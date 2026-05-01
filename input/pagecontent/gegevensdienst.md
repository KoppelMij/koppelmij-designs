### Changelog

| Versie | Datum      | Wijziging                                |
|--------|------------|------------------------------------------|
| 0.0.1  | 2026-04-30 | Initiële versie                          |
| 0.0.2  | 2026-05-01 | Verwijzing naar SMART Task-based Launch toegevoegd |
| 0.0.3  | 2026-05-01 | Twee rollen van ServiceRequest (basedOn vs focus) uitgewerkt |
| 0.0.4  | 2026-05-01 | Scope herdefinieerd: focus op gegevensafspraken PGO-DVA en Module-DVA; workflow/orkestratie buiten scope |

---

### Inleiding

In KoppelMij fungeert het PGO als het centrale overzicht voor de cliënt. De cliënt wil **in één oogopslag alle taken van verschillende zorgaanbieders zien** — zonder eerst in afzonderlijke modules te moeten kijken. Dit vereist dat individuele taken binnen een module zichtbaar en launchbaar zijn vanuit het PGO.

Deze pagina beschrijft de **FHIR-gegevensdienst Verzamelen Aanbiedertaken**: welke FHIR-resources beschikbaar zijn bij de DVA, en wat de gegevensafspraken zijn tussen de betrokken partijen. De gegevensdienst is de eerste MedMij-gegevensdienst die *uitvoerbare* (launchbare) data bevat.

### Scope

De gegevensdienst definieert twee gegevensafspraken:

1. **PGO - DVA**: welke data het PGO ophaalt bij de DVA (taken, opdrachten, moduledefinities, endpoints).
2. **Module - DVA**: welke data de module leest en schrijft **in de context van een SMART on FHIR launch** (taakcontext, statusupdates).

{::nomarkdown}
{% include gegevensdienst-scope.svg %}
{:/}

#### Buiten scope van deze gegevensdienst

De gegevensdienst legt vast *wat* er uitgewisseld wordt, niet *hoe* de data tot stand komt. De volgende onderwerpen vallen buiten scope:

- **Catalogusbeheer van ActivityDefinitions** — hoe de zorgaanbieder (niet noodzakelijk de DVA) de catalogus van moduledefinities opbouwt en uitwisselt met module-aanbieders.
- **FHIR Workflow / Zorgplanning** — hoe in een zorginformatiesysteem (XIS/ECD) het proces verloopt waarmee een behandelaar tot een Task of ServiceRequest komt.
- **Subscription-mechanisme** — hoe de module-aanbieder genotificeerd wordt over nieuwe ServiceRequests (orkestratie tussen module en CKT/zorgaanbieder).
- **`ActivityDefinition.kind` als discriminator** — de keuze tussen `Task`- en `ServiceRequest`-flow is een workflow-beslissing, geen onderdeel van de gegevensuitwisseling. Zie [Harmonisatie met Koppeltaal](#harmonisatie-met-koppeltaal-informatief) voor context.

### Betrokken partijen

| Partij | Rol |
|--------|-----|
| **PGO** | Toont taken uit DVA's van zorgaanbieders aan de cliënt. PGO's zijn "lege hulsen" die met deze gegevensdienst voor het eerst uitvoerbare (launchbare) data ontvangen. |
| **DVA** | Dienstverlener Aanbieder — ontsluit data namens de zorgaanbieder. De DVA biedt de FHIR-server waarop PGO en module hun gegevensafspraken uitvoeren. |
| **Module-aanbieder** | Biedt (online) behandelingen of andere diensten aan via de DVA van de zorgaanbieder. De module leest en schrijft taakdata in de context van een SMART on FHIR launch. |

### FHIR Resources

| Resource | Rol in de gegevensdienst |
|----------|--------------------------|
| `Task` | Individuele taak voor de cliënt — het centrale object dat het PGO toont en de module bijwerkt |
| `ServiceRequest` | Overkoepelende opdracht of concrete instructie waaraan taken gebonden zijn |
| `ActivityDefinition` | Sjabloon van de module; beschrijft wat gelauncht kan worden en via welk endpoint |
| `Endpoint` | Technisch launch-adres van de module |
| `Patient` | De cliënt voor wie de taken bedoeld zijn |
| `Practitioner` / `PractitionerRole` | De behandelaar die de opdracht heeft geïnitieerd |

### Resource-relaties

{::nomarkdown}
{% include memo-sr-resource-relaties.svg %}
{:/}

De kern van het model:
- De **ActivityDefinition** verwijst via de extensie `endpoint` naar het **Endpoint** met het launch-adres.
- De **Task** verwijst via de extensie `instantiates` naar de **ActivityDefinition** die beschrijft welke module gelauncht wordt.
- Elke **Task** heeft twee referentiepaden naar ServiceRequest, elk met een eigen semantiek:

#### Twee rollen van ServiceRequest

Een Task verwijst naar twee *verschillende* ServiceRequest-instances:

| Referentie | Rol | Voorbeeld |
|------------|-----|-----------|
| `Task.basedOn` | **Groepering** — de overkoepelende interventie waarbinnen de taak valt. Alle taken van dezelfde interventie delen dezelfde `basedOn` ServiceRequest. | *"Behandelprogramma COPD"* |
| `Task.focus` | **Instructie** — de concrete, eventueel herhalende opdracht voor de patiënt waaraan deze taak invulling geeft. | *"Wekelijks vragenlijst Kwaliteit van Leven invullen"* of *"Dagelijks bloeddruk meten"* |

Dit onderscheid is nodig omdat een individuele taak ("vul vandaag de vragenlijst in", "doe nu een meting") een eigen lifecycle heeft (`requested → in-progress → completed`), maar gebonden kan zijn aan een bredere en/of herhalende instructie. De `basedOn` ServiceRequest groepeert alle taken van een interventie; de `focus` ServiceRequest legt de specifieke opdracht vast die tot deze taak heeft geleid.

Beide zijn altijd verschillende resource-instances: de groeperings-SR opereert op interventieniveau, de instructie-SR op opdrachtniveau.

### Gegevensafspraak PGO - DVA

Het PGO haalt taken op via de DVA FHIR-server. De zoekvraag is:

```
GET /Task?patient={patient-id}&status=requested,accepted,in-progress,completed
```

Het PGO groepeert de ontvangen taken op basis van `Task.basedOn` (verwijzing naar ServiceRequest) en `Task.groupIdentifier` (label voor weergave). Zo kan het PGO per interventie een overzicht tonen van individuele taken, met status per taak.

Het PGO resolvet het launch-adres via de keten `Task → ActivityDefinition → Endpoint.address` (zie [Technical Walkthrough: Uitvoeren launch als PGO](technical-walkthrough-pgo-launch-uitvoeren.html)).

### Gegevensafspraak Module - DVA (SMART on FHIR context)

De module ontvangt bij de SMART on FHIR launch de taakcontext (patient, task-id, fhirUser) en communiceert via het access_token met de DVA FHIR-server.

**Lezen:**
- `GET /Task/{id}` — opvragen van de taak waarvoor de module is gelauncht, inclusief de referenties naar `basedOn` en `focus` ServiceRequests.

**Schrijven:**
- `PUT /Task/{id}` — bijwerken van `Task.status` en optioneel `Task.output` (zie [Technical Walkthrough: Wijzigen Task-status](technical-walkthrough-module-task-status-wijzigen.html)).

De volledige SMART on FHIR launch-flow (van launch-voorbereiding tot terugkeer naar PGO) is beschreven in de [Technical Walkthroughs](technical-walkthrough-pgo-launch-voorbereiden.html).

### Link naar ActivityDefinition: extensie `instantiates`

In Koppeltaal wordt op de Task een custom extensie [`instantiates`](http://vzvz.nl/fhir/StructureDefinition/instantiates) gebruikt om te verwijzen naar de ActivityDefinition. Het voorstel is om dezelfde extensie **symmetrisch op de ServiceRequest** toe te passen:

- De verwijzing van ServiceRequest naar ActivityDefinition wordt op dezelfde manier geïmplementeerd als bij Task.
- Een vergelijkbare SearchParameter kan worden gedefinieerd voor ServiceRequest.
- Het zoek- en Subscription-criterium wordt gebaseerd op een bewezen mechanisme.

### Harmonisatie met Koppeltaal (informatief)

De gegevensdienst is ontworpen in samenhang met Koppeltaal. Een belangrijk harmonisatiepunt is het gebruik van `ActivityDefinition.kind` als discriminator voor het type workflow:

| `AD.kind` | Betekenis | Flow |
|-----------|-----------|------|
| `Task` (of leeg) | Module werkt op taakniveau | Huidige Koppeltaal-werkwijze: één taak per toewijzing, module als black box. |
| `ServiceRequest` | Module werkt op opdrachtniveau | KoppelMij-werkwijze: module maakt individuele taken aan binnen een ServiceRequest. |

Dit is een **workflow-beslissing** die buiten de gegevensdienst zelf valt — de DVA bevat het resultaat (de Tasks en ServiceRequests), ongeacht welk patroon tot hun creatie heeft geleid. Het PGO en de module hoeven het onderscheid niet te kennen; zij werken altijd met dezelfde FHIR-resources.

{::nomarkdown}
{% include memo-sr-koppelmij-flow.svg %}
{:/}

Ter vergelijking de huidige Koppeltaal-flow:

{::nomarkdown}
{% include memo-sr-koppeltaal-flow.svg %}
{:/}

Zie de [Memo: ServiceRequest als orkestratiemiddel](https://vzvznl.github.io/Koppeltaal-2.0-FHIR/memo-servicerequest-koppelmij.html) voor de volledige analyse en de [SMART Task-based Launch overwegingen](smart_task_launch.html) voor vergelijking met het experimentele SMART Task-based Launch mechanisme.

### Open vragen

#### Wie wordt de requester van de taken?

Wanneer de module taken aanmaakt binnen een ServiceRequest:

- **De behandelaar** — logisch vanuit zorgperspectief, maar de module kent de behandelaar mogelijk niet direct.
- **Overgenomen van de ServiceRequest** — `Task.requester` = `ServiceRequest.requester`. Dit lijkt het meest consistent: de behandelaar is en blijft de opdrachtgever.

#### Kan een ServiceRequest taken van meerdere module-aanbieders bevatten?

Het huidige voorstel gaat uit van één module-aanbieder per ServiceRequest. Een samengestelde opdracht (meerdere modules) verhoogt de complexiteit aanzienlijk en vereist nadere uitwerking.

#### Lifecycle-relatie ServiceRequest en Tasks

De bestaande Task lifecycle (`requested → accepted → in-progress → completed`) blijft van toepassing op individuele taken. De ServiceRequest introduceert een bovenliggende lifecycle:

- `active`: er kunnen nog taken worden toegevoegd.
- `completed`: alle taken zijn afgerond.
- `revoked`: de opdracht is ingetrokken.

De relatie tussen de Task-lifecycles en de ServiceRequest-lifecycle moet eenduidig worden gedefinieerd.

### Referenties

- [FHIR Workflow](https://www.hl7.org/fhir/workflow.html)
- [Clinical Order Workflow (COW) IG](https://build.fhir.org/ig/HL7/fhir-cow-ig/en/workflow-patterns.html)
- [FHIR ActivityDefinition](https://www.hl7.org/fhir/activitydefinition.html)
- [FHIR ServiceRequest](https://www.hl7.org/fhir/servicerequest.html)
- [FHIR Task](https://www.hl7.org/fhir/task.html)
- [Memo: ServiceRequest als orkestratiemiddel in KoppelMij](https://vzvznl.github.io/Koppeltaal-2.0-FHIR/memo-servicerequest-koppelmij.html)
