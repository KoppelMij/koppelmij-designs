# Optie 2b: PGO als SMART on FHIR Authorization Server met Module Token Exchange

Het probleem wat we oplossen is het feit dat in het launch proces de browser geauthenticeerd moet worden. Indien we dit niet doen, is het stelen van de launch request (POST of GET) een onacceptabel risico.

**In deze optie fungeert het PGO als een SMART on FHIR authorization server en gebruikt de bestaande PGO login sessie voor browser authenticatie.** De module doorloopt een standaard SMART on FHIR app launch flow met het PGO, waarbij de PGO sessie wordt gevalideerd in de `/authorize` stap. **Voor resource toegang krijgt de module een tijdelijk token van het PGO dat vervolgens wordt ingewisseld via Token Exchange (RFC 8693) bij de DVA voor directe toegang tot DVA resources.**

Deze optie beschrijft een architectuur waarbij **het PGO fungeert als SMART on FHIR authorization server voor de module, en de module zelf de Token Exchange uitvoert met de DVA**. De browser authenticatie vindt plaats via de PGO sessie, en resource toegang wordt gefaciliteerd door Token Exchange die door de module wordt uitgevoerd. Op hoog niveau:

* Het PGO doet het verzamelen en krijgt een access_token van de DVA
* Het PGO fungeert als SMART on FHIR authorization server voor modules
* De module start een SMART on FHIR flow met het PGO als authorization server
  * **Browser authenticatie gebeurt via de bestaande PGO sessie in de `/authorize` stap**
  * **Module authenticeert zich via RFC 7523 (JWT Bearer assertion) in de `/token` stap**
  * **PGO geeft module een tijdelijk token dat kan worden ingewisseld bij DVA**
* **Module voert zelf Token Exchange uit met DVA om het tijdelijke token in te wisselen**
* Module krijgt access_token van DVA en kan direct DVA resources benaderen

**Voordelen van deze Module Token Exchange aanpak:**
- **Hergebruik van PGO sessie**: Geen extra authenticatie stappen nodig voor browser
- **Standaard SMART on FHIR**: Module gebruikt bekende SMART launch flow
- **Module controle**: Module heeft volledige controle over Token Exchange timing
- **RFC compliance**: Gebruikt RFC 8693 (Token Exchange) en RFC 7523 (JWT Bearer)
- **Veiligheid**: Browser authenticatie via vertrouwde PGO omgeving
- **DPoP ondersteuning**: Verplichte sender-constrained tokens via RFC 9449
- **Directe toegang**: Module communiceert direct met DVA FHIR service
- **Flexibiliteit**: Module kan kiezen wanneer Token Exchange uit te voeren

{::nomarkdown}
{% include koppelmij_option_2b_short.svg %}
{:/}

## Hoofdstappen van het proces

### 1. Initiële PGO login
De gebruiker logt in bij zijn Persoonlijke Gezondheidsomgeving (PGO)
PGO maakt een sessie-status aan en bindt deze aan de PGO-sessie
**PGO configureert zich als SMART on FHIR authorization server**
Dit vormt het startpunt voor toegang tot digitale interventies

### 2. Verzamelen van gegevens
PGO vraagt DVA (Dienstverlener Aanbieder) om gegevens te verzamelen
DVA laat gebruiker inloggen via DigID voor authenticatie
Na succesvolle authenticatie krijgt DVA toegang en geeft een access_token terug aan PGO
PGO gebruikt dit token om FHIR-taken op te halen van DVA
**PGO slaat DVA access_token op voor Token Exchange operaties**
Opmerking: Dit is een OIDC (OpenID Connect) flow tussen PGO en DVA

### 3. Module launch naar PGO
Gebruiker klikt op "start module" in PGO
**PGO genereert eigen launch token en stuurt gebruiker door naar module**
**PGO doet 302 redirect naar module met launch parameter:**
- **GET `{MODULE_URL}/launch?launch={launch_token}&iss={PGO_FHIR_BASE_URL}`**

### 4. SMART on FHIR Authorization Flow
**4a. `/authorize` stap (front-channel):**
- **Module redirects browser naar PGO `/authorize` endpoint met launch parameter**
- **GET `{PGO_URL}/authorize?response_type=code&client_id={module_id}&redirect_uri={module_redirect}&launch={launch_token}&state={module_state}`**
- **PGO valideert bestaande browser sessie (geen nieuwe login nodig)**
- **PGO correleert launch_token met PGO sessie**
- **Na validatie: redirect naar module met authorization code**

**4b. `/token` stap (back-channel):**
- **Module doet `/token` request naar PGO met authorization code**
- **Module authenticeert zich via RFC 7523 JWT Bearer assertion met verplichte `cnf` claim voor DPoP**
- **PGO genereert een tijdelijk token gebonden aan de PGO access_token voor DVA**
- **PGO geeft module het tijdelijke token en DVA Token Exchange endpoint informatie**

### 5. Module Token Exchange met DVA
**Module voert Token Exchange uit met DVA:**
- **Module doet Token Exchange request naar DVA met tijdelijk token**
- **grant_type=urn:ietf:params:oauth:grant-type:token-exchange**
- **subject_token=tijdelijk_token (van PGO)**
- **actor_token=module_JWT_assertion (met cnf claim)**
- **requested_token_type=urn:ietf:params:oauth:token-type:access_token**
- **DVA valideert tijdelijk token en extraheert cnf claim voor DPoP binding**
- **DVA genereert DPoP delegation token met module als actor context**

### 6. Module functioneren
**Module gebruikt DPoP access_token voor directe FHIR requests naar DVA**
**Module communiceert rechtstreeks met DVA FHIR service**
**Browser blijft geauthenticeerd via originele PGO sessie**
**Module moet DPoP proof meesturen bij elk direct DVA API request**
Module kan functioneren met DVA resources via directe DVA interactie

## Technische flow details

**Launch stap:**
- Module endpoint: `{MODULE_URL}/launch`
- Parameters: `launch={launch_token}&iss={PGO_FHIR_BASE_URL}`
- Method: 302 redirect of FORM_POST_REDIRECT
- Launch token: Opaque waarde gegenereerd door PGO, gekoppeld aan PGO sessie

**SMART on FHIR tussen Module en PGO:**
- Authorization endpoint: `{PGO_URL}/authorize`
- Token endpoint: `{PGO_URL}/token`
- **FHIR endpoint: Verwijst naar `{DVA_URL}/fhir` (module gaat direct naar DVA na Token Exchange)**
- Launch parameter: Gebruikt in `/authorize` voor sessie correlatie
- Module gebruikt RFC 7523 voor client authenticatie in `/token` stap
- **DPoP verplicht: Module moet `cnf` claim in JWT client assertion opnemen**

**PGO Token Response Specificatie:**
- **Het token response van de SMART on FHIR `/token` request bevat een tijdelijk token**
- **Het tijdelijke token is gekoppeld aan de PGO's DVA access_token**
- **Response bevat ook DVA Token Exchange endpoint informatie**
- **Voorbeeld token response:**
  ```json
  {
    "access_token": "temporary_exchange_token_...",
    "token_type": "Bearer",
    "expires_in": 300,
    "token_exchange_endpoint": "{DVA_URL}/token",
    "resource_server": "{DVA_URL}/fhir"
  }
  ```

**Token Exchange tussen Module en DVA (na SMART on FHIR flow):**
- Exchange endpoint: `{DVA_URL}/token`
- Subject token: Tijdelijk token van PGO (uit SMART flow)
- Actor token: Module JWT assertion (met cnf claim)
- **cnf claim extractie: DVA haalt cnf claim uit actor_token JWT voor DPoP key binding**
- Resultaat: DPoP delegation token voor DVA resources
- **DPoP tokens: Altijd gebonden aan module's publieke sleutel via cnf claim uit JWT**

**Directe Module-DVA communicatie:**
- **Module gebruikt DPoP delegation token voor directe requests naar `{DVA_URL}/fhir`**
- **Geen PGO tussenkomst bij FHIR API calls**
- **DVA valideert DPoP delegation token en actor context**
- **DVA valideert DPoP proof bij elke request**

**Browser authenticatie:**
- Launch stap: Browser wordt door PGO naar module gestuurd
- `/authorize` stap: Gebaseerd op bestaande PGO sessie
- Launch token correlatie: PGO koppelt launch_token aan sessie
- Geen extra login stappen voor gebruiker
- Veilige correlatie via PGO session management

**DPoP Token specifieke aspecten:**
- **cnf claim**: Zit in module's JWT client assertion, bevat JWK thumbprint van module's publieke sleutel
- **DPoP proof**: Module moet bij elk direct DVA API request een DPoP proof JWT meesturen
- **Key binding**: Token is cryptografisch gebonden aan module's private key
- **Replay protection**: DPoP proof bevat timestamp en nonce voor replay-resistance

**Tijdelijk Token eigenschappen:**
- **Korte levensduur**: Typisch 5 minuten om misbruik te voorkomen
- **Eenmalig gebruik**: Token wordt geïnvalideerd na succesvolle Token Exchange
- **Gebonden aan PGO context**: Gekoppeld aan originele PGO DVA access_token
- **Opaque format**: Geen JWT om frontend exposure te minimaliseren

{::nomarkdown}
{% include koppelmij_option_2b.svg %}
{:/}