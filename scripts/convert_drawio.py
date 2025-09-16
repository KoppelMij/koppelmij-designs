#!/usr/bin/env python3
"""
Convert drawio files to PNG format using drawio CLI or API
"""

import os
import sys
import subprocess
import glob
from pathlib import Path

def check_drawio_cli():
    """Check if drawio CLI is available"""
    try:
        subprocess.run(['drawio', '--version'], capture_output=True, check=False)
        return True
    except FileNotFoundError:
        return False

def convert_with_cli(input_file, output_file):
    """Convert using drawio CLI"""
    # In Docker container, we need to use xvfb-run for headless operation
    if os.path.exists('/.dockerenv'):
        cmd = ['xvfb-run', '-a', 'drawio', '-x', '-f', 'png', '-b', '10', '-o', output_file, input_file]
    else:
        cmd = ['drawio', '-x', '-f', 'png', '-b', '10', '-o', output_file, input_file]

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error converting {input_file}: {result.stderr}")
        return False
    return True

def convert_with_docker(input_file, output_file):
    """Convert using Docker"""
    cwd = os.path.abspath(os.getcwd())
    # Get the directory and filename
    input_dir = os.path.dirname(input_file)
    input_basename = os.path.basename(input_file)
    output_dir = os.path.dirname(output_file)

    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    cmd = [
        'docker', 'run', '--rm',
        '-v', f'{cwd}:/data',
        'rlespinasse/drawio-export:latest',
        '-f', 'png',
        '-b', '10',
        '-o', f'/data/{output_dir}',
        '--remove-page-suffix',
        f'/data/{input_file}'
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error converting {input_file}: {result.stderr}")
        return False

    # Check if the file was created (it might have a different name)
    expected_output = output_file
    if not os.path.exists(expected_output):
        # Check for file with -1 suffix (single page)
        possible_output = output_file.replace('.png', '-1.png')
        if os.path.exists(possible_output):
            os.rename(possible_output, expected_output)

    return os.path.exists(expected_output)

def main():
    # Find all drawio files
    pattern = 'input/images/koppeltaal/*.drawio'
    files = glob.glob(pattern)

    if not files:
        print(f"No drawio files found matching pattern: {pattern}")
        return 1

    print(f"Found {len(files)} drawio file(s) to convert")

    # Determine conversion method
    use_cli = check_drawio_cli()
    use_docker = False

    if not use_cli:
        try:
            subprocess.run(['docker', '--version'], capture_output=True, check=True)
            use_docker = True
        except (FileNotFoundError, subprocess.CalledProcessError):
            pass

    if not use_cli and not use_docker:
        print("ERROR: Neither drawio CLI nor Docker is available.")
        print("Please install one of:")
        print("  - drawio CLI: npm install -g @jgraph/drawio-cli")
        print("  - Docker: https://www.docker.com/get-started")
        return 1

    # Convert files
    success_count = 0
    for input_file in files:
        output_file = input_file.replace('.drawio', '.png')
        print(f"Converting {input_file} to {output_file}...")

        if use_cli:
            success = convert_with_cli(input_file, output_file)
        else:
            success = convert_with_docker(input_file, output_file)

        if success:
            success_count += 1
            print(f"  ✓ Successfully converted")
        else:
            print(f"  ✗ Failed to convert")

    print(f"\nConversion complete: {success_count}/{len(files)} files converted successfully")
    return 0 if success_count == len(files) else 1

if __name__ == '__main__':
    sys.exit(main())
