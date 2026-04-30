### Inleiding

In KoppelMij fungeert het PGO als het centrale overzicht voor de cliënt. De cliënt wil **in één oogopslag alle taken van verschillende zorgaanbieders zien** — zonder eerst in afzonderlijke modules te moeten kijken. Dit vereist dat individuele taken binnen een module zichtbaar en launchbaar zijn vanuit het PGO.

Deze pagina beschrijft de FHIR-gegevensdienst die dit mogelijk maakt: welke resources betrokken zijn, hoe ze zich tot elkaar verhouden, en welke interactiepatronen worden gebruikt door het PGO, de module-aanbieder en het ECD.

De gegevensdienst bouwt voort op de bestaande Koppeltaal-werkwijze en breidt deze uit met het concept van een **ServiceRequest als overkoepelende opdracht**, waarbinnen de module individuele taken voor de cliënt aanmaakt.

### FHIR Resources

| Resource | Rol |
|----------|-----|
| `ActivityDefinition` | Sjabloon van de module; `kind` bepaalt het type flow (`Task` of `ServiceRequest`) |
| `ServiceRequest` | Overkoepelende opdracht van behandelaar aan module |
| `Task` | Individuele taak voor de cliënt, gebonden aan de ServiceRequest |
| `Endpoint` | Technisch launch-adres van de module |
| `Patient` | De cliënt |
| `Practitioner` / `PractitionerRole` | De behandelaar |
| `Subscription` | Mechanisme waarmee de module nieuwe ServiceRequests detecteert |

### Resource-relaties

{::nomarkdown}
{% include memo-sr-resource-relaties.svg %}
{:/}

De kern van het model:
- De **ServiceRequest** verwijst via de extensie `instantiates` naar de **ActivityDefinition** die beschrijft welke module wordt aangevraagd.
- Elke **Task** verwijst via `basedOn` naar de **ServiceRequest** waarbinnen hij valt.
- De **ActivityDefinition** verwijst via de extensie `endpoint` naar het **Endpoint** met het launch-adres.

### Twee operationele patronen

Het veld `ActivityDefinition.kind` bepaalt welk patroon van toepassing is. Beide patronen kunnen naast elkaar bestaan — een module-aanbieder kan zowel ActivityDefinitions van type `Task` als van type `ServiceRequest` aanbieden.

#### Patroon 1: `AD.kind = Task` (Koppeltaal-werkwijze)

De huidige Koppeltaal-werkwijze. De module is een ondeelbaar geheel:

1. De behandelaar wijst module Y toe aan de cliënt.
2. Er ontstaat één Task in de Koppeltaalvoorziening.
3. De cliënt opent de module en werkt alles af.
4. De module rapporteert het resultaat terug.

De behandelaar heeft geen zicht op wat er *binnen* de module gebeurt. De module is een black box.

#### Patroon 2: `AD.kind = ServiceRequest` (KoppelMij-werkwijze)

De KoppelMij-uitbreiding. De module is een samenwerkingspartner die taken aandraagt:

1. De behandelaar vraagt een interventie aan voor de cliënt (bijv. *"Start behandelprogramma B"*).
2. Er ontstaat een **ServiceRequest** in de Centrale Koppeltaal (CKT) voorziening.
3. De module-aanbieder detecteert deze ServiceRequest (via Subscription) en **vult deze aan met individuele taken** (B1, B2, B3, ...) voor de cliënt.
4. De behandelaar kan ook **handmatig extra taken toevoegen** binnen dezelfde ServiceRequest.
5. De cliënt ziet in het PGO alle taken en kan ze individueel launchen.

{::nomarkdown}
{% include memo-sr-koppelmij-flow.svg %}
{:/}

Het wezenlijke verschil: de module is niet langer een black box, maar draagt individuele taken aan binnen een door de behandelaar geïnitieerde opdracht. Het PGO kan deze taken centraal tonen.

#### Ter vergelijking: huidige Koppeltaal-flow

{::nomarkdown}
{% include memo-sr-koppeltaal-flow.svg %}
{:/}

### Verzamelen door het PGO

Het PGO haalt taken op via de DVA FHIR-server. De zoekvraag is:

```
GET /Task?patient={patient-id}&status=requested,accepted,in-progress,completed
```

Het PGO groepeert de ontvangen taken op basis van `Task.basedOn` (verwijzing naar ServiceRequest) en `Task.groupIdentifier` (label voor weergave). Zo kan het PGO per interventie een overzicht tonen van individuele taken, met status per taak.

Voor het launchen van een individuele taak volgt het PGO de stappen beschreven in de [Technical Walkthroughs](technical-walkthrough-pgo-launch-voorbereiden.html).

### Subscription-mechanisme

De module-aanbieder moet genotificeerd worden over nieuwe ServiceRequests die betrekking hebben op haar ActivityDefinition(s). Dit kan via een FHIR Subscription op basis van de `instantiates` extensie:

```json
{
  "resourceType": "Subscription",
  "status": "active",
  "reason": "Notificatie bij nieuwe ServiceRequests voor module X",
  "criteria": "ServiceRequest?instantiates=ActivityDefinition/module-x",
  "channel": {
    "type": "rest-hook",
    "endpoint": "https://module-x.example.com/notifications/servicerequest",
    "payload": "application/fhir+json"
  }
}
```

Dit vereist een SearchParameter voor de `instantiates` extensie op ServiceRequest, analoog aan de bestaande [`task-instantiates`](http://koppeltaal.nl/fhir/SearchParameter/task-instantiates) SearchParameter.

### Link naar ActivityDefinition: extensie `instantiates`

In Koppeltaal wordt op de Task een custom extensie [`instantiates`](http://vzvz.nl/fhir/StructureDefinition/instantiates) gebruikt om te verwijzen naar de ActivityDefinition. Het voorstel is om dezelfde extensie **symmetrisch op de ServiceRequest** toe te passen:

- Wordt de verwijzing van ServiceRequest naar ActivityDefinition op dezelfde manier geïmplementeerd als bij Task.
- Kan een vergelijkbare SearchParameter worden gedefinieerd voor ServiceRequest.
- Wordt het zoek- en Subscription-criterium gebaseerd op een bewezen mechanisme.

### Impact per rol

#### Module-aanbieder

- Bij `AD.kind = Task`: geen verandering. De module ontvangt taken zoals nu.
- Bij `AD.kind = ServiceRequest`:
  - Publiceer een ActivityDefinition met `kind = ServiceRequest`.
  - Abonneer op nieuwe ServiceRequests (via Subscription).
  - Maak bij ontvangst van een ServiceRequest zelf taken aan binnen de CKT.

#### ECD-aanbieder

- Bij `AD.kind = ServiceRequest`: maak een ServiceRequest aan in plaats van (of naast) een Task.
- Koppel de ServiceRequest aan de ActivityDefinition via de `instantiates` extensie.
- Beheer meerdere actieve ServiceRequests per cliënt.

#### PGO-aanbieder

- Groepeer taken onder hun ServiceRequest — van een platte takenlijst naar een gestructureerd overzicht.

#### Patiëntportaal-aanbieder

- Vergelijkbare impact als PGO: taken groeperen onder de ServiceRequest, met een gestructureerd overzicht in de UI.

### Aansluiting op FHIR Workflow

Het gekozen patroon sluit aan op de [FHIR Workflow](https://www.hl7.org/fhir/workflow.html) specificatie:

- **ServiceRequest** beschrijft de *intentie* of *opdracht*: wat er moet gebeuren.
- **Task** beschrijft de *concrete uitvoering*, inclusief status (`requested`, `accepted`, `in-progress`, `completed`).

De HL7 [Clinical Order Workflow (COW) IG](https://build.fhir.org/ig/HL7/fhir-cow-ig/en/workflow-patterns.html) beschrijft patronen voor het coördineren van orders. In onze context gaan we ervan uit dat de toewijzing reeds is overeengekomen: de module-aanbieder is bekend. We sluiten aan bij het COW-patroon in zoverre dat we starten met een overeengekomen ServiceRequest met `Task.basedOn` als verbinding naar de taken.

### Open vragen

#### Wie wordt de requester van de taken?

Wanneer de module taken aanmaakt binnen een ServiceRequest:

- **De behandelaar** — logisch vanuit zorgperspectief, maar de module kent de behandelaar mogelijk niet direct.
- **Overgenomen van de ServiceRequest** — `Task.requester` = `ServiceRequest.requester`. Dit lijkt het meest consistent: de behandelaar is en blijft de opdrachtgever.

#### Kan een ServiceRequest taken van meerdere module-aanbieders bevatten?

Het huidige voorstel gaat uit van één module-aanbieder per ServiceRequest. Een samengestelde opdracht (meerdere modules) verhoogt de complexiteit aanzienlijk (Subscription, autorisatie, afsluiting) en vereist nadere uitwerking.

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
