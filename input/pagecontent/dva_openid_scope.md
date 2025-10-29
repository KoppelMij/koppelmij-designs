# DVA als Identity Provider: De `openid` scope vraagstuk

## Inleiding

Dit document analyseert een fundamentele spanning in de architectuur van KoppelMij: de rol van de DVA als authorization server versus identity provider, en de implicaties voor het gebruik van de `openid` scope in SMART on FHIR launches naar modules.

Het vraagstuk ontstaat door de eis uit de startnotitie dat modules **via meerdere wegen toegankelijk moeten zijn** (meervoudige toegang), en de daaruit volgende noodzaak voor consistente gebruikersidentificatie over deze verschillende toegangswegen.

## Achtergrond: SMART on FHIR scopes

### Authorization Server vs Identity Provider

In OAuth 2.0 en OpenID Connect is er een belangrijk onderscheid:

**Authorization Server (OAuth 2.0):**
- Geeft toestemming voor toegang tot resources
- Geeft `access_token` uit voor resource toegang
- Hoeft gebruiker niet te identificeren (alleen te autoriseren)
- Focus: "Mag deze applicatie deze resources benaderen?"

**Identity Provider (OpenID Connect):**
- Authenticeer gebruikers en geeft identiteit door
- Geeft `id_token` uit (JWT met gebruikersclaims)
- Vereist `openid` scope in de authorization request
- Focus: "Wie is deze gebruiker?"

### SMART on FHIR scopes voor gebruikersidentiteit

SMART on FHIR biedt twee mechanismen voor gebruikersidentificatie:

**1. `openid` scope (OpenID Connect):**
- Maakt de authorization server een Identity Provider
- Vereist dat server een `id_token` uitgeeft
- Id_token bevat claims zoals `sub` (subject identifier), `name`, `email`, etc.
- Id_token is een ondertekend JWT dat de identiteit bevestigt
- Gebruik: Wanneer app de identiteit van de gebruiker moet kennen en verifiëren

**2. `fhirUser` scope (SMART on FHIR):**
- Geeft FHIR resource referentie van de gebruiker
- Komt terug in token response als `fhirUser` parameter
- Bijvoorbeeld: `"fhirUser": "Patient/123"` of `"fhirUser": "Practitioner/456"`
- Geen id_token, alleen resource referentie
- Gebruik: Wanneer app wil weten welke FHIR resource de gebruiker representeert

**Combinatie `openid fhirUser`:**
- Combineert beide: id_token (met `sub` claim) + FHIR resource referentie
- Authorization server is zowel Identity Provider als FHIR authorization server
- Gebruik: Wanneer sterke gebruikersidentificatie nodig is én FHIR context

## Situatie 1: PGO <> DVA (Verzamelen van taken)

### Context

Wanneer een PGO taken verzamelt bij de DVA:
- PGO heeft gebruiker al geauthenticeerd (bijv. met DigiD)
- PGO vraagt toestemming aan DVA om FHIR resources in te lezen
- PGO is de identity provider, niet de DVA

### OAuth 2.0 scope

**Geen `openid` scope:**
```
scope=patient/Task.read patient/ActivityDefinition.read
```

**Reden:**
- DVA hoeft gebruiker niet te authenticeren (PGO heeft dit al gedaan)
- DVA geeft alleen toestemming voor resource toegang
- DVA geeft `access_token` uit (geen `id_token`)

**Rol DVA:**
- **Authorization Server**: Ja, geeft toestemming voor FHIR resource toegang
- **Identity Provider**: Nee, DVA identificeert gebruiker niet

### Token response

```json
{
  "access_token": "eyJhbG...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "patient/Task.read patient/ActivityDefinition.read",
  "patient": "Patient/123"
}
```

**Geen id_token aanwezig** - DVA is geen IdP in deze context.

## Situatie 2: Koppeltaal <> Module (Bestaande praktijk)

### Context

Wanneer een portaal (behandelportaal of patiëntportaal) een module start in Koppeltaal:
- Portaal initieert SMART on FHIR launch
- Module verwerkt gezondheidsgegeven van een specifieke persoon
- Module MOET zeker weten dat de juiste gebruiker is geauthenticeerd

### SMART on FHIR scope

**Inclusief `openid fhirUser`:**
```
scope=launch openid fhirUser patient/*.read
```

**Reden:**
- Module verwerkt persoonlijke gezondheidsgegevens
- Module moet identiteit van gebruiker vaststellen
- Koppeltaal authorization server authenticeert gebruiker
- Id_token bevestigt gebruikersidentiteit cryptografisch

**Rol Koppeltaal Authorization Server:**
- **Authorization Server**: Ja, geeft toestemming voor FHIR resource toegang
- **Identity Provider**: Ja, authenticeert gebruiker en geeft id_token uit

### Token response

```json
{
  "access_token": "eyJhbG...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "launch openid fhirUser patient/*.read",
  "id_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "patient": "Patient/123",
  "fhirUser": "Patient/123"
}
```

**Id_token aanwezig** - bevat `sub` claim met unieke gebruikers identifier.

**Voorbeeld id_token payload:**
```json
{
  "iss": "https://koppeltaal.example.com",
  "sub": "user-unique-id-12345",
  "aud": "module-client-id",
  "exp": 1234567890,
  "iat": 1234567000,
  "fhirUser": "Patient/123"
}
```

### Waarom Koppeltaal kiest voor `openid` scope

Uit de Koppeltaal specificatie (TOP-KT-007) blijkt een duidelijke rationale voor het gebruik van `openid` scope:

**1. Unsolicited authentication risico:**
> "HTI is daarom, zonder extra identificatie van de gebruiker, onvoldoende beveiligd om toegang te verlenen tot persoonlijke en/of medische gegevens."

Het HTI token alleen (met context informatie) is onvoldoende beveiligd. Er is risico dat de launch wordt onderschept of gestolen. Daarom is een authenticatiestap noodzakelijk.

**2. SMART on FHIR autorisatiestap als beveiliging:**
> "Dit is dan ook de rol van SMART on FHIR app launch framework. Hier wordt in de autorisatiestap de gebruiker door middel van SSO opnieuw geïdentificeerd, en deze gegevens worden gematched met de inhoud van het HTI launch bericht."

In de `/authorize` stap van SMART on FHIR wordt de gebruiker via SSO opnieuw geïdentificeerd. Deze identiteit wordt gematched met de `sub` claim in het HTI token.

**3. Identity matching proces:**
Het HTI token bevat in het `sub` veld een FHIR resource referentie (Patient/123, Practitioner/456, of RelatedPerson/789). Bij de autorisatiestap:
- Gebruiker authenticeert via SSO (bijv. DigiD)
- Koppeltaal authorization service haalt identiteit op van Identity Provider
- Deze identiteit wordt gematcht met identifier(s) in de FHIR resource
- Er moet een mapping bestaan tussen IdP identiteit en FHIR resource identifier

**4. Scope is altijd `launch openid fhirUser`:**
> "Omdat in koppeltaal vooralsnog de gebruiker altijd onderdeel is van de launch, is de scope altijd `launch openid fhirUser`."

Koppeltaal vereist altijd gebruikersidentificatie voor module launches die persoons/medische gegevens verwerken.

**5. Access_token is NOOP:**
> "In koppeltaal is de keuze gemaakt om de applicaties - en niet de individuele gebruikers - toegang te geven op de FHIR resource server."

Het `access_token` is altijd "NOOP" in Koppeltaal. Toegang tot de FHIR resource service gebeurt op applicatie-niveau via SMART Backend Services (RFC 7523). **Maar het `id_token` en de context parameters zijn wel van toepassing.**

**6. Context in token response:**
Naast standaard OAuth/OIDC velden bevat de token response ook FHIR context:
- `resource`: Task reference (Task/123)
- `definition`: ActivityDefinition reference
- `sub`: Gebruiker die launch uitvoert (Patient/Practitioner/RelatedPerson)
- `patient`: Optioneel, als sub niet de patiënt is
- `intent`: Optioneel, voor verschillende launch scenario's
- `fhirUser`: FHIR resource referentie van gebruiker

**Kernpunt:**
> **Koppeltaal gebruikt `openid fhirUser` scope specifiek omdat modules persoons- en/of medische gegevens verwerken, en daarom sterke gebruikersidentificatie noodzakelijk is. Het id_token met `sub` claim is de cryptografische garantie van deze identiteit.**

## Situatie 3: DVA <> Module via PGO (KoppelMij vraagstuk)

### Context

Wanneer een PGO een module start via de DVA:
- PGO heeft gebruiker geauthenticeerd
- PGO initieert launch naar module
- Module verwerkt gezondheidsgegeven van de gebruiker
- **Module moet via PGO én via andere wegen (portaal) toegankelijk zijn**

### Het vraagstuk: Meervoudige toegang

Uit de startnotitie:
> "Een client/patient moet zelf kunnen kiezen of hij de taak voor een module wil starten via het clienten/patientenportaal of via de PGO."

**Consequentie:**
- Via portaal: Gebruiker X is geauthenticeerd, module verwerkt gegevens van gebruiker X
- Via PGO: Dezelfde gebruiker X start dezelfde module
- **Module moet vaststellen dat het dezelfde gebruiker is**

### De spanning

**Als DVA geen `openid` scope gebruikt (zoals bij PGO verzamelen):**
- Module krijgt alleen `access_token` en `fhirUser` referentie
- Geen id_token met `sub` claim
- **Module kan niet vaststellen dat de gebruiker voldoende geauthenticeerd is**, howel niets uitsluit dat dit wel het geval is.
- Module heeft geen cryptografisch bewijs van gebruikersidentiteit

**Als DVA wel `openid` scope gebruikt (zoals Koppeltaal):**
- Module krijgt id_token met `sub` claim
- Module heeft cryptografisch bewijs van gebruikersidentiteit
- Module kan vaststellen dat gebruiker voldoende geauthenticeerd is
- **Maar: DVA moet dan Identity Provider zijn**
- Dit is inconsistent met DVA rol in PGO verzamelen

### Analyse: Waarom `openid` nodig is voor modules

**Het primaire probleem:**
Module applicaties verwerken persoonlijke gezondheidsgegevens. Deze gegevens kunnen al bestaan van eerdere sessies (bijvoorbeeld via een portaal). Wanneer de module nu gestart wordt vanuit een PGO, moet de module **zeker weten dat de persoon achter het toetsenbord voldoende geauthenticeerd is** om toegang te krijgen tot die bestaande zorggegevens.

**Scenario zonder `openid` (onvoldoende authenticatie):**
1. Gebruiker start module via portaal (bijv. Koppeltaal)
   - Module ontvangt: `sub=user-12345` in id_token (cryptografisch bewijs)
   - Module slaat zorggegevens op voor deze gebruiker
   - Module weet: gebruiker is sterk geauthenticeerd (SSO via IdP)
2. Dezelfde gebruiker start module via PGO (KoppelMij zonder `openid`)
   - Module ontvangt: alleen `fhirUser=Patient/123` (slechts een referentie)
   - **Geen id_token = geen cryptografisch bewijs van authenticatie**
   - Module weet niet of gebruiker echt geauthenticeerd is
   - Launch kan gestolen/onderschept zijn (unsolicited authentication risico)
   - **Probleem**: Module kan geen toegang geven tot bestaande zorggegevens zonder authenticatiebewijs

**Scenario met `openid` (voldoende authenticatie):**
1. Gebruiker start module via portaal (Koppeltaal)
   - Module ontvangt: `sub=user-12345` in id_token
   - Module slaat zorggegevens op voor deze gebruiker
   - Module weet: gebruiker is sterk geauthenticeerd
2. Dezelfde gebruiker start module via PGO (KoppelMij met `openid`)
   - Module ontvangt: `sub=user-12345` in id_token van DVA
   - **Id_token is cryptografisch bewijs van authenticatie**
   - DVA heeft gebruiker geauthenticeerd via SSO (bijv. DigiD)
   - Module kan veilig toegang geven tot bestaande zorggegevens
   - **Oplossing**: Sterke authenticatie gewaarborgd

**Parallel met Koppeltaal's "unsolicited authentication" probleem:**
Precies zoals Koppeltaal concludeerde:
> "HTI is daarom, zonder extra identificatie van de gebruiker, onvoldoende beveiligd om toegang te verlenen tot persoonlijke en/of medische gegevens."

Voor KoppelMij geldt hetzelfde: zonder id_token (en dus zonder authenticatiebewijs) is de launch onvoldoende beveiligd om toegang te geven tot persoonlijke en/of medische gegevens.

### De vereiste: DVA als Identity Provider

**Eenvoudig gesteld:**
> **Omdat de module ook via andere manieren te benaderen is (zoals via Koppeltaal portalen), moet de module een geautoriseerde gebruiker hebben in de context van een PGO (KoppelMij).**

**Conclusie uit analyse:**
> Omdat modules via meerdere wegen toegankelijk moeten zijn, en deze modules gezondheidsgegevens verwerken die gebonden zijn aan een persoon, MOET de module de identiteit van de gebruiker kunnen vaststellen als dezelfde persoon over deze verschillende toegangswegen.

**Parallel met Koppeltaal:**
Precies zoals Koppeltaal concludeerde dat HTI token alleen onvoldoende is zonder gebruikersidentificatie, geldt hetzelfde voor KoppelMij:
- **Koppeltaal**: HTI token + SMART `openid fhirUser` → id_token met `sub` voor gebruikersidentificatie
- **KoppelMij**: Token Exchange + SMART `openid fhirUser` → id_token met `sub` voor gebruikersidentificatie

In beide gevallen is de `sub` claim in het id_token de enige manier waarop de module dezelfde gebruiker kan herkennen over verschillende toegangswegen.

**Dit betekent:**
- DVA moet een **consistente gebruikers identifier** (`sub` claim) provisionen
- DVA moet een **id_token** uitgeven met deze identifier
- DVA moet daarom een **Identity Provider** zijn in de module launch context
- Deze `sub` waarde moet **stabiel en consistent** zijn over tijd

**De `sub` waarde:**
- Hoeft **niet** de BSN te zijn (privacy overweging)
- Moet wel een **unieke en persistente** identifier zijn per gebruiker
- Moet **consistent** zijn met andere systemen waar de module mee werkt
- Bijvoorbeeld: Een pseudoniem dat door DVA wordt beheerd

## Implicaties voor DVA architectuur

### Dubbele rol van DVA

De DVA heeft verschillende rollen afhankelijk van de context:

| Context | Rol DVA | `openid` scope | `id_token` |
|---------|---------|----------------|------------|
| **PGO verzamelt taken** | Authorization Server | Nee | Nee |
| **Module launch** | Authorization Server + Identity Provider | Ja | Ja |

### Vereisten voor DVA

**1. Identity Provider functionaliteit:**
- DVA moet gebruikers kunnen authenticeren (bijv. via DigiD)
- DVA moet unieke en persistente `sub` identifiers genereren/beheren
- DVA moet id_tokens kunnen uitgeven (JWT signing)
- DVA moet OpenID Connect Discovery endpoints ondersteunen

**2. Consistente gebruikersidentificatie:**
- Dezelfde gebruiker moet altijd dezelfde `sub` waarde krijgen
- `sub` waarde moet stabiel zijn over tijd en over launches
- `sub` waarde moet consistent zijn met andere systemen (indien van toepassing)

**3. Privacy overwegingen:**
- `sub` claim hoeft niet BSN te zijn (pseudonimisering)
- Id_token mag alleen naar geautoriseerde modules gestuurd worden
- Logging en audit trail van identity provisioning

### Technische implementatie

**SMART on FHIR launch scope voor module:**
```
scope=launch openid fhirUser patient/*.read
```

**DVA authorize endpoint:**
```
GET /authorize?
  response_type=code&
  client_id=module-123&
  redirect_uri=https://module.example.com/callback&
  scope=launch+openid+fhirUser+patient/*.read&
  state=xyz&
  launch=launch-token-abc
```

**DVA token response:**
```json
{
  "access_token": "eyJhbG...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "launch openid fhirUser patient/*.read",
  "id_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "patient": "Patient/123",
  "fhirUser": "Patient/123"
}
```

**Id_token payload:**
```json
{
  "iss": "https://dva.example.com",
  "sub": "pseudonym-user-abc123",
  "aud": "module-123",
  "exp": 1234567890,
  "iat": 1234567000,
  "auth_time": 1234567000,
  "fhirUser": "Patient/123"
}
```

## Vergelijking met Optie 3a documentatie

In het document `koppelmij_option_3a.md` staat op regel 115-125:

> **DVA als SMART on FHIR Authorization Server (niet OIDC)**
>
> **Belangrijk onderscheid:**
> - DVA is een SMART on FHIR authorization server, niet een OpenID Connect provider
> - Reden: DVA verificeert de gebruiker via browser sessie en eventueel DigID, maar geeft geen id_token uit
> - Gevolg: Module gebruikt `fhirUser` scope in plaats van `openid` scope

**Deze analyse toont aan dat deze keuze heroverwogen moet worden:**

De redenering in Optie 3a was:
- Vereenvoudiging van DVA implementatie
- Vermijden van volledige OIDC implementatie
- `fhirUser` geeft voldoende informatie

**Maar de analyse in dit document toont:**
- Meervoudige toegang vereist consistente gebruikersidentificatie
- `fhirUser` alleen is onvoldoende voor identificatie over verschillende contexten
- DVA moet wel Identity Provider zijn voor module launches
- Id_token met `sub` claim is noodzakelijk

## Mogelijke oplossingsrichtingen

### Optie A: DVA als volledige Identity Provider

**DVA implementeert volledige OpenID Connect:**
- DVA geeft id_tokens uit met `sub` claim
- Module gebruikt `scope=launch openid fhirUser patient/*.read`
- DVA authenticeert gebruiker (bijv. via DigiD) bij module launch
- Consistent met Koppeltaal aanpak

**Voordelen:**
- Volledige gebruikersidentificatie mogelijk
- Consistent over verschillende toegangswegen
- Standaard OpenID Connect implementatie

**Nadelen:**
- DVA moet volledige OIDC provider zijn
- Complexere implementatie dan alleen authorization
- Key management voor id_token signing

### Optie B: Federatieve identiteit

**PGO blijft Identity Provider, DVA federeert:**
- PGO authenticeert gebruiker en geeft id_token
- DVA ontvangt id_token van PGO (via token exchange of claims)
- DVA geeft eigen id_token uit met zelfde `sub` (of gemapped)
- Module ontvangt id_token van DVA

**Voordelen:**
- PGO behoudt IdP rol
- DVA hoeft niet primair te authenticeren
- Delegatie van identity verantwoordelijkheid

**Nadelen:**
- Complexe federatie mechanisme
- Trust relatie tussen PGO en DVA nodig
- Mapping van identiteiten tussen systemen

### Optie C: `sub` in access_token claims (zonder volledige OIDC)

**DVA geeft geen id_token, maar `sub` in access_token:**
- Access_token is JWT met `sub` claim
- Module gebruikt `fhirUser` scope (geen `openid`)
- Module kan `sub` uit access_token JWT halen
- Vereenvoudigde aanpak

**Voordelen:**
- Geen volledige OIDC implementatie nodig
- `sub` wel beschikbaar voor identificatie
- Eenvoudiger dan volledig IdP

**Nadelen:**
- Non-standard gebruik van access_token
- Access_token kan opaque token zijn (niet altijd JWT)
- Security concerns: access_token heeft andere levensduur/scope dan id_token

### Optie D: Context-specifieke identifier in token response

**DVA geeft custom parameter in token response:**
- Bijvoorbeeld: `"user_identifier": "pseudonym-abc123"`
- Module gebruikt deze identifier voor sessie management
- Geen id_token, geen OIDC

**Voordelen:**
- Flexibel, eenvoudig te implementeren
- DVA hoeft geen IdP te zijn
- Voldoet aan minimum vereiste

**Nadelen:**
- Non-standard extensie van OAuth 2.0
- Geen cryptografische garantie (niet ondertekend zoals id_token)
- Modules moeten deze custom parameter ondersteunen

## Aanbeveling

### Voorkeur: Optie A (DVA als volledige Identity Provider)

**Rationale:**
1. **Standaard compliance**: OpenID Connect is breed geaccepteerde standaard
2. **Interoperabiliteit**: Consistent met Koppeltaal en andere systemen
3. **Security**: Id_token biedt cryptografische garantie van identiteit
4. **Toekomstbestendig**: Volledige OIDC ondersteunt toekomstige use cases
5. **Module perspectief**: Modules kunnen uniforme flow gebruiken (geen verschil met Koppeltaal)

**Implementatie:**
- DVA implementeert OpenID Connect provider functionaliteit
- Module launches gebruiken `scope=launch openid fhirUser patient/*.read`
- DVA geeft id_token uit met stabiele `sub` claim
- `sub` is pseudoniem (niet BSN) voor privacy

**Migratiepad:**
- Update Optie 3a documentatie om `openid` scope te vereisen
- DVA implementeert id_token uitgave
- Module leveranciers updaten scope requests (indien nodig)

### Alternatief: Optie C (sub in access_token JWT)

Als volledige OIDC implementatie niet haalbaar is:
- DVA geeft access_token uit als JWT (niet opaque)
- JWT bevat `sub` claim
- Modules kunnen `sub` extraheren uit access_token
- Documenteer dit als KoppelMij-specifieke extensie

**Trade-off:**
- Eenvoudiger te implementeren
- Maar: non-standard en minder security garanties

## Impact op bestaande documentatie

### Updates nodig in `koppelmij_option_3a.md`

Sectie "DVA als SMART on FHIR Authorization Server (niet OIDC)" moet worden herzien:

**Oud:**
> DVA is een SMART on FHIR authorization server, niet een OpenID Connect provider
> Module gebruikt `fhirUser` scope in plaats van `openid` scope

**Nieuw:**
> DVA is zowel een SMART on FHIR authorization server als een OpenID Connect provider
> Module gebruikt `openid fhirUser` scope voor volledige gebruikersidentificatie
> Id_token bevat `sub` claim met pseudoniem voor consistente identificatie over toegangswegen

### Scopes aanpassen

**Oud (regel 78-82):**
```
scope=launch+fhirUser+patient/*.read
```

**Nieuw:**
```
scope=launch+openid+fhirUser+patient/*.read
```

### Token response aanpassen

**Toevoegen aan token response (regel 95-102):**
```json
{
  "access_token": "...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "id_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "patient": "Patient/123",
  "fhirUser": "Patient/123"
}
```

## Conclusie

De vereiste van **meervoudige toegang** tot modules (via PGO én via portalen) heeft een fundamentele implicatie:

> **De DVA moet een Identity Provider zijn in de context van module launches.**

**Eenvoudig gesteld:** Omdat de module ook via andere manieren te benaderen is, moet de module een geautoriseerde gebruiker hebben in de context van een PGO (KoppelMij).

Dit is in contrast met de DVA rol bij het verzamelen van taken, waar DVA alleen een authorization server is. Deze dubbele rol is noodzakelijk om:
1. Consistente gebruikersidentificatie over verschillende toegangswegen te garanderen
2. Modules in staat te stellen dezelfde gebruiker te herkennen
3. Continuïteit van zorg te waarborgen

### Parallel met Koppeltaal

Deze conclusie komt exact overeen met de rationale van Koppeltaal (TOP-KT-007):

**Koppeltaal's bevinding:**
> "HTI is daarom, zonder extra identificatie van de gebruiker, onvoldoende beveiligd om toegang te verlenen tot persoonlijke en/of medische gegevens."

**KoppelMij's bevinding:**
> Token Exchange alleen (zonder id_token) is onvoldoende om dezelfde gebruiker te herkennen over verschillende toegangswegen.

**Koppeltaal's oplossing:**
- HTI token voor context + SMART on FHIR met `openid fhirUser` voor gebruikersidentificatie
- Authorization service is Identity Provider die id_token uitgeeft
- Id_token met `sub` claim voor consistente gebruikersidentificatie

**KoppelMij's vereiste oplossing:**
- Token Exchange voor context + SMART on FHIR met `openid fhirUser` voor gebruikersidentificatie
- DVA is Identity Provider die id_token uitgeeft
- Id_token met `sub` claim voor consistente gebruikersidentificatie

**Belangrijkste les van Koppeltaal:**
> "Omdat in koppeltaal vooralsnog de gebruiker altijd onderdeel is van de launch, is de scope altijd `launch openid fhirUser`."

Dit geldt evenzeer voor KoppelMij: modules verwerken persoons- en/of medische gegevens, dus gebruikersidentificatie via id_token is essentieel.

### Aanbeveling

**De aanbeveling is om Optie A te volgen**: DVA implementeert volledige OpenID Connect provider functionaliteit, en modules gebruiken `openid fhirUser` scope bij launches. Dit is de meest standaard-conforme en toekomstbestendige oplossing.

**Rationale:**
1. **Consistent met Koppeltaal**: Dezelfde benadering die Koppeltaal heeft gekozen na security analyse
2. **Meervoudige toegang**: Enige manier om gebruiker te herkennen over PGO en portaal launches
3. **Standaard compliance**: Volledig OpenID Connect, geen custom extensies
4. **Module perspectief**: Modules kunnen uniforme flow gebruiken voor Koppeltaal én KoppelMij
5. **Security**: Id_token biedt cryptografische garantie van gebruikersidentiteit

De keuze in Optie 3a om geen `openid` scope te gebruiken moet worden heroverwogen op basis van deze analyse.

### Referenties

- Koppeltaal TOP-KT-007: Koppeltaal Launch (versie 2.0.5, 4 april 2025)
- SMART App Launch Framework v2.1.0: https://hl7.org/fhir/smart-app-launch/STU2.1/
- OpenID Connect Core 1.0: https://openid.net/specs/openid-connect-core-1_0.html
