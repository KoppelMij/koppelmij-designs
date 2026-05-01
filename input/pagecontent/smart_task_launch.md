
### SMART App Launch: Task-based Launch

De [SMART App Launch v2.2.0](https://build.fhir.org/ig/HL7/smart-app-launch/task-launch.html) specificatie introduceert een experimenteel mechanisme om SMART-applicatie-launches te initiëren via FHIR Task-resources. Dit is relevant voor KoppelMij omdat het een alternatieve benadering biedt voor het koppelen van taken aan module-launches.

### Wat is Task-based Launch?

Task-based launch definieert twee profielen op de FHIR Task-resource waarmee een systeem (bijvoorbeeld een CDS-engine of een ECD) kan verzoeken dat een SMART-applicatie wordt gestart:

| Profiel | Doel | Context |
|---------|------|---------|
| `task-ehr-launch` | EHR-geïntegreerde launch | Patient, Encounter en optionele `appContext` worden meegegeven via de Task |
| `task-standalone-launch` | Standalone launch | Alleen de applicatie-URL; geen geïntegreerde EHR-context |

De Task bevat gecodeerde inputs uit het codesysteem `http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes`:

- **`smartonfhir-application`**: de URL van de te lanceren applicatie.
- **`smartonfhir-appcontext`** (alleen bij EHR launch): optionele contextdata die aan de applicatie wordt doorgegeven.

Bij een EHR launch wordt `Task.for` gebruikt voor de Patient en `Task.encounter` voor de Encounter.

### Relatie tot KoppelMij

In KoppelMij gebruiken we een eigen launch-mechanisme gebaseerd op Token Exchange (RFC 8693) en SMART on FHIR App Launch. De Task-based Launch specificatie biedt een complementaire benadering die op een aantal punten raakt aan onze architectuur:

#### Overeenkomsten

- **Task als drager van launch-intent**: zowel in KoppelMij als in Task-based Launch is de FHIR Task het middel waarmee een launch-verzoek wordt gecommuniceerd. In KoppelMij verwijst de Task via `instantiates` naar een ActivityDefinition die het launch-adres bevat; in Task-based Launch bevat de Task zelf de applicatie-URL als input.
- **Patient-context**: beide benaderingen koppelen de launch aan een specifieke patiënt (`Task.for`).
- **EHR-initiatie**: in beide gevallen kan een behandelaar of systeem de launch initiëren.

#### Verschillen

| Aspect | KoppelMij | SMART Task-based Launch |
|--------|-----------|------------------------|
| **Launch-adres** | Indirect: Task → ActivityDefinition → Endpoint.address | Direct: Task.input met applicatie-URL |
| **Autorisatie** | Token Exchange (RFC 8693) voor launch_code, daarna SMART on FHIR authorization flow | Standaard SMART EHR-launch of standalone launch |
| **Gebruikersidentificatie** | DVA identificeert gebruiker opnieuw (DigiD of cookie) | EHR-sessie van de gebruiker |
| **Orkestratie** | ServiceRequest als overkoepelende opdracht; module maakt taken aan | Task staat op zichzelf; geen ServiceRequest-patroon |
| **Status** | Experimenteel (SMART v2.2.0) | KoppelMij is gebaseerd op stabiele SMART v2.1.0 |

#### Waarom we Task-based Launch niet direct gebruiken

1. **Experimentele status**: Task-based Launch is gemarkeerd als experimenteel in de SMART App Launch specificatie. Voor een productie-afsprakenstelsel als MedMij is een stabiele basis vereist.
2. **Ontbrekende orkestratie**: Task-based Launch kent geen ServiceRequest-patroon. In KoppelMij is de ServiceRequest essentieel voor het scheiden van de behandelaarsopdracht van de individuele taken die de module aanmaakt.
3. **Autorisatiemodel**: KoppelMij vereist Token Exchange en gebruikersherauthenticatie bij de DVA, wat niet past in het Task-based Launch model dat uitgaat van een bestaande EHR-sessie.
4. **Indirectie via ActivityDefinition**: KoppelMij gebruikt ActivityDefinition als herbruikbaar sjabloon (welke module, welk endpoint, welke configuratie). Task-based Launch plaatst de applicatie-URL direct in de Task, wat minder flexibel is bij wijzigingen in het launch-adres.

### Toekomstige relevantie

Wanneer Task-based Launch een stabiele status bereikt, kan het interessant zijn om de KoppelMij-profielen te aligneren met de SMART Task-profielen. Concreet:

- De `smartonfhir-application` input-code zou als alternatief voor de `instantiates`-extensie + Endpoint-keten kunnen dienen, mits de orkestratie- en autorisatielagen behouden blijven.
- Interoperabiliteit met internationale SMART-applicaties wordt eenvoudiger als de Task-structuur herkenbaar is voor systemen die Task-based Launch implementeren.

Dit vereist monitoring van de HL7-specificatie en evaluatie zodra de status naar `trial-use` of `normative` gaat.

### Referenties

- [SMART App Launch v2.2.0 - Task Profile for Requesting SMART Launch](https://build.fhir.org/ig/HL7/smart-app-launch/task-launch.html)
- [SMART App Launch v2.1.0](https://hl7.org/fhir/smart-app-launch/STU2.1/) (huidige stabiele basis voor KoppelMij)
