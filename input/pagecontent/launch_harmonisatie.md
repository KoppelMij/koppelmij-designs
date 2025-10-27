# Harmonisatie van Module Launch: HTI Token vs Token Exchange

## Inleiding

Voor de harmonisatie van het starten van modules (Stap 2 uit de gefaseerde aanpak van Optie 3) moet er een keuze gemaakt worden over hoe de launch context wordt meegegeven aan modules. Dit document analyseert de huidige situaties in Koppeltaal en KoppelMij en presenteert drie opties voor harmonisatie.

## Huidige situatie

### Perspectief van de module applicatie

In alle gevallen is het perspectief van de module applicatie identiek en volledig SMART on FHIR compliant:

1. Module ontvangt een SMART on FHIR launch request met `launch` en `iss` parameters
2. Module haalt de SMART configuratie op bij de `iss` URL (`.well-known/smart-configuration`)
3. Module begint een authorization flow naar het `/authorize` endpoint
4. Na gebruikerstoestemming volgt een code exchange bij het `/token` endpoint
5. Module ontvangt een access_token en context informatie (patient, fhirUser, etc.)

Dit proces is volledig gestandaardiseerd volgens SMART on FHIR. Het verschil tussen de implementaties zit in **hoe de portalen tot een launch komen** en **hoe de context wordt meegegeven**.

### Koppeltaal: HTI Token

In de Koppeltaal implementatie wordt een **HTI (Health Tools Interoperability) token** gebruikt:

**Werkwijze:**
- Portaal ondertekent een JWT (HTI token) met daarin de context:
  - Taak referentie (Task ID)
  - Patiënt referentie (Patient ID)
  - Andere relevante FHIR resource referenties
  - Metadata over de launch
- Dit HTI token wordt meegegeven als `launch` parameter in de SMART launch URL
- Module start SMART on FHIR flow met het HTI token als launch parameter
- Koppeltaal authorization service:
  - Valideert de handtekening van het HTI token
  - Pakt het token uit en extraheert de context
  - Geeft de context terug in de token response van de SMART flow

**Kenmerken:**
- **Ondertekend JWT**: HTI token is een ondertekend JWT, dus cryptografisch beveiligd
- **Self-contained**: Alle context informatie zit in het token zelf
- **Validatie**: Authorization service valideert handtekening en expiratie
- **Context in token**: Context wordt direct uit het JWT gehaald en teruggegeven

**Voorbeeld HTI token payload:**
```json
{
  "iss": "https://portal.example.com",
  "sub": "Patient/123",
  "aud": "https://koppeltaal.example.com/fhir",
  "exp": 1234567890,
  "iat": 1234567000,
  "task": "Task/456",
  "patient": "Patient/123",
  "practitioner": "Practitioner/789"
}
```

### KoppelMij (Solution Design 3a): Token Exchange

In de KoppelMij implementatie (Optie 3a) wordt **Token Exchange (RFC 8693)** gebruikt:

**Werkwijze:**
- PGO heeft al een access_token van de DVA (uit de verzamel-fase)
- PGO voert een Token Exchange uit bij de DVA:
  - `grant_type=urn:ietf:params:oauth:grant-type:token-exchange`
  - `subject_token={DVA_access_token}` (bestaand token)
  - `audience={DVA_FHIR_URL}`
  - `resource=Task/456&resource=Observation/789` (context als parameters)
- DVA valideert de toegang tot de opgegeven resources
- DVA genereert een `launch_token` (opaque of JWT)
- DVA **houdt de context vast** en associeert deze met het launch_token
- PGO start module met dit launch_token als `launch` parameter
- Module start SMART on FHIR flow
- DVA **geeft de opgeslagen context terug** in de token response

**Kenmerken:**
- **Server-side state**: DVA houdt context vast, gekoppeld aan launch_token
- **Token Exchange standaard**: Gebruikt RFC 8693 voor token verkrijging
- **Resource parameters**: Context wordt meegegeven als extra parameters
- **Validatie vooraf**: DVA valideert toegang bij Token Exchange
- **Context uit state**: Context wordt opgehaald uit server-side state bij token response

**Token Exchange request voorbeeld:**
```http
POST /token HTTP/1.1
Host: dva.example.com
Content-Type: application/x-www-form-urlencoded

grant_type=urn:ietf:params:oauth:grant-type:token-exchange
&subject_token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
&requested_token_type=urn:ietf:params:oauth:token-type:access_token
&audience=https://dva.example.com/fhir
&resource=Task/456
&resource=Observation/789
```

## Vergelijking van beide aanpakken

| Aspect                        | HTI Token (Koppeltaal)                        | Token Exchange (KoppelMij)                           |
|-------------------------------|-----------------------------------------------|------------------------------------------------------|
| **Standaard basis**           | Custom JWT extensie                           | RFC 8693 Token Exchange                              |
| **Context locatie**           | In het token zelf (JWT payload)               | Server-side state bij authorization service          |
| **Token type**                | Ondertekend JWT                               | Opaque token of JWT                                  |
| **Validatie**                 | Handtekening verificatie                      | Subject token validatie + resource autorisatie       |
| **State management**          | Stateless (self-contained)                    | Stateful (server houdt context)                      |
| **Complexiteit portaal**      | Moet JWT kunnen ondertekenen                  | Moet Token Exchange kunnen doen                      |
| **Complexiteit auth service** | Moet JWT kunnen valideren                     | Moet context kunnen opslaan en ophalen               |
| **Beveiliging**               | Asymmetrische cryptografie                    | Subject token + server-side validatie                |
| **Transparantie**             | Context zichtbaar in JWT (indien gedecodeerd) | Context verborgen in server-side state               |
| **Hergebruik**                | Token is eenmalig, context immutable          | Launch token is eenmalig, subject token herbruikbaar |

## Beide oplossingen zijn aanpassingen van SMART on FHIR

Het is belangrijk te erkennen dat **beide implementaties afwijkingen zijn van de standaard SMART on FHIR specificatie**:

**Standaard SMART on FHIR:**
- Launch parameter is een opaque identifier
- Context wordt bepaald door de authorization service op basis van gebruikerssessie
- Geen specifieke mechanisme voor context meegave vanuit portaal

**Koppeltaal HTI:**
- **Afwijking**: HTI token is een gestructureerd JWT met specifieke claims
- **Toevoeging**: Specifieke JWT structuur en validatie vereisten
- **Voordeel**: Self-contained en cryptografisch beveiligd

**KoppelMij Token Exchange:**
- **Afwijking**: Vereist extra Token Exchange stap vóór launch
- **Toevoeging**: Resource parameters in Token Exchange voor context
- **Voordeel**: Gebruikt bestaande RFC 8693 standaard

## Optie 1: Niets doen - Beide standaarden handhaven

In deze optie blijven beide afsprakenstelsels hun eigen implementatie gebruiken zonder harmonisatie.

### Beschrijving

**Koppeltaal:**
- Blijft HTI token gebruiken voor module launches
- Portalen ondertekenen HTI tokens met context
- Koppeltaal authorization service valideert HTI tokens

**KoppelMij:**
- Blijft Token Exchange gebruiken voor launch_token verkrijging
- PGO doet Token Exchange met resource parameters
- DVA houdt context vast en geeft deze terug in token response

**Use case afhankelijk:**
- Voor elke specifieke use case wordt bepaald welke aanpak gebruikt wordt
- Cross-ecosystem integraties vereisen maatwerk oplossingen

### Voordelen

- **Geen wijzigingen nodig**: Bestaande implementaties blijven ongewijzigd
- **Onafhankelijke ontwikkeling**: Beide ecosystemen kunnen zelfstandig doorontwikkelen
- **Bewezen oplossingen**: Beide methodes zijn getest en werkend
- **Geen migratie**: Geen impact op bestaande leveranciers en systemen
- **Risico-arm**: Geen risico op nieuwe bugs of implementatieproblemen

### Nadelen

- **Geen harmonisatie**: Doel van Stap 2 wordt niet bereikt
- **Dubbele complexiteit**: Module leveranciers moeten beide methodes ondersteunen
- **Verwarring**: Leveranciers moeten weten welke methode in welke context te gebruiken
- **Schaalbaarheid**: Moeilijker om nieuwe use cases toe te voegen
- **Onderhoud**: Twee verschillende implementaties om te onderhouden
- **Interoperabiliteit**: Cross-ecosystem scenarios blijven complex
- **Training en documentatie**: Dubbele documentatie en trainingsmateriaal nodig

### Wanneer te kiezen

Deze optie is zinvol als:
- Harmonisatie niet haalbaar blijkt door fundamentele verschillen
- Beide ecosystemen volledig gescheiden blijven opereren
- De kosten van harmonisatie de baten overtreffen
- Er onvoldoende draagvlak is voor wijzigingen

### Impact

| Stakeholder                | Impact                                    | Mitigatie                                       |
|----------------------------|-------------------------------------------|-------------------------------------------------|
| **Module leveranciers**    | Moeten beide methodes implementeren       | Goede documentatie en referentie-implementaties |
| **Portaal leveranciers**   | Verschillende implementatie per ecosystem | Duidelijke scheiding in codebase                |
| **Authorization services** | Twee verschillende flows ondersteunen     | Modulaire architectuur                          |
| **Standaardisatie beheer** | Twee standaarden te beheren               | Gecoördineerde release planning                 |
| **Nieuwe toetreders**      | Hogere instapdrempel                      | Uitgebreide onboarding materiaal                |

## Optie 2: Token Exchange harmonisatie - Koppeltaal aanpassen

In deze optie wordt Token Exchange de geharmoniseerde standaard en past Koppeltaal zich hierop aan.

### Beschrijving

**Koppeltaal past aan naar Token Exchange:**
- Portalen verkrijgen eerst een launch_token via Token Exchange bij Koppeltaal authorization service
- Context wordt meegegeven als `resource` parameters in Token Exchange request
- Koppeltaal authorization service houdt context vast (stateful)
- Bij module launch wordt de opgeslagen context teruggegeven
- HTI token wordt uitgefaseerd

**Beide ecosystemen gebruiken:**
- Token Exchange (RFC 8693) voor launch_token verkrijging
- Resource parameters voor context meegave
- Server-side state management voor context
- Identiek SMART on FHIR launch proces

### Workflow

**Voor Koppeltaal (nieuw):**

1. **Portaal sessie**: Gebruiker is ingelogd bij behandelportaal/patiëntportaal
2. **Token verkrijging**: Portaal heeft access_token voor Koppeltaal authorization service
3. **Token Exchange**:
   - Portaal doet Token Exchange bij Koppeltaal authorization service
   - Meegegeven: `subject_token`, `audience`, `resource` parameters
   - Koppeltaal valideert toegang en genereert launch_token
   - Koppeltaal **slaat context op** gekoppeld aan launch_token
4. **Module launch**: Portaal start module met launch_token
5. **SMART flow**: Module doorloopt SMART on FHIR flow
6. **Context terugkrijgen**: Koppeltaal geeft opgeslagen context terug in token response

**Voor KoppelMij (ongewijzigd):**
- Blijft werken zoals beschreven in Solution Design 3a

### Voordelen

- **Volledige harmonisatie**: Één methode voor beide ecosystemen
- **RFC 8693 compliant**: Gebruikt bestaande OAuth 2.0 extensie standaard
- **Uniforme implementatie**: Module leveranciers implementeren één flow
- **Schaalbaarheid**: Eenvoudig uit te breiden naar nieuwe use cases
- **Duidelijke documentatie**: Één set documentatie en voorbeelden
- **Interoperabiliteit**: Cross-ecosystem integraties worden eenvoudiger
- **Toekomstbestendig**: Gebaseerd op brede industrie standaard
- **Validatie vooraf**: Authorization service valideert resource toegang bij Token Exchange

### Nadelen

- **Koppeltaal wijzigingen**: Significante aanpassingen in Koppeltaal implementaties
- **Stateful**: Vereist server-side state management in Koppeltaal
- **Migratie Koppeltaal**: Bestaande Koppeltaal portalen moeten migreren
- **Subject token vereiste**: Portaal moet al een access_token hebben (extra stap)
- **Complexiteit portalen**: Token Exchange is complexer dan JWT ondertekenen
- **Transitieperiode**: Mogelijk twee flows parallel ondersteunen tijdens migratie
- **Infrastructuur aanpassingen**: Server-side state vereist database/cache infrastructuur

### Implementatie overwegingen

**Koppeltaal aanpassingen:**
- **Authorization service**:
  - Token Exchange endpoint toevoegen (`/token` met grant_type token-exchange)
  - State management implementeren voor context opslag
  - Resource parameter validatie implementeren
- **Portalen**:
  - HTI token ondertekening verwijderen
  - Token Exchange flow implementeren
  - Access token management toevoegen
- **Documentatie**:
  - Migratie guide voor bestaande implementaties
  - Nieuwe ontwikkelaars documentatie
  - Best practices voor state management

**Transitie strategie:**
- **Parallel support**: Beide flows tijdelijk ondersteunen
- **Deprecation timeline**: HTI token geleidelijk uitfaseren
- **Backwards compatibility**: Oude module versies blijven werken
- **Phased rollout**: Stapsgewijze uitrol per zorgaanbieder

### Wanneer te kiezen

Deze optie is geschikt als:
- Volledige harmonisatie de hoogste prioriteit heeft
- RFC 8693 compliance belangrijk is voor toekomstige integraties
- Koppeltaal bereid is significante wijzigingen door te voeren
- Er voldoende tijd en budget is voor migratie
- Stateful implementatie acceptabel is voor authorization services

### Impact

| Stakeholder             | Impact                                               | Mitigatie                                          |
|-------------------------|------------------------------------------------------|----------------------------------------------------|
| **Koppeltaal AS**       | Grote wijzigingen: Token Exchange + state management | Gefaseerde implementatie, technische ondersteuning |
| **Koppeltaal portalen** | Migratie van HTI naar Token Exchange                 | Migratie tools, documentatie, test omgeving        |
| **KoppelMij DVA**       | Geen wijziging (reeds Token Exchange)                | N.v.t.                                             |
| **Module leveranciers** | Vereenvoudiging (één flow)                           | Communicatie over benefits                         |
| **Beheer organisaties** | Migratie coördinatie                                 | Project management, duidelijke roadmap             |

## Optie 3: HTI Token harmonisatie - KoppelMij aanpassen

In deze optie wordt het HTI token de geharmoniseerde standaard en past KoppelMij zich hierop aan.

### Beschrijving

**KoppelMij past aan naar HTI token:**
- PGO of DVA ondertekent een HTI token met context (Task, Patient, etc.)
- HTI token wordt gebruikt als `launch` parameter in module launch
- DVA authorization service valideert HTI token handtekening
- Context wordt uit HTI token geëxtraheerd en teruggegeven
- Token Exchange wordt uitgefaseerd (of optioneel gemaakt)

**Beide ecosystemen gebruiken:**
- HTI token (ondertekend JWT) voor context meegave
- Self-contained tokens met alle context informatie
- Stateless authorization services
- Identiek SMART on FHIR launch proces

### Varianten

Er zijn twee varianten mogelijk voor waar het HTI token wordt gegenereerd:

#### Variant 3a: DVA genereert HTI token

**Workflow:**
1. PGO doet Token Exchange bij DVA (bestaande flow)
2. **DVA genereert HTI token** in plaats van opaque launch_token
3. HTI token bevat alle context (Task, Patient, resources)
4. DVA ondertekent HTI token met private key
5. PGO ontvangt HTI token en start module
6. Module start SMART flow, DVA valideert HTI handtekening
7. DVA extraheert context uit HTI token en geeft terug

**Voordelen:**
- Minimale wijziging in PGO (alleen token format wijzigt)
- DVA behoudt controle over token inhoud
- Token Exchange blijft bestaan als validatie stap

**Nadelen:**
- Token Exchange blijft nodig (extra stap)
- DVA moet JWT ondertekening implementeren

#### Variant 3b: PGO genereert HTI token

**Workflow:**
1. PGO heeft context informatie (Task ID, Patient ID)
2. **PGO ondertekent zelf een HTI token** met eigen private key
3. PGO start module direct met HTI token (geen Token Exchange)
4. Module start SMART flow met DVA
5. DVA valideert HTI token handtekening (PGO's public key)
6. DVA valideert dat PGO toegang heeft tot resources in HTI token
7. DVA extraheert context en geeft terug

**Voordelen:**
- Token Exchange niet meer nodig (vereenvoudiging)
- PGO heeft directe controle
- Snellere flow (één stap minder)

**Nadelen:**
- PGO moet JWT ondertekening kunnen doen
- DVA moet PGO's public keys kennen en vertrouwen
- Complexere trust model (elk PGO heeft eigen keys)

### Voordelen (algemeen)

- **Self-contained**: Alle context in het token, geen server-side state nodig
- **Stateless**: Authorization services hoeven geen state te bewaren
- **Cryptografisch beveiligd**: Ondertekend JWT voorkomt tampering
- **Transparantie**: Context is zichtbaar (JWT kan gedecodeerd worden)
- **Eenvoudige validatie**: Alleen handtekening verificatie nodig
- **Koppeltaal ongewijzigd**: Bestaande Koppeltaal implementatie blijft werken
- **Bewezen technologie**: HTI token is al in productie bij Koppeltaal

### Nadelen (algemeen)

- **KoppelMij wijzigingen**: DVA en/of PGO moeten JWT ondertekening implementeren
- **Non-standard**: HTI token is geen breed geaccepteerde standaard
- **Key management**: Public/private key beheer nodig voor signing
- **Token size**: JWT tokens zijn groter dan opaque tokens
- **Immutable context**: Context kan niet aangepast na token generatie
- **Trust management**:
  - Variant 3a: DVA moet eigen keys beheren
  - Variant 3b: DVA moet alle PGO keys kennen en vertrouwen
- **Geen vooraf validatie**:
  - Variant 3b: Resource toegang wordt pas gevalideerd bij authorize, niet bij token generatie

### Implementatie overwegingen

**Voor variant 3a (DVA genereert HTI):**
- **DVA wijzigingen**:
  - JWT library integreren voor token ondertekening
  - Private/public key pair genereren en beheren
  - HTI token structure implementeren volgens Koppeltaal spec
  - Token Exchange response wijzigen (JWT in plaats van opaque)
- **PGO wijzigingen**:
  - Minimaal (ontvangt ander token format)
  - Mogelijk JWT decoding voor debugging/logging
- **Module wijzigingen**:
  - Geen (ontvangt SMART launch zoals altijd)

**Voor variant 3b (PGO genereert HTI):**
- **PGO wijzigingen**:
  - JWT library integreren voor token ondertekening
  - Private/public key pair genereren en beheren
  - HTI token structure implementeren
  - Token Exchange stap verwijderen
- **DVA wijzigingen**:
  - JWT validatie implementeren
  - PGO public keys ophalen en cachen (via JWKS endpoint)
  - Trust model implementeren (welke PGO's worden vertrouwd)
  - Resource autorisatie validatie bij `/authorize`
  - Token Exchange endpoint kan verwijderd/optioneel worden
- **Module wijzigingen**:
  - Geen (ontvangt SMART launch zoals altijd)

**HTI token structuur (voorbeeld):**
```json
{
  "iss": "https://pgo.example.com",
  "sub": "Patient/123",
  "aud": "https://dva.example.com/fhir",
  "exp": 1234567890,
  "iat": 1234567000,
  "jti": "unique-token-id",
  "task": "Task/456",
  "patient": "Patient/123",
  "resources": [
    "Task/456",
    "Observation/789",
    "CarePlan/101"
  ]
}
```

### Wanneer te kiezen

Deze optie is geschikt als:
- Self-contained tokens en stateless architectuur de voorkeur hebben
- Koppeltaal's bewezen HTI implementatie als basis kan dienen
- KoppelMij bereid is JWT ondertekening te implementeren
- Transparantie van context belangrijk is (debuggability)
- Server-side state management vermeden wil worden

**Variant 3a kiezen als:**
- DVA controle over token inhoud moet behouden
- PGO capabilities beperkt moeten blijven
- Token Exchange als validatie-gate gewenst is

**Variant 3b kiezen als:**
- Vereenvoudiging (minder stappen) prioriteit heeft
- PGO's capabel zijn voor JWT ondertekening
- Direct launch zonder extra roundtrip gewenst is

### Impact

| Stakeholder             | Impact Variant 3a                | Impact Variant 3b                | Mitigatie                             |
|-------------------------|----------------------------------|----------------------------------|---------------------------------------|
| **DVA**                 | JWT signing implementeren        | JWT validation + trust model     | JWT libraries, key management tooling |
| **PGO**                 | Minimaal (token format wijzigt)  | JWT signing + key management     | JWT libraries, documentatie           |
| **Koppeltaal**          | Geen wijziging                   | Geen wijziging                   | N.v.t.                                |
| **Module leveranciers** | Geen wijziging                   | Geen wijziging                   | N.v.t.                                |
| **Beheer KoppelMij**    | Standaard documentatie aanpassen | Standaard documentatie aanpassen | HTI spec documenteren                 |

## Vergelijking van opties

| Aspect                     | Optie 1: Niets doen | Optie 2: Token Exchange        | Optie 3a: DVA HTI            | Optie 3b: PGO HTI        |
|----------------------------|---------------------|--------------------------------|------------------------------|--------------------------|
| **Harmonisatie**           | Geen                | Volledig                       | Volledig                     | Volledig                 |
| **Standaard basis**        | Beide bestaand      | RFC 8693                       | HTI (Koppeltaal)             | HTI (Koppeltaal)         |
| **Wijzigingen Koppeltaal** | Geen                | Groot (Token Exchange + state) | Geen                         | Geen                     |
| **Wijzigingen KoppelMij**  | Geen                | Geen                           | Middel (JWT signing DVA)     | Groot (JWT signing PGO)  |
| **State management**       | Mixed               | Stateful                       | Stateless                    | Stateless                |
| **Complexiteit portalen**  | Depends             | Token Exchange                 | Token Exchange + JWT         | JWT signing              |
| **Complexiteit AS**        | Both methods        | State + validation             | JWT validation               | JWT + trust + validation |
| **Aantal stappen**         | Depends             | 3 (exchange + launch + flow)   | 3 (exchange + launch + flow) | 2 (launch + flow)        |
| **Validatie timing**       | Depends             | Bij Token Exchange             | Bij Token Exchange           | Bij authorize            |
| **Key management**         | Depends             | Geen extra                     | DVA keys                     | PGO + DVA keys           |
| **Trust model**            | Depends             | Token based                    | DVA signing                  | Multi-party trust        |
| **Module impact**          | Dubbel              | Geen                           | Geen                         | Geen                     |
| **Migratie omvang**        | Geen                | Koppeltaal groot               | KoppelMij middel             | KoppelMij groot          |
| **Toekomstbestendigheid**  | Laag                | Hoog (RFC)                     | Middel                       | Middel                   |
| **Interoperabiliteit**     | Laag                | Hoog                           | Middel                       | Middel                   |

## Aanbevelingen

### Technische overwegingen

**Optie 1 (Niets doen):**
- Alleen geschikt als harmonisatie niet haalbaar blijkt
- Accepteer permanente dualiteit in implementaties
- Investeer in goede documentatie voor beide flows

**Optie 2 (Token Exchange):**
- Beste keuze voor **volledige harmonisatie op basis van industrie standaard**
- Vereist significante investering in Koppeltaal migratie
- Stateful implementatie kan uitdagend zijn voor schaalbaarheid
- Beste long-term oplossing als RFC 8693 adoptie toeneemt

**Optie 3a (DVA HTI):**
- Goede **compromis** tussen harmonisatie en beperkte wijzigingen
- Behoudt Token Exchange als validatie stap
- Stateless voordeel van HTI
- DVA behoudt controle over token inhoud

**Optie 3b (PGO HTI):**
- **Meest vereenvoudigde flow** (minste stappen)
- Vereist mature key management bij PGO's
- Trust model complexiteit bij DVA
- Geschikt als PGO's capabel zijn voor crypto operaties

### Strategische overwegingen

1. **Harmonisatie prioriteit**: Als volledige harmonisatie het belangrijkste doel is, kies Optie 2 of 3
2. **Migratie capaciteit**: Evalueer of Koppeltaal (Optie 2) of KoppelMij (Optie 3) meer capaciteit heeft voor wijzigingen
3. **Standaard compliance**: RFC 8693 (Optie 2) heeft voorkeur voor lange termijn interoperabiliteit
4. **Stateless voorkeur**: Als stateless architectuur belangrijk is, kies Optie 3
5. **Time to market**: Optie 1 of 3a hebben snelste implementatie
6. **Complexity**: Optie 3a heeft laagste totale complexiteit

### Gefaseerde aanpak

Een hybride benadering is ook mogelijk:

**Fase 1: Optie 3a implementeren**
- Korte termijn harmonisatie bereiken
- Beperkte wijzigingen in KoppelMij (alleen DVA)
- Geen wijziging in Koppeltaal
- Stateless voordelen benutten

**Fase 2: Evaluatie en eventueel naar Optie 2**
- Evalueer RFC 8693 adoptie in de industrie
- Evalueer behoefte aan runtime resource validatie
- Overweeg migratie naar Token Exchange als dat de dominante standaard wordt
- Of blijf bij HTI als dat goed werkt

**Fase 3: Optioneel naar Optie 3b**
- Als PGO's volwassener worden in crypto operaties
- Vereenvoudig flow door Token Exchange te verwijderen
- Alleen als trust model goed beheerst kan worden

## Conclusie

De keuze tussen deze opties hangt af van:
- **Prioriteit van harmonisatie** (Optie 1 als laag, 2/3 als hoog)
- **Bereidheid tot wijziging** (Koppeltaal bij Optie 2, KoppelMij bij Optie 3)
- **Voorkeur voor standaarden** (RFC 8693 bij Optie 2, HTI bij Optie 3)
- **Architectuur voorkeur** (Stateful bij Optie 2, stateless bij Optie 3)
- **Implementatie horizon** (Kort bij Optie 3a, lang bij Optie 2)

Voor een pragmatische balans tussen harmonisatie, beperkte wijzigingen, en stateless architectuur is **Optie 3a (DVA genereert HTI token)** een sterke kandidaat. Voor maximale toekomstbestendigheid op basis van brede industrie standaarden is **Optie 2 (Token Exchange)** de beste keuze, mits de migratie-inspanning haalbaar is.
