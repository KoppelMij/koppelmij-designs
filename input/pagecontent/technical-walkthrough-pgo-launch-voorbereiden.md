Deze walkthrough beschrijft hoe een PGO een module-launch voorbereidt door een `launch_code` op te halen bij de DVA. De flow is gebaseerd op [Option 3a - Token Exchange Launch Token met Gebruikersidentificatie](koppelmij_option_3a.html) en gebruikt PAR (RFC 9126), Authorization Code flow met PKCE (RFC 6749 / RFC 7636) en Token Exchange (RFC 8693). Voorwaarde is dat het PGO in de verzamelfase al een DVA access_token (`MEDMIJ_VERZAMELEN_TOKEN`) heeft verkregen.

### Overzicht

De PGO doorloopt vier stappen om een `launch_code` op te halen bij de DVA:

1. **`POST /par`** — Pushed Authorization Request met `subject_token`, PKCE en state (backchannel).
2. **`GET /authorize`** — front-channel redirect met `request_uri`. De DVA zet de *Module DVA Authentication cookie* en redirect direct terug naar de PGO-callback (géén DigiD in dit pad).
3. **`GET /callback_stepup`** — PGO ontvangt een `code` (opaque, kortlevende authorization code) en `state`.
4. **`POST /token`** — Token Exchange waarbij de authorization code als `actor_token` wordt meegegeven en de response de `launch_code` bevat.

### Voorwaarden

- Het PGO beschikt over `MEDMIJ_VERZAMELEN_TOKEN`, het DVA access_token uit de verzamelfase.
- Het PGO heeft een geregistreerde `client_id` bij de DVA.
- De `redirect_uri` `https://pgo.example.nl/callback_stepup` is geregistreerd bij de DVA.
- Per flow genereert het PGO:
  - een `state` (opaque, CSRF-bescherming);
  - een PKCE `code_verifier` + afgeleide `code_challenge` (method `S256`).

### Stap 1 — Pushed Authorization Request

De PGO duwt de authorization request naar de DVA voordat de browser wordt geredirect.

#### Parameters

* `baseUrl`, de DVA Authorization Server, bijvoorbeeld `https://dva.example.nl`.
* `subjectToken`, de `MEDMIJ_VERZAMELEN_TOKEN` uit de verzamelfase.
* `moduleClientId`, de `client_id` van de module die gelaunched wordt (audience).
* `pgoClientId`, de `client_id` van het PGO bij de DVA.
* `redirectUri`, bijvoorbeeld `https://pgo.example.nl/callback_stepup`.
* `state`, opaque anti-CSRF waarde.
* `codeChallenge`, PKCE code_challenge, methode `S256`.
* `scope`, door de DVA voorgeschreven scope-set. Typisch combinatie van SMART-on-FHIR scopes (bv. `launch openid fhirUser patient/*.read`); exacte waarde is per DVA configureerbaar.

```typescript
async function pushAuthorizationRequest(
    baseUrl: string,
    subjectToken: string,
    moduleClientId: string,
    pgoClientId: string,
    redirectUri: string,
    state: string,
    codeChallenge: string,
    scope: string,
): Promise<{ request_uri: string; expires_in: number }> {
    const url = `${baseUrl}/par`;
    const body = new URLSearchParams({
        response_type: "code",
        client_id: pgoClientId,
        redirect_uri: redirectUri,
        audience: moduleClientId,
        subject_token: subjectToken,
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        acr_values: "urn:medmij:oauth2:acr-value:launch-authorization",
        state: state,
        scope: scope,
        code_challenge: codeChallenge,
        code_challenge_method: "S256",
    });
    const resp = await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body.toString(),
    });
    if (!resp.ok) {
        throw new Error(`PAR failed: ${resp.status} ${resp.statusText}`);
    }
    return await resp.json();
}
```

#### Response value

* `201 Created` met een JSON map die het `request_uri` bevat, te gebruiken in [Stap 2](#stap-2--redirect-naar-authorize-front-channel). De `expires_in` geeft de geldigheid van dit `request_uri` in seconden.

##### Example

```JSON
{
    "request_uri": "urn:ietf:params:oauth:request_uri:example123",
    "expires_in": 90
}
```

### Stap 2 — Redirect naar `/authorize` (front-channel)

De PGO stuurt de browser naar de DVA `/authorize` met het `request_uri` uit Stap 1.

#### Parameters

* `client_id`, de PGO `client_id` (zelfde als in PAR).
* `request_uri`, de waarde uit de PAR-response.
* `state`, zelfde waarde als in PAR (optioneel — het `request_uri` bevat ook state, maar het meesturen vergemakkelijkt browser-side correlatie).

#### HTTP voorbeeld

```http
GET /authorize?client_id={pgo-clientid}&request_uri=urn:ietf:params:oauth:request_uri:example123&state=example456 HTTP/1.1
Host: dva.example.nl
```

Wat er aan DVA-zijde gebeurt:

* De DVA valideert het `request_uri` en correleert met de parameters uit Stap 1.
* De DVA triggert **géén DigiD-login** in dit pad; het `MEDMIJ_VERZAMELEN_TOKEN` uit Stap 1 fungeert als bewijs van eerdere authenticatie.
* De DVA maakt de **Module DVA Authentication cookie** aan op het DVA-domein, gebonden aan `sub` (claim uit `MEDMIJ_VERZAMELEN_TOKEN`), `client_id` van de module, `state` en een kortlevende authorization code. TTL: 3 minuten.
* De DVA redirect direct terug naar de `redirect_uri` van het PGO met de authorization code.

### Stap 3 — Callback op het PGO

Het PGO ontvangt de authorization code op zijn `redirect_uri`.

#### Parameters

* `code`, opaque authorization code uitgegeven door de DVA (kortlevend, eenmalig bruikbaar in Stap 4).
* `state`, moet exact matchen met de `state` uit Stap 1.

#### HTTP voorbeeld

```http
GET /callback_stepup?code={authorization-code}&state=example456 HTTP/1.1
Host: pgo.example.nl
```

#### Validatie

* Verifieer dat `state` overeenkomt met de waarde die in Stap 1 is gegenereerd. Bij mismatch: flow afbreken.
* Correleer de ontvangen `code` met de bijbehorende PKCE `code_verifier`; die is nodig in Stap 4.

### Stap 4 — Token Exchange voor de `launch_code`

Het PGO wisselt de `MEDMIJ_VERZAMELEN_TOKEN` + authorization code in voor een `launch_code` via Token Exchange.

#### Parameters

* `baseUrl`, de DVA Authorization Server, bijvoorbeeld `https://dva.example.nl`.
* `subjectToken`, dezelfde `MEDMIJ_VERZAMELEN_TOKEN` als in Stap 1.
* `authorizationCode`, de `code` uit Stap 3.
* `codeVerifier`, de PKCE `code_verifier` die in Stap 1 als `code_challenge` is gecommitteerd.
* `pgoClientId` en `moduleClientId`, zelfde waarden als in Stap 1.
* `resources`, één of meer FHIR resource-referenties die de launch-context vormen (bijv. `Task/456`, `Observation/789`). De DVA valideert dat het PGO toegang heeft tot deze resources en neemt ze op in de launch-context. Zie [Option 3a §Context meegeven](koppelmij_option_3a.html#context-meegeven-in-token-exchange).

```typescript
async function exchangeForLaunchCode(
    baseUrl: string,
    subjectToken: string,
    authorizationCode: string,
    codeVerifier: string,
    pgoClientId: string,
    moduleClientId: string,
    resources: string[],
): Promise<{
    access_token: string;
    expires_in: number;
    token_type: string;
    issued_token_type: string;
}> {
    const url = `${baseUrl}/token`;
    const body = new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        subject_token: subjectToken,
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        actor_token: authorizationCode,
        actor_token_type: "urn:medmij:token-type:launch-authorization-code",
        requested_token_type: "urn:medmij:token-type:launch-code",
        client_id: pgoClientId,
        audience: moduleClientId,
        code_verifier: codeVerifier,
    });
    // resource is multi-valued; URLSearchParams append respecteert dat bij serialisatie.
    for (const resource of resources) {
        body.append("resource", resource);
    }
    const resp = await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body.toString(),
    });
    if (!resp.ok) {
        throw new Error(`Token Exchange failed: ${resp.status} ${resp.statusText}`);
    }
    return await resp.json();
}
```

#### Response value

* `200 OK` met een JSON map. De `access_token` bevat de `launch_code`.

> **Let op:** de `launch_code` is géén access_token. Hij wordt conform RFC 8693 in het veld `access_token` geretourneerd, maar is bedoeld als opaque launch-code voor de SMART-on-FHIR launch van de module en kan niet gebruikt worden tegen een FHIR endpoint. Het veld `token_type` is bewust `N_A`. De `launch_code` is kortlevend (doorgaans 180 s) en **éénmalig bruikbaar**.

##### Example

```JSON
{
    "access_token": "{launch_code}",
    "expires_in": 180,
    "token_type": "N_A",
    "issued_token_type": "urn:medmij:token-type:launch-code"
}
```

### Volgende stap

Met de `launch_code` kan het PGO de module launchen via SMART-on-FHIR. Zie [Het uitvoeren van de launch als PGO](technical-walkthrough-pgo-launch-uitvoeren.html).

### Discussie

Openstaand: de gekozen waarde voor `acr_values` in Stap 1. In eerdere ontwerpversies werd `urn:medmij:oauth2:acr-value:step-up` gebruikt als marker voor de step-up flow. Nu step-up is komen te vervallen, is de huidige aanname `urn:medmij:oauth2:acr-value:launch-authorization` als marker voor "dit is een launch-voorbereiding, geen gewone verzamelen-authorize". Openstaande vragen:

* Moet `acr_values` überhaupt meegegeven worden, of is `audience={module-clientid}` + `requested_token_type=launch-code` in Stap 4 voldoende signaal voor de DVA?
* Als `acr_values` blijft: is `urn:medmij:oauth2:acr-value:launch-authorization` de juiste naamgeving, of hoort dit bij een andere MedMij-urn-namespace?
