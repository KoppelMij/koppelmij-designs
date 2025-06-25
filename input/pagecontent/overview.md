Het probleem wat we oplossen is het feit dat in het launch proces de browser geauthenticeerd moet worden. Indien we dit niet doen, is het stelen van de launch request (POST of GET) een onacceptabel risico.

<img src="overview_koppelmij.svg" alt="Koppelmij overview" style="width: 100%; float: none;"/>

## Niveaus van integratie
Ontworpen voor/compatibel met vijf typen modules:
 * Gebruiker start module zonder datadeling zonder aanleiding van de zorgverlener
   * Aangeduid met **L (link)**
   * Geen toestemmingen nodig omdat er geen datadeling is
   * Hieronder vallen ook cases waarbij de module een eigen FHIR server gebruikt of
andere interne databases
   * Voorbeeld: informatiesite, Thuisarts
 * Gebruiker start module zonder datadeling na taak van zorgverlener
   * Aangeduid met **TL (task link)**
   * Geen toestemmingen nodig omdat er geen datadeling is
   * Voorbeeld: informatiefolder met informatie over je behandeling
 * Gebruiker start module met datadeling zonder aanleiding/taak zorgverlener
   * Aangeduid met **S (standalone)**
   * Expliciete gebruikerstoestemming bij de DvA nodig voor data-toegang module
   * Voorbeeld: zelfstandig afspraak maken bij nieuwe zorgorganisatie
 * Gebruiker start een module die data moet delen met de PGO
   * Aangeduid met **PS (PGO-standalone)**
   * Geen toestemming omdat de module onderdeel is van het PGO-domein
   * Voorbeeld: extern ingekochte uitbreiding van mogelijkheden in PGO
 * Gebruiker start module met datadeling na taak van zorgverlener
   * Aangeduid met **T (task)**
   * Geen toestemming omdat de module onderdeel is van het zorgaanbiederdomein
   * Voorbeeld: zelfstandig taak uitvoeren in de behandeling, vragenlijst, zelfrapportage


## Vijf architectuurbenaderingen voor veilige module launches

Voor het veilig starten van modules vanuit een PGO (Persoonlijke Gezondheidsomgeving) naar een DVA (Dienstverlener Aanbieder) zijn vijf verschillende oplossingen ontwikkeld:

### **Optie 1: DVA als Authorization Server met Cookie-gebaseerde Browser Correlatie**
DVA fungeert als SMART on FHIR authorization server waarbij browser authenticatie gebeurt via een cookie die tijdens de data verzamelfase wordt gezet. Het PGO initieert een OIDC flow met de DVA voor browser authenticatie. Voor gebruikers zonder langdurige toestemming wordt de bestaande cookie hergebruikt, terwijl gebruikers met langdurige toestemming opnieuw via DigID moeten inloggen. Deze aanpak biedt flexibele cookie-afhandeling en standaard OIDC compliance.

### **Optie 2a: PGO Authorization Server met PGO Token Exchange**
Het PGO fungeert als SMART on FHIR authorization server en gebruikt de bestaande PGO sessie voor browser authenticatie. De module start een standaard SMART launch flow met het PGO, waarna het PGO tijdens de `/token` stap Token Exchange uitvoert met de DVA om namens de module een delegation token te verkrijgen. Module krijgt directe toegang tot DVA resources via DPoP tokens.

### **Optie 2b: PGO Authorization Server met Module Token Exchange**
Vergelijkbaar met Optie 2a, maar hier voert de module zelf Token Exchange uit met de DVA. Het PGO geeft de module een tijdelijk token waarmee de module rechtstreeks een delegation token bij de DVA kan ophalen. Dit resulteert in de zuiverste implementatie van RFC 8693 omdat er geen tussenpartij namens de module handelt.

### **Optie 3a: Token Exchange voor Launch Token met Gebruikersidentificatie**
Deze optie combineert Token Exchange (RFC 8693) voor het verkrijgen van een launch token met verplichte gebruikersheridentificatie tijdens de SMART on FHIR flow. Het PGO gebruikt de opgeslagen DVA access_token om via Token Exchange een kortdurende launch_token te verkrijgen. Tijdens de module launch moet de gebruiker zich opnieuw identificeren via DigID, wat een dubbele beveiligingslaag biedt. Deze aanpak is bijzonder geschikt voor gevoelige zorgapplicaties vanwege de expliciete gebruikersverificatie per module launch.

### **Optie 3b: DVA-geïnitieerde Module Launch met SMART on FHIR**
In deze optie fungeert de DVA als centrale coordinator voor module launches. Het PGO stuurt de gebruiker naar een DVA launch endpoint, waarna de DVA bepaalt welke module te starten en zelf de SMART on FHIR launch naar de module initieert. De DVA behoudt volledige controle over het authenticatie- en autorisatieproces, waarbij de bestaande DVA-sessie uit de verzamelfase wordt hergebruikt. Deze aanpak vereenvoudigt de PGO-integratie aanzienlijk en biedt centrale controle voor compliance en audit doeleinden.

Alle opties gebruiken moderne OAuth2 extensies zoals Token Exchange (RFC 8693) en DPoP (RFC 9449) om veilige en standards-compliant oplossingen te bieden voor cross-domain module launches in de zorgverlening.

