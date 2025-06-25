# Optie 1: Cookie op het DVA domein met OIDC Launch

**Het nieuwe inzicht is dat browser authenticatie niet gekoppeld hoeft te worden aan een gebruiker login of Identity Provider sessie.** We zetten een cookie enkel en alleen om de browser te correleren tijdens de validatie. **Deze optie gebruikt OIDC voor de launch in plaats van Token Exchange, omdat de verzamelfase bij langdurige toestemming slechts eens in de zes maanden plaatsvindt. Voor gebruikers zonder langdurige toestemming wordt het cookie van de verzamelfase hergebruikt, terwijl gebruikers met langdurige toestemming een nieuwe DigID login doorlopen met cookie-instelling.**

Deze optie beschrijft de werking van het DVA (Dienstverlener Aanbieder) proces waarbij **een cookie wordt gezet tijdens de verzamelen fase en OIDC wordt gebruikt voor de launch**. De cookie behandeling verschilt afhankelijk van of de gebruiker langdurige toestemming heeft gegeven. Op hoog niveau:

* Het PGO doet het verzamelen en krijgt een access_token
  * **DVA zet tijdens deze fase een cookie in de browser**
* Het PGO wil een launch starten en **gebruikt OIDC bij de DVA**
  * **Voor gebruikers ZONDER langdurige toestemming: hergebruik van bestaande cookie**
  * **Voor gebruikers MET langdurige toestemming: nieuwe DigID login met cookie-instelling**
* De PGO doet een launch naar de module
* De module ontvangt een launch en start een OIDC flow
  * **Het cookie wordt gebruikt voor browser correlatie tijdens de OIDC flow**
  * Bij de /token stap wordt het access_token via de backchannel verkregen

{::nomarkdown}
{% include koppelmij_option_1_short.svg %}
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
**DVA zet tijdens dit proces een cookie voor latere browser correlatie**
PGO gebruikt dit token om FHIR-taken op te halen van DVA
**Opmerking: Bij langdurige toestemming vindt deze stap slechts eens per zes maanden plaats**
Opmerking: Dit is een OIDC (OpenID Connect) flow

### 3. Voorbereiding voor module launch
Gebruiker klikt op "start module" in PGO
**PGO start een OIDC flow met DVA voor browser authenticatie**
**Twee scenario's:**

**3a. Gebruiker ZONDER langdurige toestemming:**
- **DVA detecteert bestaande cookie van recente verzamelfase**
- **Geen nieuwe DigID login vereist**
- **Gebruiker geeft toestemming voor het delen van informatie met de specifieke module**
- **Cookie wordt hergebruikt voor browser correlatie**
- **DVA genereert authorization code en stuurt browser terug naar PGO**

**3b. Gebruiker MET langdurige toestemming:**
- **DVA detecteert geen recent cookie (verzamelfase >6 maanden geleden)**
- **Nieuwe DigID login wordt gestart**
- **Na succesvolle DigID authenticatie wordt nieuw cookie gezet**
- **Gebruiker geeft toestemming voor het delen van informatie met de specifieke module**
- **DVA genereert authorization code en stuurt browser terug naar PGO**

**PGO wisselt authorization code in voor tokens via backchannel**
**Opmerking: Dit blijft een OIDC flow in plaats van Token Exchange**

### 4. Daadwerkelijke launch naar module
PGO stuurt gebruiker door naar de module (via 302 redirect of FORM_POST_REDIRECT)
Module stuurt gebruiker terug naar DVA voor finale autorisatie
**DVA correleert browser met het cookie (nieuw of hergebruikt uit stap 3)**
DVA genereert finale toegangstokens en stuurt gebruiker terug naar module
Module krijgt uiteindelijk een access_token en id_token om te kunnen functioneren

## Technische flow details

**Verzamelfase cookie-instelling:**
- Cookie domein: DVA domein
- Cookie doel: Browser correlatie (niet gekoppeld aan gebruikersidentiteit)
- Cookie type: Korte levensduur voor security

**Launch OIDC flow:**
- Authorization endpoint: `{DVA_URL}/authorize`
- Token endpoint: `{DVA_URL}/token`
- Response type: `code` (authorization code flow)
- Browser correlatie: Via bestaand of nieuw cookie

**Cookie strategie per toestemmingstype:**

**Zonder langdurige toestemming:**
- Cookie van recente verzamelfase wordt hergebruikt
- Geen nieuwe DigID login tijdens launch
- Snelle browser correlatie

**Met langdurige toestemming:**
- Verzamelfase kan >6 maanden geleden zijn
- Cookie mogelijk verlopen of afwezig
- Nieuwe DigID login tijdens launch
- Nieuw cookie wordt gezet voor toekomstige launches

**Browser authenticatie flow:**
- Launch stap: Browser wordt door PGO naar DVA gestuurd voor OIDC
- Cookie detectie: DVA controleert aanwezigheid en geldigheid van cookie
- Conditionele login: DigID login alleen bij ontbrekend/verlopen cookie
- **Toestemmingsstap: Gebruiker geeft expliciete toestemming voor het delen van gegevens met de specifieke module**
- Authorization code: Gegenereerd na succesvolle browser correlatie en toestemming
- Token uitwisseling: PGO wisselt code in via backchannel

**Veiligheidsaspecten:**
- Cookie is niet gekoppeld aan gebruikersidentiteit
- Cookie dient uitsluitend voor browser correlatie
- Verschillende cookie strategieën per toestemmingstype
- DigID login alleen wanneer noodzakelijk
- Backchannel token uitwisseling voor veiligheid

**Voordelen van OIDC launch aanpak:**
- **Flexibele cookie behandeling**: Verschillende strategieën per toestemmingstype
- **Efficiëntie**: Hergebruik van cookies waar mogelijk
- **Standaard compliance**: Gebruik van OIDC in plaats van Token Exchange
- **Gebruikerservaring**: Minimale login-stappen voor gebruikers zonder langdurige toestemming
- **Expliciete toestemming**: Duidelijke toestemmingsstap voor gegevensdeling per module
- **Veiligheid**: Browser correlatie zonder gebruikersidentiteit in cookie
- **Schaalbaarheid**: Geschikt voor verschillende toestemmingsmodellen
- **Granulaire controle**: Gebruiker kan per module beslissen over gegevensdeling

{::nomarkdown}
{% include koppelmij_option_1.svg %}
{:/}
