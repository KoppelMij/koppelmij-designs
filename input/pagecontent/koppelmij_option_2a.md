
Het probleem wat we oplossen is het feit dat in het launch proces de browser geauthenticeerd moet worden. Indien we dit niet doen, is het stelen van de launch request (POST of GET) een onacceptabel risico.

**In deze optie fungeert het PGO als een SMART on FHIR resource service en gebruikt de bestaande PGO login sessie voor browser authenticatie.** De module doorloopt een standaard SMART on FHIR app launch flow met het PGO, waarbij de PGO sessie wordt gevalideerd in de `/authorize` stap. **Voor resource toegang gebruikt het PGO Token Exchange (RFC 8693) om namens de module een delegation token op te halen bij de DVA, waarbij de module zich authenticeert via RFC 7523 en dit token als actor_token wordt meegegeven.**

Deze optie beschrijft een architectuur waarbij **het PGO een dual-role vervult: enerzijds als SMART on FHIR authorization server voor de module, anderzijds als client voor de DVA**. De browser authenticatie vindt plaats via de PGO sessie, en resource toegang wordt gefaciliteerd door Token Exchange. Op hoog niveau:

* Het PGO doet het verzamelen en krijgt een access_token van de DVA
* Het PGO fungeert als SMART on FHIR authorization server voor modules
* De module start een SMART on FHIR flow met het PGO als authorization server
  * **Browser authenticatie gebeurt via de bestaande PGO sessie in de `/authorize` stap**
  * **Module authenticeert zich via RFC 7523 (JWT Bearer assertion) in de `/token` stap**
  * **PGO doet Token Exchange met DVA tijdens de `/token` stap**
* Module krijgt access_token van PGO en kan direct DVA resources benaderen

**Voordelen van deze PGO Authorization Server aanpak:**
- **Hergebruik van PGO sessie**: Geen extra authenticatie stappen nodig voor browser
- **Standaard SMART on FHIR**: Module gebruikt bekende SMART launch flow
- **Delegation model**: PGO handelt namens module met expliciete actor context
- **RFC compliance**: Gebruikt RFC 8693 (Token Exchange) en RFC 7523 (JWT Bearer)
- **Veiligheid**: Browser authenticatie via vertrouwde PGO omgeving
- **DPoP ondersteuning**: Verplichte sender-constrained tokens via RFC 9449
- **Directe toegang**: Module communiceert direct met DVA FHIR service

{::nomarkdown}
{% include koppelmij_option_2a_short.svg %}
{:/}


### Hoofdstappen van het proces

#### 1. Initiële PGO login
De gebruiker logt in bij zijn Persoonlijke Gezondheidsomgeving (PGO)
PGO maakt een sessie-status aan en bindt deze aan de PGO-sessie
**PGO configureert zich als SMART on FHIR authorization server**
Dit vormt het startpunt voor toegang tot digitale interventies

#### 2. Verzamelen van gegevens
PGO vraagt DVA (Dienstverlener Aanbieder) om gegevens te verzamelen
DVA laat gebruiker inloggen via DigID voor authenticatie
Na succesvolle authenticatie krijgt DVA toegang en geeft een access_token terug aan PGO
PGO gebruikt dit token om FHIR-taken op te halen van DVA
**PGO slaat DVA access_token op voor latere Token Exchange operaties**
Opmerking: Dit is een OIDC (OpenID Connect) flow tussen PGO en DVA

#### 3. Module launch naar PGO
Gebruiker klikt op "start module" in PGO
**PGO genereert eigen launch token en stuurt gebruiker door naar module**
**PGO doet 302 redirect naar module met launch parameter:**
- **GET `{MODULE_URL}/launch?launch={launch_token}&iss={PGO_FHIR_BASE_URL}`**

#### 4. SMART on FHIR Authorization Flow
**4a. `/authorize` stap (front-channel):**
- **Module redirects browser naar PGO `/authorize` endpoint met launch parameter**
- **GET `{PGO_URL}/authorize?response_type=code&client_id={module_id}&redirect_uri={module_redirect}&launch={launch_token}&state={module_state}`**
- **PGO valideert bestaande browser sessie (geen nieuwe login nodig)**
- **PGO correleert launch_token met PGO sessie**
- **Na validatie: redirect naar module met authorization code**

**4b. `/token` stap (back-channel):**
- **Module doet `/token` request naar PGO met authorization code**
- **Module authenticeert zich via RFC 7523 JWT Bearer assertion met verplichte `cnf` claim voor DPoP**
- **PGO voert tegelijkertijd Token Exchange uit met DVA:**
  - **grant_type=urn:ietf:params:oauth:grant-type:token-exchange**
  - **subject_token=DVA_access_token (uit stap 2)**
  - **actor_token=module_JWT_assertion (uit RFC 7523 authenticatie, bevat cnf claim)**
  - **requested_token_type=urn:ietf:params:oauth:token-type:access_token**
- **DVA extraheert cnf claim uit actor_token JWT voor DPoP key binding**
- **DVA genereert DPoP delegation token met module als actor context**
- **PGO geeft module een DPoP access_token (gebaseerd op delegation token) en DVA FHIR endpoint informatie**

#### 5. Module functioneren
**Module gebruikt DPoP access_token voor directe FHIR requests naar DVA**
**Module communiceert rechtstreeks met DVA FHIR service**
**Browser blijft geauthenticeerd via originele PGO sessie**
**Module moet DPoP proof meesturen bij elk direct DVA API request**
Module kan functioneren met DVA resources via directe DVA interactie

### Technische flow details

**Launch stap:**
- Module endpoint: `{MODULE_URL}/launch`
- Parameters: `launch={launch_token}&iss={PGO_FHIR_BASE_URL}`
- Method: 302 redirect of FORM_POST_REDIRECT
- Launch token: Opaque waarde gegenereerd door PGO, gekoppeld aan PGO sessie

**SMART on FHIR tussen Module en PGO:**
- Authorization endpoint: `{PGO_URL}/authorize`
- Token endpoint: `{PGO_URL}/token`
- **FHIR endpoint: Verwijst naar `{DVA_URL}/fhir` (module gaat direct naar DVA)**
- Launch parameter: Gebruikt in `/authorize` voor sessie correlatie
- Module gebruikt RFC 7523 voor client authenticatie in `/token` stap
- **DPoP verplicht: Module moet `cnf` claim in JWT client assertion opnemen**

**Token Response Specificatie:**
- **Het token response van de SMART on FHIR `/token` request bevat een `aud` veld met de DVA FHIR resource service URL**
- **Het `aud` veld bevat de waarde `{DVA_URL}/fhir` om de beoogde audience van het token aan te geven**
- **Dit is een extra veld buiten de standaard SMART on FHIR en OIDC specificaties**
- **Voorbeeld token response:**
  ```json
  {
    "access_token": "...",
    "token_type": "DPoP",
    "expires_in": 3600,
    "scope": "...",
    "aud": "{DVA_URL}/fhir"
  }
  ```

**Token Exchange tussen PGO en DVA (tijdens PGO `/token` stap):**
- Exchange endpoint: `{DVA_URL}/token`
- Subject token: DVA access_token van PGO (uit verzamelen fase)
- Actor token: Module JWT assertion (uit RFC 7523 authenticatie, bevat cnf claim)
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

{::nomarkdown}
{% include koppelmij_option_2a.svg %}
{:/}
