Het probleem wat we oplossen is het feit dat in het launch proces de browser geauthenticeerd moet worden. Indien we dit niet doen, is het stelen van de launch request (POST of GET) een onacceptabel risico.

<img src="overview_koppelmij.svg" alt="Koppelmij overview" style="width: 100%; float: none;"/>


## Drie architectuurbenaderingen voor veilige module launches

Voor het veilig starten van modules vanuit een PGO (Persoonlijke Gezondheidsomgeving) naar een DVA (Dienstverlener Aanbieder) zijn drie verschillende oplossingen ontwikkeld:

### **Optie 1: DVA OTP met Cookie Correlatie**
DVA fungeert als SMART on FHIR authorization server. Het PGO gebruikt Token Exchange (RFC 8693) om een impersonation token (OTP) te verkrijgen. Browser authenticatie gebeurt door een cookie die tijdens de verzamelfase wordt gezet en later gecorreleerd wordt met het OTP token. Dit biedt een eenvoudige implementatie met standaard SMART on FHIR compliance.

### **Optie 2a: PGO Authorization Server met PGO Token Exchange**
Het PGO fungeert als SMART on FHIR authorization server en gebruikt de bestaande PGO sessie voor browser authenticatie. De module start een standaard SMART launch flow met het PGO, waarna het PGO tijdens de `/token` stap Token Exchange uitvoert met de DVA om namens de module een delegation token te verkrijgen. Module krijgt directe toegang tot DVA resources via DPoP tokens.

### **Optie 2b: PGO Authorization Server met Module Token Exchange**
Vergelijkbaar met Optie 2a, maar hier voert de module zelf Token Exchange uit met de DVA. Het PGO geeft de module een tijdelijk token waarmee de module rechtstreeks een delegation token bij de DVA kan ophalen. Dit resulteert in de zuiverste implementatie van RFC 8693 omdat er geen tussenpartij namens de module handelt.

Alle opties gebruiken moderne OAuth2 extensies zoals Token Exchange (RFC 8693) en DPoP (RFC 9449) om veilige en standards-compliant oplossingen te bieden voor cross-domain module launches in de zorgverlening.

