Deze walkthrough beschrijft hoe een module de gebruiker na afloop terugbrengt naar de PGO. De module voert drie verplichte stappen uit in vaste volgorde: (1) Task-status bijwerken, (2) token revoken, (3) browser redirecten naar de `return_url`. De flow vindt altijd plaats in hetzelfde browser-window via een HTTP 302 redirect.

### Overzicht

1. **Werk de Task-status bij** via `PATCH /Task/{id}` — dit MOET vóór de redirect plaatsvinden zodat het PGO na terugkeer de actuele status kan ophalen.
2. **Revoke het access_token** conform RFC 7009 — het token is niet meer nodig na de status-update.
3. **Redirect de browser** via HTTP 302 naar de `return_url` uit de launch-context — optioneel met `error`-parameter bij afbreken of fout.

Stap 1 en 3 zijn sequentieel (Task-update vóór redirect); stap 2 en 3 mogen parallel plaatsvinden.

### Voorwaarden

- De module heeft de `return_url` uit de launch-context opgeslagen (ontvangen in de Token Exchange response in [3.6](technical-walkthrough-module-launch-ontvangen.html)).
- Het access_token is nog geldig (nodig voor de Task-status-update in stap 1).
- De module kent het `Task.id` uit de launch-context.

### Stap 1 — Task-status bijwerken

Voordat de module de gebruiker terugstuurt, MOET de module de `Task.status` bijwerken naar de juiste waarde die de uitkomst van het modulegebruik weerspiegelt (bijv. `completed`, `failed`, `cancelled`, `in-progress`). Zie [Wijzigen Task-status als module](technical-walkthrough-module-task-status-wijzigen.html) voor de technische details.

Dit is essentieel omdat het PGO na de redirect een `GET /Task/{id}` uitvoert om de actuele status op te halen. Zonder voorafgaande update ziet het PGO een verouderde status.

### Stap 2 — Token revocation (RFC 7009)

Na de Task-status-update MOET de module het access_token laten intrekken via het revocation endpoint van de DVA. De DVA MOET request revocation ondersteunen en bijbehorende access_tokens en refresh_tokens vernietigen.

#### Parameters

* `revocationEndpoint`, uit de SMART configuration (of `{DVA_AUTH_URL}/revoke`).
* `token`, het access_token dat gerevoked moet worden.
* `clientId` / `clientSecret`, module client credentials.

```typescript
async function revokeToken(
    revocationEndpoint: string,
    token: string,
    clientId: string,
    clientSecret: string,
) {
    const basic = Buffer.from(`${clientId}:${clientSecret}`).toString("base64");
    const body = new URLSearchParams({
        token: token,
        token_type_hint: "access_token",
    });
    await fetch(revocationEndpoint, {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            Authorization: `Basic ${basic}`,
        },
        body: body.toString(),
    });
    // RFC 7009: server antwoordt altijd 200 OK, ook als token al verlopen was.
}
```

Stap 2 mag parallel met stap 3 plaatsvinden — de token-revocation hoeft de redirect niet te blokkeren.

### Stap 3 — Redirect naar PGO

De module stuurt een HTTP 302 redirect naar de `return_url`. Het PGO kan de `return_url` verrijken met query-parameters zoals `task_id`, zodat het PGO bij terugkomst direct de juiste taak kan tonen.

#### Normale terugkeer

```http
HTTP/1.1 302 Found
Location: https://pgo.example.nl/launch_callback?task_id=abc
```

#### Terugkeer na afbreken of fout

Bij annulering of fout voegt de module een `error`-parameter toe:

```http
HTTP/1.1 302 Found
Location: https://pgo.example.nl/launch_callback?task_id=abc&error=temporarily_unavailable
```

#### TypeScript voorbeeld

```typescript
function redirectToPgo(
    returnUrl: string,
    error?: string,
) {
    const url = new URL(returnUrl);
    if (error) {
        url.searchParams.set("error", error);
    }
    // Express: res.redirect(302, url.toString());
    window.location.href = url.toString();
}
```

#### Wat het PGO doet na terugkeer

* Ontvangt de gebruiker op de `return_url`, eventueel met `task_id` als query-parameter.
* Haalt (optioneel direct) de taak opnieuw op via `GET /Task/{id}` om de bijgewerkte status te tonen.
* Toont de bijgewerkte status en eventuele foutcodes of metadata.

#### Mobiele apps

De `return_url` werkt ook voor mobiele apps: voor iOS via **Universal Links** en voor Android via **App Links**. Dit is de verantwoordelijkheid van de app-bouwers.

### Sessie-management

De sessie tussen persoon en aanbiedermodule heeft een beperkte geldigheidsduur met een sliding window:

* **Access_token geldigheid**: 900 seconden (15 minuten).
* **Sliding window**: de module MAG het access_token vernieuwen via een refresh_token (RFC 6749 §6) tussen 10 en 15 minuten vóór expiry, telkens met 15 minuten verlenging.
* **Maximale sessieduur**: 10.800 seconden (3 uur).
* **Grace period**: DVA hanteert 120 seconden grace vóór automatische vernietiging, zodat de module tijd heeft om het token te ontvangen en opnieuw aan te vragen.
* **DVA verplichtingen**:
  - MOET access_token en refresh_token na maximale duur + 120 s automatisch vernietigen.
  - MOET verzoeken om nieuw access_token + refresh_token inwilligen zolang de maximale duur nog niet bereikt is.
  - MOET de `expires_in` van het access_token binnen de resterende geldigheid van het sliding window laten vallen.

De sessie eindigt wanneer:
1. De geldigheidsduur is bereikt.
2. De persoon de sessie beëindigt.

### Discussie

Openstaand: locatie van `return_url` in de SMART-context. Het Confluence-document vermeldt dat de `return_url` meekomt in de launch-context (stap 3.6). De exacte positie in de token response (top-level veld vs. `authorization_details`) is nog af te stemmen.

Openstaand: welke `error`-waarden zijn gestandaardiseerd? Het voorbeeld gebruikt `temporarily_unavailable`; een volledige lijst van foutcodes is nog niet vastgelegd.
