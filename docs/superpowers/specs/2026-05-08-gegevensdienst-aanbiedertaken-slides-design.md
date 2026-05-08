# Spec: Slides Gegevensdienst Verzamelen Aanbiedertaken

**Datum**: 2026-05-08
**Auteur**: Roland Groen
**Status**: Concept

## Doel

Drie content-slides toevoegen aan `Technische sessie KoppelMij CONCEPT-3.pptx` voor het onderwerp **3.3 Verzamelen aanbiedertaken**, plus de bijbehorende markdown-bronbestanden in `work-documents/presentation/`. Inhoud is gebaseerd op:

- [Memo: ServiceRequest als orkestratiemiddel in KoppelMij](https://vzvznl.github.io/Koppeltaal-2.0-FHIR/memo-servicerequest-koppelmij.html) (lokaal: `Koppeltaal-2.0-FHIR/input/pagecontent/memo-servicerequest-koppelmij.md`)
- [MedMij R4 Provider Module IG — Technical Design](https://simplifier.net/guide/medmij-r4-provider-module-ig/Home/Technical-design.md?version=current)
- Lokale gegevensdienst-pagina: `koppelmij-designs/input/pagecontent/gegevensdienst.md`

## Scope

- Drie nieuwe markdown-slides in `work-documents/presentation/`.
- Generator-script (`generate_pptx.py`) uitbreiden zodat de drie slides op de juiste positie in CONCEPT-3 belanden.
- Sectie-titel-slide 15 fixen: typo `aanbiedertakenb` → `aanbiedertaken`.

## Buiten scope

- Wijzigingen aan de inhoud van slide-09 t/m slide-13 (3.4–3.8 walkthroughs).
- Aanpassingen aan `gegevensdienst.md` of `memo-servicerequest-koppelmij.md`.
- Diagrammen/SVG's toevoegen aan de slides (de bron-pagina's bevatten SVG's, maar de bestaande deck-stijl gebruikt alleen tekstuele bullets).

## Plaatsing in deck

Huidige CONCEPT-3 layout (relevante slides):

| Pos | Titel |
|-----|-------|
| 14 | Overige uitgangspunten |
| 15 | Gegevensdienst verzamelen aanbiedertaken*b* (sectie-titel) |
| 16 | 3.3 Verzamelen aanbiedertaken (placeholder met ruwe inhoud) |
| 17 | Acties ter voorbereiding op designathon |
| 18 | Task-status en transities |

Doelresultaat (functioneel):

| Pos | Titel | Bron |
|-----|-------|------|
| 14 | Overige uitgangspunten | onveranderd |
| 15 | Gegevensdienst verzamelen aanbiedertaken | typo-fix |
| 16 | 3.3 Verzamelen aanbiedertaken — scope | NIEUW (vervangt placeholder) |
| 17 | 3.3 Verzamelen aanbiedertaken — FHIR-resources | NIEUW (ingevoegd) |
| 18 | 3.3 Verzamelen aanbiedertaken — gegevensafspraken | NIEUW (ingevoegd) |
| 19 | Acties ter voorbereiding op designathon | doorgeschoven |
| 20 | Task-status en transities | doorgeschoven |

**Let op — afwijking met script-resultaat**: De huidige CONCEPT-3 heeft *Task-status en transities* op positie 18 (na *Acties / Designathon*), niet op positie 13 zoals het script zou produceren. Dat suggereert dat de huidige CONCEPT-3 niet 1-op-1 een script-output is. De implementatie moet dus een keuze maken over de bron: óf het script in plaats van CONCEPT-2 vanaf de huidige CONCEPT-3 laten werken, óf eerst CONCEPT-2 brengen op het door de gebruiker gewenste niveau. Deze keuze hoort in het implementatieplan.

## Slide-inhoud

### Slide 16 — `slide-12a-verzamelen-aanbiedertaken-scope.md`

Titel: **3.3 Verzamelen aanbiedertaken — scope**

**Uitgangspunten**
- Verzamelen Aanbiedertaken is de **eerste MedMij-gegevensdienst met *uitvoerbare* (launchbare) data** — PGO's zijn nu nog "lege hulsen".
- De gegevensdienst legt twee gegevensafspraken vast:
  - **PGO ↔ DVA** — welke data het PGO ophaalt (taken, opdrachten, moduledefinities, endpoints).
  - **Module ↔ DVA** — welke data de module leest/schrijft binnen een SMART on FHIR launch (taakcontext, statusupdates).
- Betrokken partijen: **PGO** (toont taken aan cliënt), **DVA** (Dienstverlener Aanbieder; FHIR-server namens de zorgaanbieder), **Module-aanbieder** (levert behandelingen via DVA).
- De gegevensdienst legt vast *wat* er uitgewisseld wordt, niet *hoe* het tot stand komt.

**Buiten scope**
- Catalogusbeheer van `ActivityDefinition`s (uitwisseling zorgaanbieder ↔ module-aanbieder).
- FHIR Workflow / zorgplanning binnen het XIS/ECD.
- Subscription-mechanisme voor module-notificatie bij nieuwe `ServiceRequest`s.
- `ActivityDefinition.kind` als discriminator (workflow-keuze, geen gegevensuitwisseling).

*Geen Discussiepunten-sectie — scope is vastgesteld.*

### Slide 17 — `slide-12b-verzamelen-aanbiedertaken-resources.md`

Titel: **3.3 Verzamelen aanbiedertaken — FHIR-resources**

**Uitgangspunten**
- Kern-resources, geharmoniseerd met het MedMij Provider Module IG (profielen `pt-Task`, `pt-ServiceRequest-DigitalGroupPlan`, `pt-ServiceRequest-ExecutionOrder`, `pt-ActivityDefinition`, `pt-Endpoint`):
  - `Task` — individuele taak; centrale object dat PGO toont en module bijwerkt.
  - `ServiceRequest` (twee profielen) — overkoepelende **opdracht** of concrete **instructie**.
  - `ActivityDefinition` — sjabloon van de module (wat is launchbaar, via welk endpoint).
  - `Endpoint` — technisch launch-adres.
  - `Patient`, `Practitioner` / `PractitionerRole`, `Organization`.
- **Twee rollen van ServiceRequest** (een Task verwijst naar twee verschillende SR-instances):
  - `Task.basedOn` → **DigitalGroupPlan** — groepering, alle taken van dezelfde interventie delen deze SR. Voorbeeld: *"Behandelprogramma COPD"*.
  - `Task.focus` → **ExecutionOrder** — concrete (eventueel herhalende) instructie. Voorbeeld: *"Wekelijks vragenlijst Kwaliteit van Leven invullen"*.
- Verwijzing van `Task` (en `ServiceRequest`) naar `ActivityDefinition` via custom extensie **`instantiates`** — met bijbehorende SearchParameter, symmetrisch toegepast op beide resources.
- Resourcetypen `Device` en `CareTeam` worden **niet** gebruikt in deze gegevensdienst.

**Discussiepunten**
- Wie wordt `Task.requester`? Voorstel: overgenomen van `ServiceRequest.requester` — behandelaar blijft opdrachtgever.
- Eén of meerdere module-aanbieders per `ServiceRequest`? Uitgangspunt: één module per SR; samengestelde opdrachten verhogen complexiteit.

### Slide 18 — `slide-12c-verzamelen-aanbiedertaken-afspraken.md`

Titel: **3.3 Verzamelen aanbiedertaken — gegevensafspraken**

**PGO ↔ DVA**
- Ophalen: `GET /Task?owner=Patient/{patient-id}` — DVA filtert op OAuth2-context.
- Groepering in PGO-UI: op `Task.basedOn`, met groepslabel uit `ServiceRequest.code.text` (DigitalGroupPlan).
- Launch-adres resolven: keten `Task` → `ActivityDefinition` (via `instantiates`) → `Endpoint.address`.
- **DVA is leidend voor `Task.status`** — bij terugkeer haalt PGO de Task opnieuw op; eventuele `status`/`error` query-parameters op `return_url` zijn slechts een UX-hint.

**Module ↔ DVA (binnen SMART on FHIR launch-context)**
- Lezen: `GET /Task/{id}` — taak waarvoor de module is gelauncht, inclusief `basedOn`/`focus`-referenties.
- Schrijven: `PATCH /Task/{id}` voor statuswijziging via **FHIRPath Patch** (zie 3.7 Wijzigen Task-status).

**Discussiepunten**
- Lifecycle-relatie tussen `ServiceRequest` (`active` / `completed` / `revoked`) en de onderliggende `Task`s — wanneer wordt SR `completed`?

## Bestandsnaam-conventie

Bestaande markdown-bestanden in `work-documents/presentation/` gebruiken een prefix die historisch is gegroeid en niet 1-op-1 overeenkomt met pptx-posities:
- `slide-09…11`: 3.4–3.6 walkthroughs
- `slide-15`: 3.7 walkthrough
- `slide-15b`: Task-status transities
- `slide-16`: 3.8 terugkeer

Voor de nieuwe slides kiezen we de prefix `slide-12a/b/c-…` om semantisch duidelijk te maken dat het om sectie 3.3 gaat (de inhoud staat conceptueel vóór 3.4–3.8). De suffix-letters geven de volgorde binnen het onderwerp aan, analoog aan het bestaande `slide-15b` patroon.

## Wijzigingen aan `generate_pptx.py`

Functionele aanpassingen:

1. **Sectie-titel-slide typo-fix**: titel van de sectie-titel-slide ("Gegevensdienst verzamelen aanbiedertaken*b*") corrigeren naar `Gegevensdienst verzamelen aanbiedertaken`.
2. **Bestaande 3.3-placeholder vervangen** door inhoud uit `slide-12a-verzamelen-aanbiedertaken-scope.md`.
3. **Twee nieuwe slides invoegen** ná de geüpdatete slide met inhoud uit `slide-12b-…-resources.md` en `slide-12c-…-afspraken.md`, met dezelfde content-layout als de slot die wordt vervangen.

De precieze indices, volgorde van operaties en bron-pptx (CONCEPT-2 vs CONCEPT-3) worden in het implementatieplan vastgelegd; ze zijn afhankelijk van de keuze die volgt uit "Let op — afwijking met script-resultaat" hierboven.

## Verificatie

- Markdown-bestanden parseren correct (titel `# …`, secties `## …`, bullets `- …`).
- `python3 generate_pptx.py` draait zonder errors.
- Resulterende `CONCEPT-3.pptx` bevat 20 slides, met de drie nieuwe op posities 16-18 en juiste titels.
- Sectie-titel-slide 15 toont `Gegevensdienst verzamelen aanbiedertaken` (zonder typo).
- Alle bestaande slide-titels van 3.4–3.8 + Task-status transities zijn ongewijzigd.

## Risico's en mitigaties

- **Layout-mismatch bij invoegen**: nieuwe slides moeten dezelfde content-layout hebben als de bestaande 3.3-placeholder. Mitigatie: layout clonen uit dezelfde slide *vóór* die wordt geüpdatet.
- **Index-shifts bij meerdere insertions**: na elke `insert_new_slide` verschuiven volgende indices. Mitigatie: insertions in oplopende volgorde, target_index expliciet herberekenen na elke stap.
- **Bron-pptx ambiguïteit**: zie de "Let op" boven — keuze tussen CONCEPT-2 of CONCEPT-3 als basis hoort in het implementatieplan, niet hier.
