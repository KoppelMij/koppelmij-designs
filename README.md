# Koppelmij Implementation Guide

Deze repository bevat de FHIR Implementation Guide voor het Koppelmij project, dat de integratie van modules in Persoonlijke Gezondheidsomgevingen (PGO's) binnen het MedMij afsprakenstelsel beschrijft.

## 📚 Gepubliceerde versies

De Implementation Guide is online beschikbaar op:

- **Hoofdversie (main branch):** https://koppelmij.github.io/koppelmij-designs/
- **Branch deployments:** https://koppelmij.github.io/koppelmij-designs/branches/
  - Feature branches: `https://koppelmij.github.io/koppelmij-designs/branches/feature-[naam]/`
  - Develop branch: `https://koppelmij.github.io/koppelmij-designs/branches/develop/`
  - Release branches: `https://koppelmij.github.io/koppelmij-designs/branches/release-[versie]/`

## 🎯 Doel

Dit project beschrijft de architectuur en technische specificaties voor veilige module launches vanuit PGO's, waarbij gebruik wordt gemaakt van:
- SMART on FHIR voor module autorisatie
- OAuth 2.0 Token Exchange (RFC 8693) voor veilige token uitwisseling
- Koppeltaal FHIR model voor gestructureerde data-uitwisseling

## 🛠️ Lokaal bouwen

### Vereisten

Voor het lokaal bouwen van deze Implementation Guide heeft u alleen nodig:

- **Docker** (Docker Desktop of Docker Engine)
  ```bash
  # Controleer uw Docker installatie
  docker --version
  ```

### Build instructies

1. **Clone de repository**
   ```bash
   git clone https://github.com/koppelmij/koppelmij-designs.git
   cd koppelmij-designs
   ```

2. **Bouw de Docker image lokaal**
   ```bash
   docker build -t koppelmij-builder:latest .
   ```
   
   Dit bouwt een lokale Docker image met alle benodigde tools voor de IG generatie.

3. **Bouw de Implementation Guide**
   ```bash
   # Standaard build (volledige documentatie package)
   docker run --rm -v ${PWD}:/src koppelmij-builder:latest
   
   # Of expliciet met make target
   docker run --rm -v ${PWD}:/src koppelmij-builder:latest build
   ```
   
   Op Windows (PowerShell):
   ```powershell
   docker run --rm -v ${PWD}:/src koppelmij-builder:latest
   ```

4. **Bekijk de gegenereerde IG lokaal**
   
   Open `output/index.html` in uw browser om de lokaal gegenereerde Implementation Guide te bekijken.

### Beschikbare Make targets

Het project gebruikt een Makefile voor verschillende build opties:

| Target | Beschrijving | Docker commando |
|--------|--------------|-----------------|
| `build` | Volledige documentatie package (standaard) | `docker run -v ${PWD}:/src koppelmij-builder` |
| `build-ig` | Bouw alleen Implementation Guide | `docker run -v ${PWD}:/src koppelmij-builder build-ig` |
| `version` | Toon huidige versie | `docker run -v ${PWD}:/src koppelmij-builder version` |
| `help` | Toon beschikbare targets | `docker run -v ${PWD}:/src koppelmij-builder help` |

### Interactieve shell voor ontwikkeling

Voor debugging of ontwikkeling kunt u een interactieve shell starten:

```bash
docker run -it --entrypoint /bin/bash \
  -v ${PWD}:/src \
  koppelmij-builder:latest
```

### Ontwikkeling workflow

Voor het bekijken van wijzigingen tijdens ontwikkeling:

1. Maak uw wijzigingen in de bronbestanden
2. Voer het Docker build commando opnieuw uit
3. Refresh uw browser om de wijzigingen te zien

**Tip**: U kunt een lokale webserver starten voor betere ontwikkelervaring:
```bash
# Met Python 3
cd output && python3 -m http.server 8080

# Of met Node.js npx
cd output && npx http-server -p 8080
```

Bezoek dan http://localhost:8080 in uw browser.

## 📁 Project structuur

```
koppelmij-ig/
├── input/
│   ├── fsh/              # FHIR Shorthand definities
│   ├── pagecontent/      # Markdown content voor de IG pagina's
│   └── images/           # Diagrammen en afbeeldingen
├── output/               # Gegenereerde IG (niet in git)
├── sushi-config.yaml     # SUSHI configuratie
└── ig.ini               # IG Publisher configuratie
```

## 📖 Belangrijke documentatie

De Implementation Guide bevat de volgende hoofdonderdelen:

- **Solution Design**: Beschrijving van Optie 3a - Token Exchange met Gebruikersidentificatie
- **Overwegingen**: Analyse van architectuurkeuzes en alternatieven
- **Harde en Zachte Vereisten**: Specificatie van vaste en flexibele onderdelen
- **Technische Specificaties**: Details over SMART on FHIR en Token Exchange implementatie

## 🤝 Bijdragen

Dit project is onderdeel van het Koppelmij initiatief. Voor vragen of bijdragen:
- Open een issue in deze repository
- Neem contact op met het projectteam

## 📄 Licentie

Dit project valt onder de voorwaarden zoals gespecificeerd in het MedMij afsprakenstelsel.

## 🔗 Gerelateerde projecten

- [MedMij](https://www.medmij.nl/)
- [Koppeltaal](https://koppeltaal.nl/)
- [SMART on FHIR](https://www.hl7.org/fhir/smart-app-launch/)

## ⚠️ Status

Deze Implementation Guide is in ontwikkeling en wordt actief beproefd met leveranciers. De specificaties kunnen nog wijzigen op basis van praktijkervaringen en feedback.