# Harde en Zachte Vereisten in de Standaard

## Inleiding

Bij het ontwikkelen en beproeven van deze standaard met leveranciers maken we een onderscheid tussen harde en zachte vereisten. Dit document beschrijft welke onderdelen van de standaard als vaststaand worden beschouwd en welke onderdelen open staan voor discussie, verfijning of aanpassing op basis van praktijkervaringen.

Het is belangrijk om te benadrukken dat ook de harde vereisten niet volledig in steen gebeiteld zijn. Indien tijdens de beproeving blijkt dat fundamentele aanpassingen noodzakelijk zijn, kunnen ook deze ter discussie worden gesteld. Echter, wijzigingen aan harde vereisten betekenen vaak dat we "terug naar de tekentafel" moeten, omdat hier al uitgebreide overwegingen en ontwerpbeslissingen aan ten grondslag liggen.

## Harde Vereisten

De volgende onderdelen van de standaard worden beschouwd als harde vereisten. Deze vormen de kern van de architectuur en zijn gebaseerd op uitgebreide analyse en overwegingen:

### 1. Architectuurkeuze: Optie 3a

**Vereiste**: De implementatie volgt het architectuurpatroon van Optie 3a - Token Exchange met Gebruikersidentificatie.

**Rationale**: Deze keuze is gebaseerd op een grondige analyse van verschillende alternatieven, waarbij Optie 3a de beste balans biedt tussen:
- Flexibiliteit voor DVA-implementaties
- Behoud van controle over authenticatie door de DVA
- Standaard compliance met SMART on FHIR
- Schaalbaarheid voor het ecosysteem

**Impact bij wijziging**: Een andere architectuurkeuze zou een fundamentele herziening van het volledige ontwerp vereisen.

### 2. Gekozen Standaarden

**Vereiste**: De standaard is gebaseerd op:
- SMART on FHIR voor module launches
- OAuth 2.0 Token Exchange (RFC 8693) voor token uitwisseling

**Rationale**: Deze standaarden zijn:
- Internationaal geaccepteerd en breed geïmplementeerd
- Bewezen in productieomgevingen
- Ondersteund door een actieve community
- Compatibel met bestaande zorginfrastructuur

**Impact bij wijziging**: Het verlaten van deze standaarden zou leiden tot:
- Verlies van interoperabiliteit
- Hogere implementatiekosten
- Langere ontwikkeltijd
- Verminderde herbruikbaarheid van bestaande componenten

## Zachte Vereisten

De volgende onderdelen staan open voor discussie, verfijning en aanpassing op basis van praktijkervaringen en input van leveranciers:

### 1. FHIR Context in Token Response

**Open vraag**: Hoe wordt de FHIR context het beste meegegeven in de token response van SMART on FHIR?

**Opties volgens SMART on FHIR specificatie**:

**Optie A: Direct in de token response**
- FHIR context parameters direct als velden in de token response
- Bijvoorbeeld: `patient`, `encounter`, `fhirContext` parameters
- Simpele, backwards-compatible benadering
- Voorbeeld:
  ```json
  {
    "access_token": "...",
    "patient": "123",
    "encounter": "456"
  }
  ```

**Optie B: Via authorization_details array (Experimenteel)**
- Context informatie voor meerdere FHIR servers in een `authorization_details` array
- Ondersteunt multi-server scenarios
- Volgt RFC 9396 (OAuth 2.0 Rich Authorization Requests)
- Elke entry bevat server-specifieke context met `locations` array
- Voorbeeld:
  ```json
  {
    "access_token": "...",
    "authorization_details": [{
      "type": "fhir_context",
      "locations": ["https://fhir.example.org"],
      "patient": "123",
      "encounter": "456",
      "fhirVersions": ["4.0.1"]
    }]
  }
  ```
- **Let op**: Dit is een experimentele feature voor complexere multi-server scenarios

**Gewenste input**:
- Is er een use case voor de experimentele multi-server authorization_details feature?
- Zijn er scenario's waarbij modules data van meerdere FHIR servers moeten benaderen?
- Is de simpele aanpak (Optie A) voldoende voor de voorziene implementaties?
- Welke praktijkervaringen zijn er met beide benaderingen?

**Referenties**:
- [SMART App Launch IG - Token Response](https://build.fhir.org/ig/HL7/smart-app-launch/app-launch.html#response-5)
- [Experimental: Authorization Details for Multiple Servers](https://build.fhir.org/ig/HL7/smart-app-launch/app-launch.html#experimental-authorization-details-for-multiple-servers-exp)

### 2. Client Identificatie van Moduleapplicaties

**Open vraag**: Hoe identificeren en vertrouwen we moduleapplicaties optimaal?

Deze vraag heeft twee belangrijke aspecten:

#### Aspect 1: Scope van vertrouwensmodel

**Afweging**: Waar leggen we de verantwoordelijkheid voor het vertrouwen van modules?

**Opties**:
- **MedMij model**: DVA bepaalt zelf welke modules vertrouwd worden (buiten afsprakenstelsel)
  - Maximale vrijheid voor DVA's
  - Mogelijk fragmentatie in het ecosysteem

- **Koppeltaal model**: Vertrouwensmodel is onderdeel van de standaard
  - Uniforme aanpak in het ecosysteem
  - Duidelijke richtlijnen voor alle partijen

- **Hybride model**: Best practices met ruimte voor DVA-specifieke uitbreidingen
  - Balans tussen standaardisatie en flexibiliteit

**Gewenste input**:
- Voorkeur leveranciers: vrijheid vs. duidelijke richtlijnen?
- Behoefte aan ecosystem-brede uniformiteit?
- Welke rol moet het afsprakenstelsel hierin spelen?

#### Aspect 2: Technische implementatie van client authenticatie

**Voorgestelde aanpak**: RFC 7523 - JWT Profile for OAuth 2.0 Client Authentication

**Uitdaging**: Hoe vinden en vertrouwen we de publieke sleutels van modules?

**Opties voor sleuteldistributie**:
- **Koppeltaal aanpak**: Centraal beheersysteem met JWKS endpoint registratie
  - Modules registreren hun JWKS endpoint in centraal systeem
  - Voordeel: Centraal beheer en oversight
  - Nadeel: Koppeltaal-specifieke infrastructuur vereist

- **did:web alternatief**: Gedecentraliseerde identiteit via DID specificatie
  - Publieke sleutels vindbaar via DID resolutie
  - Voordeel: Standaard-gebaseerd, gedecentraliseerd en aansluiting bij NUTS
  - Nadeel: Complexere implementatie
  - Voorbeeld: `did:web:module.example.com` resoleert naar publieke sleutels

- **Directe sleutelregistratie**: Publieke sleutels direct delen/registreren
  - Modules delen hun publieke sleutel direct met DVA
  - Voordeel: Simpel en direct
  - Nadeel: Minder flexibel bij sleutelrotatie

- **Andere voorstellen**: Open voor suggesties van leveranciers

**Gewenste input**:
- Ervaringen met verschillende methoden van publieke sleuteldistributie?
- Voorkeur voor gecentraliseerd vs. gedecentraliseerd sleutelbeheer?
- Hoe wordt sleutelrotatie het beste ondersteund?
- Balans tussen veiligheid en implementatiecomplexiteit?

### 3. Sessie Management

**Open vraag**: Hoe kunnen we optimaal omgaan met sessie management tussen DVA, PGO en modules?

**Aspecten ter overweging**:
- Sessie timeout configuratie
- Sessie synchronisatie mechanismen
- Single logout implementatie
- Sessie hervatting na onderbreking

### 4. Error Handling en Recovery

**Open vraag**: Is de bestaande MedMij error handling specificatie voldoende voor module launches?

**Context**: MedMij heeft al uitgebreide specificaties voor error handling, inclusief:
- Gestandaardiseerde error codes
- Retry mechanismen
- Fallback procedures
- Gebruikerscommunicatie richtlijnen

**Te evalueren**:
- Dekken de MedMij error specificaties alle module launch scenarios?
- Zijn er module-specifieke error situaties die aanvullende handling vereisen?
- Is de bestaande error response structuur voldoende informatief voor troubleshooting?
- Moeten we aanvullende error codes definiëren voor Token Exchange flows?

**Gewenste input**:
- Praktijkervaringen met MedMij error handling
- Identificatie van gaps in huidige error specificaties
- Module-specifieke error scenarios die aandacht behoeven
- Suggesties voor eventuele uitbreidingen

