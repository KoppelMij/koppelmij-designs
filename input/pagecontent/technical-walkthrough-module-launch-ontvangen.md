Deze walkthrough beschrijft hoe een module een PGO-launch ontvangt en doorloopt tot FHIR resource-toegang. De module fungeert hier als standaard [SMART App Launch](http://hl7.org/fhir/smart-app-launch/app-launch.html) client tegen de DVA als Authorization Server en Resource Server. Voorwaarde is dat de PGO de module heeft gelauncht zoals beschreven in [Uitvoeren van een launch als PGO](technical-walkthrough-pgo-launch-uitvoeren.html).

### Overzicht

De module doorloopt vijf stappen:

1. **Ontvang de launch request** op het launch endpoint (`GET /launch?iss=&launch=`) en haal de SMART configuration op bij de `iss`.
2. **Redirect naar `/authorize`** bij de DVA met de `launch`-parameter, PKCE en state.
3. **Ontvang de authorization code** op de module `redirect_uri`.
4. **Token exchange** bij de DVA voor een access_token.
5. **FHIR-resources ophalen** met het access_token.

### Voorwaarden

- De module is als SMART-on-FHIR client geregistreerd bij de DVA (`client_id`, `client_secret`, `redirect_uri`).
- De module kent zijn eigen launch endpoint (bijv. `https://module.example.nl/launch`).
- Per launch genereert de module: een `state` (anti-CSRF, gebonden aan sessie) en een PKCE `code_verifier` + `code_challenge` (methode `S256`).

### Stap 1 — Ontvang de launch request en haal de SMART configuration op

De module ontvangt een SMART standalone/EHR launch request met `iss` en `launch` als query-parameters. Met de `iss` wordt de SMART configuration opgehaald; daaruit komen de `authorization_endpoint` en `token_endpoint` van de DVA.

#### Parameters

* `iss`, URL-gecodeerde DVA FHIR base URL, bijvoorbeeld `https://dva.example.nl/fhir`.
* `launch`, de `launch_code` die het PGO via Token Exchange heeft verkregen.

#### HTTP voorbeeld

De binnenkomende request op de module:

```http
GET /launch?iss=https%3A%2F%2Fdva.example.nl%2Ffhir&launch={launch_code} HTTP/1.1
Host: module.example.nl
```

#### SMART configuration ophalen

```typescript
type SmartConfiguration = {
    authorization_endpoint: string;
    token_endpoint: string;
    capabilities: string[];
    code_challenge_methods_supported?: string[];
    scopes_supported?: string[];
};

async function getSmartConfiguration(iss: string): Promise<SmartConfiguration> {
    const url = `${iss}/.well-known/smart-configuration`;
    const resp = await fetch(url, {
        headers: { Accept: "application/json" },
    });
    if (!resp.ok) {
        throw new Error(`SMART configuration fetch failed: ${resp.status}`);
    }
    return resp.json();
}
```

#### Response value

* Een JSON map met minimaal `authorization_endpoint` en `token_endpoint`, gebruikt in Stap 2 en Stap 4.

##### Example

```JSON
{
    "authorization_endpoint": "https://dva.example.nl/authorize",
    "token_endpoint": "https://dva.example.nl/token",
    "capabilities": [
        "launch-standalone",
        "client-confidential-symmetric",
        "context-standalone-patient",
        "permission-patient"
    ],
    "code_challenge_methods_supported": ["S256"],
    "scopes_supported": ["launch", "openid", "fhirUser", "patient/*.read"]
}
```

### Stap 2 — Redirect naar DVA `/authorize`

De module redirect de browser naar het `authorization_endpoint` met de ontvangen `launch`-parameter, PKCE en state. De module slaat `state`, `code_verifier` en `iss` server-side op, gekoppeld aan de browser-sessie.

#### Parameters

* `authorizationEndpoint`, uit Stap 1.
* `clientId`, de `client_id` van de module bij de DVA.
* `redirectUri`, de geregistreerde module callback URL.
* `scope`, de gewenste scopes. Typisch `launch openid fhirUser patient/*.read`. De `openid`/`fhirUser`-combinatie is een bilaterale afspraak — zie [DVA als Identity Provider](dva_openid_scope.html) en de [Discussie](#discussie).
* `state`, opaque CSRF-waarde.
* `launch`, de `launch_code` uit Stap 1.
* `codeChallenge`, PKCE code_challenge (method `S256`).
* `aud`, de DVA FHIR base URL (`iss` uit Stap 1). SMART vereist dat de module de beoogde audience expliciet meestuurt.

#### TypeScript voorbeeld

```typescript
function buildAuthorizeRedirect(
    authorizationEndpoint: string,
    clientId: string,
    redirectUri: string,
    scope: string,
    state: string,
    launchCode: string,
    codeChallenge: string,
    aud: string,
): string {
    const params = new URLSearchParams({
        response_type: "code",
        client_id: clientId,
        redirect_uri: redirectUri,
        scope: scope,
        state: state,
        aud: aud,
        launch: launchCode,
        code_challenge: codeChallenge,
        code_challenge_method: "S256",
    });
    return `${authorizationEndpoint}?${params.toString()}`;
}
```

#### HTTP voorbeeld

De browser volgt de redirect:

```http
GET /authorize?response_type=code&client_id={module-clientid}&redirect_uri=https%3A%2F%2Fmodule.example.nl%2Fcallback&scope=launch+openid+fhirUser+patient%2F%2A.read&state=example789&aud=https%3A%2F%2Fdva.example.nl%2Ffhir&launch={launch_code}&code_challenge=XYZ&code_challenge_method=S256 HTTP/1.1
Host: dva.example.nl
```

Wat er aan DVA-zijde gebeurt:

* De DVA valideert de `launch_code` en koppelt die aan de in Stap 4 van walkthrough #1 opgebouwde context (sub, module `client_id`, resources).
* De DVA authenticeert de gebruiker. Afhankelijk van DVA-implementatie gaat dit via DigiD óf via de *Module DVA Authentication cookie* die tijdens walkthrough #1 is gezet.
* De DVA redirect terug naar `redirect_uri` met `code` en `state`.

### Stap 3 — Ontvang de authorization code

De DVA stuurt de browser terug naar de module callback met een authorization code.

#### Parameters

* `code`, opaque authorization code (kortlevend, eenmalig bruikbaar in Stap 4).
* `state`, moet exact matchen met de waarde uit Stap 2.

#### HTTP voorbeeld

```http
GET /callback?code={authorization-code}&state=example789 HTTP/1.1
Host: module.example.nl
```

#### Validatie

* Verifieer `state` tegen de waarde uit de sessie. Bij mismatch: afbreken.
* Haal `code_verifier`, `iss` en `redirect_uri` uit de sessie-context voor Stap 4.

### Stap 4 — Token exchange voor het access_token

De module ruilt de authorization code in voor een access_token bij het `token_endpoint`.

#### Parameters

* `tokenEndpoint`, uit Stap 1.
* `code`, uit Stap 3.
* `codeVerifier`, de PKCE `code_verifier` uit Stap 2.
* `redirectUri`, zelfde als in Stap 2.
* `clientId` / `clientSecret`, module client credentials.

```typescript
type TokenResponse = {
    access_token: string;
    token_type: "Bearer";
    expires_in: number;
    scope: string;
    patient?: string;
    fhirUser?: string;
    id_token?: string;
    refresh_token?: string;
};

async function exchangeCodeForAccessToken(
    tokenEndpoint: string,
    code: string,
    codeVerifier: string,
    redirectUri: string,
    clientId: string,
    clientSecret: string,
): Promise<TokenResponse> {
    const body = new URLSearchParams({
        grant_type: "authorization_code",
        code: code,
        redirect_uri: redirectUri,
        code_verifier: codeVerifier,
    });
    const basic = Buffer.from(`${clientId}:${clientSecret}`).toString("base64");
    const resp = await fetch(tokenEndpoint, {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            Authorization: `Basic ${basic}`,
        },
        body: body.toString(),
    });
    if (!resp.ok) {
        throw new Error(`Token exchange failed: ${resp.status} ${resp.statusText}`);
    }
    return resp.json();
}
```

#### Response value

* `200 OK` met JSON map die het `access_token` bevat, plus launch-context (`patient`, `fhirUser`, eventueel `id_token` als `openid` scope is gebruikt).

##### Example (met `openid fhirUser` scope)

```JSON
{
    "access_token": "{access_token}",
    "token_type": "Bearer",
    "expires_in": 3600,
    "scope": "launch openid fhirUser patient/*.read",
    "patient": "Patient/789",
    "fhirUser": "Patient/789",
    "id_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

##### Example (zonder `openid` scope)

```JSON
{
    "access_token": "{access_token}",
    "token_type": "Bearer",
    "expires_in": 3600,
    "scope": "launch patient/*.read",
    "patient": "Patient/789"
}
```

### Stap 5 — FHIR-resources ophalen

De module gebruikt het access_token om FHIR resources op te halen bij de DVA Resource Server.

#### Parameters

* `iss`, de DVA FHIR base URL uit Stap 1.
* `accessToken`, uit Stap 4.

#### HTTP voorbeeld

```http
GET /fhir/Task/456 HTTP/1.1
Host: dva.example.nl
Authorization: Bearer {access_token}
Accept: application/fhir+json
```

```typescript
async function fetchTask(
    iss: string,
    taskId: string,
    accessToken: string,
): Promise<unknown> {
    const resp = await fetch(`${iss}/Task/${taskId}`, {
        headers: {
            Authorization: `Bearer ${accessToken}`,
            Accept: "application/fhir+json",
        },
    });
    if (!resp.ok) {
        throw new Error(`FHIR GET /Task/${taskId} failed: ${resp.status}`);
    }
    return resp.json();
}
```

De module kan vervolgens zijn eigen functionaliteit aanbieden (bijvoorbeeld een vragenlijst tonen) op basis van de opgehaalde FHIR-context.

### Discussie

Openstaand: scope-keuze en `id_token`.

* De combinatie `openid fhirUser` leidt ertoe dat de DVA een `id_token` uitgeeft met de gebruikersidentiteit als FHIR referentie. Dit is de verwachte praktijk voor modules met meervoudige toegang (PGO én portalen). Zie [DVA als Identity Provider](dva_openid_scope.html).
* Een launch zonder `openid` is toegestaan; de module krijgt dan geen `id_token` en moet gebruikersidentiteit afleiden uit launch-context (`patient`, `fhirUser` via scope zonder `openid` is technisch niet mogelijk in SMART v2).
* De concrete scope-set is een bilaterale afspraak tussen moduleleverancier en zorgaanbieder/DVA — niet vastgelegd in het KoppelMij afsprakenstelsel.

Openstaand: client-authenticatiemethode op `/token`. Dit voorbeeld gebruikt `client_secret_basic`. Een DVA mag ook `client_secret_post`, `private_key_jwt` of andere methoden ondersteunen; zie het veld `token_endpoint_auth_methods_supported` in de SMART configuration.
