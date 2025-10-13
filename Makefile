# Makefile for FHIR build process

# Variables
DOTNET_TOOLS := $(HOME)/.dotnet/tools

# Fetch version from sushi-config.yaml with error handling
export VERSION := $(shell grep '^version:' sushi-config.yaml | sed 's/version: //' | tr -d '[:space:]')
ifeq ($(VERSION),)
$(error "Could not extract version from sushi-config.yaml")
endif

# Export PATH with dotnet tools
export PATH := $(PATH):$(DOTNET_TOOLS)

# Default target
.PHONY: all
all: build

# Build target (full documentation package)
.PHONY: build
build: install-dependencies convert-drawio build-ig

# Install dependencies
.PHONY: install-dependencies
install-dependencies:
	@fhir install nictiz.fhir.nl.r4.zib2020@0.12.0-beta.4
	@fhir inflate --package nictiz.fhir.nl.r4.zib2020@0.12.0-beta.4

# Build Implementation Guide (Full with documentation)
.PHONY: build-ig
build-ig:
	@echo "Building Full Implementation Guide with version $(VERSION)..."
	java -jar /usr/local/publisher.jar -ig ig.ini
	@if [ ! -f ./output/package.tgz ]; then \
		echo "ERROR: Build did not create ./output/package.tgz"; \
		exit 1; \
	fi
	@echo "Copying package.tgz to: ./output/koppelmij-$(VERSION).tgz"
	@cp ./output/package.tgz ./output/koppelmij-$(VERSION).tgz
	@echo "Successfully created: ./output/koppelmij-$(VERSION).tgz"

# Show version
.PHONY: version
version:
	@echo "Version: $(VERSION)"

# Convert drawio files to PNG
.PHONY: convert-drawio
convert-drawio:
	@python3 scripts/convert_drawio.py

# Clean target (optional)
.PHONY: clean
clean:
	@echo "Clean target not implemented - add cleanup commands if needed"

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  build    - Run the complete FHIR build process (full documentation package)"
	@echo "  install-dependencies  - Install FHIR dependencies"
	@echo "  build-ig - Build Implementation Guide using FHIR publisher (full)"
	@echo "  convert-drawio - Convert all drawio files to PNG format"
	@echo "  version  - Show the current version from sushi-config.yaml"
	@echo "  clean    - Clean build artifacts (not implemented)"
	@echo "  help     - Show this help message"
