# Optie 3b: DVA-geïnitieerde Module Launch met SMART on FHIR

Het probleem wat we oplossen is het feit dat in het launch proces de browser geauthenticeerd moet worden. Indien we dit niet doen, is het stelen van de launch request (POST of GET) een onacceptabel risico.

**In deze optie doet het PGO een launch naar de DVA, die vervolgens de module opstart met een SMART on FHIR flow. De DVA fungeert als tussenpartij die de module launch coördineert en beheert, waarbij de DVA volledige controle heeft over het authenticatie- en autorisatieproces.**

Deze optie beschrijft een architectuur waarbij **het PGO de gebruiker naar de DVA stuurt, waarna de DVA zelf de module launch initieert via SMART on FHIR**. De DVA heeft hierdoor maximale controle over het proces. Op hoog niveau:

* Het PGO doet het verzamelen en krijgt een access_token van de DVA
* Voor module launch: PGO stuurt gebruiker naar DVA launch endpoint
* DVA valideert de gebruikerssessie en bepaalt welke module te starten
* DVA initieert SMART on FHIR launch naar de module
* Module doorloopt standaard SMART flow met DVA als authorization server
* Module krijgt access_token van DVA voor directe resource toegang

**Voordelen van deze DVA-geïnitieerde aanpak:**
- **Centrale controle**: DVA beheert het volledige launch proces
- **Vereenvoudigde PGO integratie**: PGO hoeft alleen naar DVA te redirecten
- **Consistente gebruikerservaring**: DVA kan uniforme launch flow aanbieden
- **Module isolatie**: Modules hoeven geen kennis te hebben van PGO
- **Flexibele module selectie**: DVA kan dynamisch bepalen welke module te starten
- **Audit en compliance**: Centrale logging en controle bij DVA
- **Standaard SMART compliance**: Module gebruikt normale SMART launch

{::nomarkdown}
{% include koppelmij_option_3b_short.svg %}
{:/}

## Hoofdstappen van het proces

### 1. Initiële PGO login
De gebruiker logt in bij zijn Persoonlijke Gezondheidsomgeving (PGO)
PGO maakt een sessie-status aan en bindt deze aan de PGO-sessie
Dit vormt het startpunt voor toegang tot digitale interventies

### 2. Verzamelen van gegevens
PGO vraagt DVA (Dienstverlener Aanbieder) om gegevens te verzamelen
DVA laat gebruiker inloggen via DigID voor authenticatie
Na succesvolle authenticatie krijgt DVA toegang en geeft een access_token terug aan PGO
PGO gebruikt dit token om FHIR-taken op te halen van DVA
**PGO bewaart context informatie voor module launch**
Opmerking: Dit is een OIDC (OpenID Connect) flow tussen PGO en DVA

### 3. Launch naar DVA
Gebruiker klikt op "start module" in PGO
**PGO redirect gebruiker naar DVA launch endpoint:**
- **GET `{DVA_URL}/launch-module?module={module_id}&context={launch_context}`**
- **DVA valideert bestaande gebruikerssessie (cookie van stap 2)**
- **Indien geen geldige sessie: DVA start nieuwe DigID authenticatie**
- **DVA bepaalt welke module te starten op basis van context**

### 4. DVA initieert SMART on FHIR launch
**DVA genereert een launch token voor de module**
**DVA redirect gebruiker naar module met SMART launch:**
- **GET `{MODULE_URL}/launch?launch={launch_token}&iss={DVA_FHIR_BASE_URL}`**
- **Launch token bevat module-specifieke context**
- **Module ontvangt DVA als issuer voor SMART flow**

### 5. SMART on FHIR Authorization Flow
**5a. `/authorize` stap (front-channel):**
- **Module redirects browser naar DVA `/authorize` endpoint**
- **GET `{DVA_URL}/authorize?response_type=code&client_id={module_id}&redirect_uri={module_redirect}&launch={launch_token}&state={module_state}`**
- **DVA valideert launch token en gebruikerssessie**
- **DVA toont eventueel toestemmingsscherm**
- **Na goedkeuring: redirect naar module met authorization code**

**5b. `/token` stap (back-channel):**
- **Module doet `/token` request naar DVA met authorization code**
- **Module authenticeert zich via client credentials**
- **DVA genereert access_token voor FHIR toegang**
- **Module ontvangt tokens voor resource toegang**

### 6. Module functioneren
**Module gebruikt access_token voor directe FHIR requests naar DVA**
**DVA beheert en monitort alle module interacties**
**Volledige audit trail van PGO launch tot module toegang**
Module kan functioneren met DVA resources via geauthenticeerde toegang

## Technische flow details

**PGO naar DVA launch:**
- Launch endpoint: `{DVA_URL}/launch-module`
- Parameters: `module={module_id}&context={launch_context}`
- Method: GET redirect of FORM POST
- Sessie validatie: Via cookie uit verzamelfase
- Context: Bevat informatie over gewenste module en gebruikerscontext

**DVA module selectie:**
- Module registry: DVA beheert lijst van beschikbare modules
- Context evaluatie: DVA bepaalt geschikte module op basis van context
- Configuratie: Per module specifieke launch parameters
- Validatie: DVA controleert of gebruiker toegang heeft tot module

**DVA naar Module launch:**
- Launch generatie: DVA creëert unieke launch token
- Launch URL: `{MODULE_URL}/launch?launch={token}&iss={DVA_URL}`
- Token eigenschappen: Korte levensduur, eenmalig gebruik
- Issuer: DVA FHIR base URL voor SMART discovery

**SMART on FHIR tussen Module en DVA:**
- Authorization endpoint: `{DVA_URL}/authorize`
- Token endpoint: `{DVA_URL}/token`
- FHIR endpoint: `{DVA_URL}/fhir`
- Standaard SMART flow: Module volgt normale SMART specificaties
- DVA controle: Volledige controle over autorisatie beslissingen

**Sessie management:**
- **PGO sessie**: Onafhankelijk van DVA en module sessies
- **DVA sessie**: Gedeeld tussen verzamelen en module launch
- **Module sessie**: Onafhankelijk, gebaseerd op SMART tokens
- **Cookie hergebruik**: DVA cookie uit verzamelfase voor SSO

**Veiligheidsaspecten:**
- **Centrale validatie**: DVA valideert alle launch requests
- **Sessie controle**: Hergebruik van geauthenticeerde DVA sessie
- **Module isolatie**: Modules hebben geen directe PGO kennis
- **Audit logging**: Complete trace bij DVA van alle launches
- **Token beveiliging**: Korte levensduur en eenmalig gebruik
- **Standaard compliance**: Volgt SMART on FHIR specificaties

**Voordelen voor implementatie:**
- **Eenvoudige PGO integratie**: Alleen redirect naar DVA nodig
- **Module onafhankelijkheid**: Standaard SMART implementatie
- **Centrale configuratie**: DVA beheert alle module configuraties
- **Flexibele uitbreiding**: Nieuwe modules eenvoudig toe te voegen
- **Consistente ervaring**: DVA controleert gebruikersflow
- **Compliance ready**: Centrale controle voor regelgeving

{::nomarkdown}
{% include koppelmij_option_3b.svg %}
{:/}