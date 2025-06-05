Hoofdstappen van het proces
1. Initiële PGO login
De gebruiker logt in bij zijn Persoonlijke Gezondheidsomgeving (PGO)
PGO maakt een sessie-status aan en bindt deze aan de PGO-sessie
Dit vormt het startpunt voor toegang tot digitale interventies
2. Verzamelen van gegevens
PGO vraagt DVA (Dienstverlener Aanbieder) om gegevens te verzamelen
DVA laat gebruiker inloggen via DigID voor authenticatie
Na succesvolle authenticatie krijgt DVA toegang en geeft een access_token terug aan PGO
PGO gebruikt dit token om FHIR-taken op te halen van DVA
Belangrijk: Er wordt geen sessie-cookie opgeslagen bij DVA tijdens dit proces
Opmerking: Dit is een OIDC (OpenID Connect) flow
3. Voorbereiding voor module launch
Gebruiker klikt op "start module" in PGO
PGO stuurt gebruiker door naar DVA voor autorisatie voor de eenmalige code (OTP)
DVA zet een tijdelijke cookie en genereert een code + OTP-token
DVA stuurt gebruiker naar PGO met de gegenereerde code
PGO wisselt de code in voor een OTP-token bij DVA (gebruik makend van access_token als client_credentials)
Opmerking: Het OTP-token is een opaque waarde ("gewoon een nummer") en geen JWT, omdat het gebruikt wordt in het frontend-kanaal
Opmerking: Ook dit is een OIDC (OpenID Connect) flow
4. Daadwerkelijke launch naar module
PGO stuurt gebruiker door naar de module met het OTP-token (via 302 redirect of FORM_POST_REDIRECT)
Module stuurt gebruiker terug naar DVA voor finale autorisatie
DVA correleert het OTP-token met de eerder gezette cookie
DVA genereert finale toegangstokens en stuurt gebruiker terug naar module
Module krijgt uiteindelijk een access_token en id_token om te kunnen functioneren
