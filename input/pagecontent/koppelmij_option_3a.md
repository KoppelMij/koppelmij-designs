
<img src="overview_optie_3a.png" alt="Optie 3 overview" style="width: 100%; float: none;"/>

Het probleem wat we oplossen is het feit dat in het launch proces de browser geauthenticeerd moet worden. Indien we dit niet doen, is het stelen van de launch request (POST of GET) een onacceptabel risico.

**In deze optie gebruikt het PGO Token Exchange (RFC 8693) om een launch_token op te halen bij de DVA, waarna een launch wordt gedaan naar de module met de DVA FHIR server als audience. De module start vervolgens een SMART on FHIR flow met de DVA, waarbij de DVA de gebruiker (niet alleen de browser sessie) opnieuw identificeert voor extra zekerheid.**

Deze optie beschrijft een architectuur waarbij **het PGO eerst een launch_token verkrijgt via Token Exchange, waarna de module een volledige SMART on FHIR flow doorloopt met gebruikersidentificatie bij de DVA**. De combinatie van launch_token en gebruikersidentificatie biedt dubbele beveiliging. Op hoog niveau:

* Het PGO doet het verzamelen en krijgt een access_token van de DVA
* Voor module launch: PGO gebruikt Token Exchange om een launch_token te verkrijgen
* PGO stuurt gebruiker naar module met launch_token en DVA als audience
* Module start SMART on FHIR flow met DVA
* **DVA kan de gebruiker opnieuw identificeren (niet alleen browser sessie)**
* Module krijgt access_token van DVA voor directe resource toegang

**Voordelen van deze Token Exchange Launch Token aanpak:**
- **Dubbele beveiliging**: Zowel launch_token als gebruikersidentificatie
- **Standaard SMART on FHIR**: Module gebruikt bekende SMART launch flow met DVA
- **Token Exchange compliance**: Gebruikt RFC 8693 voor launch_token verkrijging
- **Gebruikerszekerheid**: DVA kan gebruiker opnieuw identificeren voor gevoelige modules
- **Directe toegang**: Module communiceert direct met DVA FHIR service
- **Flexibiliteit**: DVA kan verschillende identificatiemethoden gebruiken
- **Audit trail**: Volledige logging van zowel launch_token als gebruikersidentificatie

{::nomarkdown}
{% include koppelmij_option_3a_short.svg %}
{:/}

### Hoofdstappen van het proces

#### 1. Initiële PGO login
De gebruiker logt in bij zijn Persoonlijke Gezondheidsomgeving (PGO)
PGO maakt een sessie-status aan en bindt deze aan de PGO-sessie
Dit vormt het startpunt voor toegang tot digitale interventies

#### 2. Verzamelen van gegevens
PGO vraagt DVA (Dienstverlener Aanbieder) om gegevens te verzamelen
DVA laat gebruiker inloggen via DigID voor authenticatie
Na succesvolle authenticatie krijgt DVA toegang en geeft een access_token terug aan PGO
PGO gebruikt dit token om FHIR-taken op te halen van DVA
**PGO slaat DVA access_token op voor Token Exchange operaties**
Opmerking: Dit is een OIDC (OpenID Connect) flow tussen PGO en DVA

#### 3. Launch token verkrijging via Token Exchange
Gebruiker klikt op "start module" in PGO
**PGO voert Token Exchange uit met DVA om een launch_token te verkrijgen**
**PGO stuurt Token Exchange request naar DVA:**
- **grant_type=urn:ietf:params:oauth:grant-type:token-exchange**
- **subject_token=DVA_access_token (uit stap 2)**
- **requested_token_type=urn:ietf:params:oauth:token-type:access_token**
- **audience={DVA_FHIR_URL}**
- **resource={ResourceType}/{id} (één of meer FHIR resources, exclusief Patient)**
**DVA valideert resource toegang en genereert een launch_token**
**Launch_token bevat gevalideerde resource context en is tijdelijk geldig**

#### 4. Optionele step-up authenticatie (indien vereist door DVA)
**Wanneer DVA extra verificatie nodig acht:**
- **DVA kan step-up error retourneren** bij Token Exchange request
- **Error response** geeft aan dat aanvullende gebruikersidentificatie vereist is
- **PGO start step-up OIDC flow** met DVA voor gebruikersidentificatie/toestemming
- **Gebruiker doorloopt authenticatie** bij DVA (bijvoorbeeld DigID)
- **Na succesvolle step-up:** PGO herhaalt Token Exchange request
- **DVA accepteert request** met verhoogde authenticatie context
- **Use case:** Voor gevoelige modules of specifieke gegevenstoegang
- **Toekomstbestendig:** Optionele feature voor toekomstige scenario's

#### 5. Module launch naar DVA
**PGO stuurt gebruiker door naar module met launch_token:**
- **GET `{MODULE_URL}/launch?launch={launch_token}&iss={DVA_FHIR_BASE_URL}`**
**Module valideert launch_token en extraheert DVA informatie**
**Audience is de DVA FHIR server, niet het PGO**

#### 6. SMART on FHIR Authorization Flow met Gebruikersidentificatie
**6a. `/authorize` stap (front-channel):**
- **Module redirects browser naar DVA `/authorize` endpoint met launch parameter**
- **GET `{DVA_URL}/authorize?response_type=code&client_id={module_id}&redirect_uri={module_redirect}&launch={launch_token}&state={module_state}&scope=launch+fhirUser+patient/*.read`**
- **Belangrijke scopes:**
  - **`launch`**: Vereist voor SMART on FHIR launch flow met context
  - **`fhirUser`**: Om de gebruikersidentiteit te krijgen als FHIR resource referentie
  - **GEEN `openid` scope**: DVA is geen OIDC provider (geeft geen id_token uit)
  - **Resource scopes**: Zoals `patient/*.read` voor toegang tot patient resources
- **DVA valideert launch_token en correleert met originele access_token**
- **DVA start gebruikersidentificatie via DigID (niet alleen browser sessie)**
- **Gebruiker logt opnieuw in via DigID voor verificatie**
- **DVA toont toestemmingsscherm voor gegevensdeling met specifieke module**
- **Na succesvolle identificatie en toestemming: redirect naar module met authorization code**

**6b. `/token` stap (back-channel):**
- **Module doet `/token` request naar DVA met authorization code**
- **Module authenticeert zich via client credentials**
- **DVA valideert authorization code en gebruikersidentificatie**
- **DVA genereert access_token voor directe FHIR toegang**
- **Token response bevat:**
  - **`access_token`**: Voor toegang tot FHIR resources
  - **`token_type`**: "Bearer"
  - **`expires_in`**: Geldigheid van het token
  - **`patient`**: Patient ID uit de launch context
  - **`fhirUser`**: FHIR referentie naar de gebruiker (bijv. "Practitioner/123")
  - **Andere context parameters**: Zoals `encounter` indien van toepassing
  - **GEEN `id_token`**: DVA is geen OIDC provider, wel SMART on FHIR authorization server

#### 7. Module functioneren
**Module gebruikt access_token voor directe FHIR requests naar DVA**
**Module communiceert rechtstreeks met DVA FHIR service**
**Volledige audit trail van launch_token tot gebruikersidentificatie**
Module kan functioneren met DVA resources via geauthenticeerde toegang

### Technische flow details

#### DVA als SMART on FHIR Authorization Server (niet OIDC)

**Belangrijk onderscheid:**
- **DVA is een SMART on FHIR authorization server**, niet een OpenID Connect provider
- **Reden**: DVA verificeert de gebruiker via browser sessie en eventueel DigID, maar geeft geen id_token uit
- **Gevolg**: Module gebruikt `fhirUser` scope in plaats van `openid` scope
- **Voordeel**: DVA hoeft geen volledige OIDC implementatie te hebben
- **Gebruikersidentiteit**: Wordt doorgegeven als FHIR resource referentie via `fhirUser` in token response

**Waarom geen `openid` scope:**
- `openid` scope vereist dat de server een id_token uitgeeft (JWT met gebruikersclaims)
- DVA hoeft geen id_token te genereren omdat gebruikersidentiteit via FHIR wordt gecommuniceerd
- De `fhirUser` scope geeft voldoende informatie voor de module om de gebruiker te identificeren
- Dit vereenvoudigt de DVA implementatie terwijl volledige functionaliteit behouden blijft

**Token Exchange voor launch_token:**
- Exchange endpoint: `{DVA_URL}/token`
- Subject token: DVA access_token van PGO (uit verzamelen fase)
- Audience: `{DVA_FHIR_URL}` (niet het PGO)
- Resource parameters: `resource={ResourceType}/{id}` (meerdere mogelijk)
- Voorbeeld: `resource=Task/456&resource=Observation/789&resource=CarePlan/101`
- Resultaat: Launch_token met gevalideerde resource context
- Launch_token format: Opaque waarde of JWT met resource context

**Step-up authenticatie mogelijkheid:**
- **DVA kan step-up vereisen**: Bij Token Exchange request kan DVA een specifieke error code retourneren die een "step-up" aangeeft
- **Step-up mechanisme**: DVA vereist aanvullende gebruikersidentificatie of toestemming via OIDC flow
- **Use case**: DVA wil gebruiker identificeren of toestemming verkrijgen VOORDAT launch wordt gestart
- **Error response**: Specifieke error code die aangeeft dat PGO een step-up OIDC flow moet doorlopen
- **PGO actie**: Start step-up OIDC flow met DVA voor gebruikersidentificatie/toestemming
- **Na succesvolle step-up**: PGO herhaalt Token Exchange request, nu met verhoogde authenticatie
- **Toekomstbestendig**: Step-up feature voor toekomstige scenario's, niet direct vereist
- **Vergelijking met Optie 1**: Bij step-up lijkt het op Optie 1 flow, maar zonder cookie vereiste

**Launch stap:**
- Module endpoint: `{MODULE_URL}/launch`
- Parameters: `launch={launch_token}&iss={DVA_FHIR_BASE_URL}`
- Method: 302 redirect of FORM_POST_REDIRECT
- Launch_token: Gegenereerd door DVA via Token Exchange, bevat module context
- **Audience: DVA FHIR server (niet PGO)**

**SMART on FHIR tussen Module en DVA:**
- Authorization endpoint: `{DVA_URL}/authorize`
- Token endpoint: `{DVA_URL}/token`
- FHIR endpoint: `{DVA_URL}/fhir`
- Launch parameter: Launch_token gebruikt voor context correlatie
- Module gebruikt client credentials voor authenticatie in `/token` stap
- **Gebruikersidentificatie: DVA identificeert gebruiker opnieuw**

**Gebruikersidentificatie opties:**
- **DigID verificatie**: Opnieuw inloggen via DigID voor gebruikersidentificatie

**Launch_token eigenschappen:**
- **Korte levensduur**: Typisch 5-15 minuten om misbruik te voorkomen
- **Eenmalig gebruik**: Token wordt geïnvalideerd na succesvolle SMART flow
- **Context informatie**: Bevat module ID, gebruiker context, scope informatie
- **Gebonden aan DVA**: Kan alleen door DVA worden gevalideerd
- **Audience verificatie**: Module moet DVA als audience herkennen

**Gebruikersidentificatie flow:**
- Launch_token correlatie: DVA koppelt launch_token aan originele gebruiker
- Identificatiemethode selectie: DVA kiest methode op basis van module/risico
- Gebruikersverificatie: Actieve verificatie van gebruikersidentiteit
- Toestemmingsvalidatie: Expliciete toestemming voor module toegang
- Authorization code generatie: Na succesvolle identificatie en toestemming

**Veiligheidsaspecten:**
- **Dubbele verificatie**: Launch_token + gebruikersidentificatie
- **Tijdelijke tokens**: Korte geldigheid van launch_token
- **Directe DVA communicatie**: Geen PGO tussenkomst bij FHIR calls
- **Audit logging**: Volledige trace van launch tot resource toegang
- **Gebruikerscontrole**: Actieve verificatie per module launch
- **Context binding**: Launch_token gekoppeld aan specifieke module en gebruiker

**Voordelen van gebruikersidentificatie:**
- **Extra zekerheid**: Bevestiging van gebruikersidentiteit
- **Compliance**: Voldoet aan strenge authenticatie-eisen
- **Fraude preventie**: Moeilijker te misbruiken dan alleen browser sessies
- **Granulaire controle**: Per module verschillende identificatie-eisen
- **Gebruikersvertrouwen**: Transparante en veilige toegang
- **Regulatory compliance**: Geschikt voor gereguleerde omgevingen

### Context meegeven in Token Exchange

Voor het meegeven van de juiste context (FHIR resources) tijdens de Token Exchange is gekozen voor het gebruik van resource parameters als extra parameters:

**Gekozen oplossing: Resource parameters**
- **Implementatie**: FHIR resource identifiers worden meegegeven als extra parameters in de Token Exchange request
- **Parameter naam**: `resource` (kan meerdere keren voorkomen voor multiple resources)
- **Format**: `resource=<ResourceType>/<id>` (bijv. `resource=Task/456&resource=Observation/789`)
- **Validatie**: DVA valideert toegang tot opgegeven resources en neemt deze op in launch_token

**Voordelen van deze aanpak:**
- Expliciet en duidelijk welke resources nodig zijn
- Eenvoudig te implementeren en te valideren
- Flexibel: ondersteunt meerdere resources
- Compatible met bestaande OAuth2/Token Exchange infrastructuur

**Implementatie details:**
- Token Exchange request bevat één of meer `resource` parameters
- DVA controleert of PGO toegang heeft tot opgegeven resources
- Launch_token bevat gevalideerde resource context
- Module ontvangt alleen toegang tot expliciet opgegeven resources

{::nomarkdown}
{% include koppelmij_option_3a.svg %}
{:/}
