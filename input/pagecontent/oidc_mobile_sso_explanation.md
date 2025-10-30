
### Overzicht

OpenID Connect Native SSO voor Mobiele Apps 1.0 is een specificatie die mobiele apps in staat stelt om authenticatie en identiteit te delen tussen meerdere apps van dezelfde leverancier die op hetzelfde apparaat zijn geïnstalleerd. De specificatie pakt de uitdaging aan om naadloze Single Sign-On (SSO) te bieden tussen mobiele applicaties zonder te vertrouwen op browser sessie cookies, die onbetrouwbaar kunnen zijn op mobiele apparaten.

### Kernprobleem dat het oplost

De specificatie adresseert risico's zoals gebruikers die hun systeembrowser cookies wissen of privé browsen gebruiken op iOS en Android, wat traditionele web-gebaseerde SSO-mechanismen kan verstoren. In plaats daarvan maakt het gebruik van de beveiligde keychain-mechanismen van het mobiele platform (zoals iOS Keychain of Android Account Manager) om de authenticatiestatus te delen tussen apps van dezelfde leverancier.

### Belangrijkste componenten

#### 1. Device Secret (`device_secret`)
Het device secret bevat relevante gegevens voor het apparaat en de huidige gebruikers die met het apparaat zijn geauthenticeerd. Het device secret is volledig ondoorzichtig voor de client en de Authorization Server moet de waarde adequaat beschermen. Dit geheim kan worden gedeeld tussen mobiele apps die toegang hebben tot hetzelfde gedeelde beveiligingsmechanisme.

#### 2. Nieuwe Scope Waarde
De specificatie definieert een nieuwe scope waarde `device_sso` die wordt gebruikt om aan de Authorization Server door te geven dat wanneer de code wordt ingewisseld voor een token, een nieuw device_secret zal worden geretourneerd.

#### 3. Verbeterde ID Token
De specificatie vereist aanvullende claims in de ID token:
- `ds_hash` claim om een functie van het device_secret weer te geven
- Sessie-id die de huidige authenticatiesessie van de gebruiker vertegenwoordigt

### Hoe het werkt

#### Initiële Authenticatie Flow
1. **Eerste App Authenticatie**: Native App #1 voert een standaard OpenID Connect authorization code flow uit
2. **Device Secret Aanvraag**: De app voegt de `device_sso` scope toe aan zijn autorisatieverzoek
3. **Token Exchange**: Na authenticatie wisselt de app de autorisatiecode in voor tokens, waarbij een access token, refresh token, ID token, en cruciaal, een device_secret wordt ontvangen
4. **Veilige Opslag**: De app slaat het device_secret en ID token op in gedeelde apparaatopslag toegankelijk voor andere apps van dezelfde leverancier

#### SSO Flow voor Tweede App
1. **Token Exchange Verzoek**: Native App #2 doet een token exchange verzoek naar het /token endpoint met behulp van het opgeslagen ID token en device_secret
2. **Validatie**: De Authorization Server valideert:
   - Het device_secret is nog steeds geldig
   - De ID token integriteit door de handtekening te valideren
   - De binding tussen het ID token en device_secret door de ds_hash waarde te valideren
   - De sessie-ID in het ID token is nog steeds geldig
3. **Token Uitgifte**: Als validatie slaagt, geeft de server nieuwe tokens uit voor de tweede app

### Technisch Flow Diagram

```
+----------+ +----------+ +-----------+ +------------+
| Native   | | Native   | | System    | | AS         |
| App      | | App      | | Browser   | |            |
| #1       | | #2       | |           | |            |
+----+-----+ +----+-----+ +-----+-----+ +-------+----+
     |            |             |               |
     | [1] Start OpenID Connect AuthN           |
     +----------------------------------------->|
     |            |             |               |
     |            |      [2] /authorize         |
     |            |      +--------------------->|
     |            |             |               |
     |            |      [3] authenticate       |
     |            |      <----------------------+
     |            |             |               |
     |            |      [4] user creds         |
     |            |      +--------------------->|
     |            |             |               |
     |            |      [5] callback           |
     |            |      <----------------------+
     | [6] callback with code    |              |
     <--------------+---------------------------+
     |            |             |               |
     | [7] exchange code for tokens             |
     +----------------------------------------->|
     |            |             |               |
     | [8] tokens (including device_secret)     |
     <-----------------------------------------+|
     |            |             |               |
     |     Store device_secret and id_token     |
     |     in shared device storage             |
     |            |             |               |
     |            | [9] token exchange          |
     |            +---------------------------->|
     |            |             |               |
     |            | [10] refresh, access tokens |
     |            <-----------------------------+
     |            |             |               |
```

### Token Exchange Profiel

De specificatie profileert de OAuth2 Token Exchange (RFC 8693) specificatie, waarbij specifieke parameters voor het token exchange verzoek worden gedefinieerd:

- **subject_token**: Het ID token van de eerste app
- **subject_token_type**: `urn:ietf:params:oauth:token-type:id_token`
- **actor_token**: Het device_secret
- **actor_token_type**: `urn:openid:params:token-type:device-secret`

#### Voorbeeld Token Exchange Verzoek

```http
POST /token HTTP/1.1
Host: as.example.com

client_id=cid_235saw4r4
&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Atoken-exchange
&audience=https%3A%3F%3Flogin.example.net
&subject_token=<id_token>
&subject_token_type=urn%3Aietf%3Aparams%3Aoauth%3Atoken-type%3Aid-token
&actor_token=95twdf3w4y6wvftw35634t
&actor_token_type=urn%3Aopenid%3Aparams%3Atoken-type%3Adevice-secret
```

#### Voorbeeld Token Exchange Respons

```json
{
  "access_token": "2YotnFZFEjr1zCsicMWpAA",
  "issued_token_type": "urn:ietf:params:oauth:token-type:access_token",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "tGzv3JOkF0XG5Qx2TlKWIA",
  "id_token": "<id_token>",
  "device_secret": "casdfgarfgasdfg"
}
```

### Beveiligingsoverwegingen

De specificatie bevat verschillende belangrijke beveiligingsmaatregelen:

#### 1. Apparaat Binding
Implementaties moeten hun best doen om het device_secret aan het apparaatexemplaar te binden om exfiltratie van het device_secret en id_token van het apparaat te voorkomen.

#### 2. Client Autorisatie
De Authorization Server moet een lijst bijhouden van client_ids die gebruikersauthenticaties kunnen delen. De server kan de 'aud' claim uit het id_token en het client_id uit het token verzoek nemen en ervoor zorgen dat beide client_ids gebruikersauthenticaties mogen delen.

#### 3. Toestemming Validatie
De server moet verifiëren dat gevraagde scopes geen expliciete gebruikerstoestemming vereisen, waarbij een `interaction_required` fout wordt geretourneerd als ze dat wel doen.

#### 4. Device Secret Bescherming
Er moet voldoende zorg worden besteed aan het beschermen van het device_secret. Het device secret moet worden versleuteld door de Authorization Service en periodiek worden vernieuwd via de mechanismen beschreven in de specificatie.

#### 5. Sessie Validatie
De Authorization Server moet verifiëren dat de sessie-ID in het ID token (sid claim) nog steeds geldig is. Als de sessie niet langer geldig is, moet de server een fout van `invalid_grant` retourneren.

### Discovery Metadata

De specificatie breidt OpenID Connect Discovery Metadata uit en definieert het volgende:

- **native_sso_supported**: Een boolean waarde van `true` die aangeeft dat de Authorization Server deze OpenID Connect specificatie ondersteunt.

### Huidige Status en Implementatie

- **Specificatie Status**: De specificatie kan als stabiel worden beschouwd voor implementatie en zal naar verwachting definitief worden verklaard in 2025 of 2026
- **Implementer's Draft**: Het werd goedgekeurd als een OpenID Implementer's Draft in december 2022, waardoor intellectuele eigendomsbescherming wordt geboden voor implementeerders
- **Real-world Ondersteuning**: Bedrijven zoals Okta ondersteunen deze specificatie al, waarbij token-gebaseerde SSO tussen native apps wordt aangeboden

### Voordelen

1. **Naadloze Gebruikerservaring**: Gebruikers hoeven slechts één keer te authenticeren voor meerdere apps van dezelfde leverancier
2. **Verbeterde Beveiliging**: Maakt gebruik van platform-specifieke veilige opslagmechanismen in plaats van browser cookies
3. **Betrouwbaarheid**: Elimineert problemen met gewiste browser cookies of privé browsen modi
4. **Standaarden Compliance**: Gebruikt gevestigde OAuth2 en OpenID Connect patronen en extensies

### Use Cases

Deze specificatie is bijzonder waardevol voor:

- Enterprise mobiele app suites waarbij meerdere apps authenticatie moeten delen
- Consumer apps van dezelfde leverancier (bijv. social media bedrijf met meerdere apps)
- Financiële diensten apps die naadloze maar veilige authenticatie vereisen tussen meerdere tools
- Zorgtoepassingen waarbij zorgverleners meerdere gespecialiseerde apps gebruiken

### Conclusie

OpenID Connect Native SSO voor Mobiele Apps 1.0 vertegenwoordigt een significante vooruitgang in mobiele authenticatie, waarbij een gestandaardiseerde aanpak wordt geboden die de unieke uitdagingen van mobiele SSO aanpakt terwijl beveiligings- en gebruikerservaringsnormen worden gehandhaafd. Het maakt echt naadloze authenticatie-ervaringen mogelijk binnen mobiele app-ecosystemen terwijl gebruik wordt gemaakt van de beveiligingsfuncties die in moderne mobiele platforms zijn ingebouwd.