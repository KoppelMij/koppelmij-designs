Deze walkthrough beschrijft hoe een module de gebruiker na afloop terugbrengt naar de PGO. De module voert twee verplichte stappen uit in vaste volgorde: (1) Task-status bijwerken, (2) browser redirecten naar de `return_url`. De flow vindt altijd plaats in hetzelfde browser-window via een HTTP 302 redirect.

### Overzicht

1. **Werk de Task-status bij** via `PATCH /Task/{id}` — dit MOET vóór de redirect plaatsvinden zodat het PGO na terugkeer de actuele status kan ophalen.
2. **Redirect de browser** via HTTP 302 naar de `return_url` uit de launch-context — optioneel met `status` / `error`-parameter bij afbreken of fout.

### Voorwaarden

- De module heeft de `return_url` uit de launch-context opgeslagen (ontvangen in de Token Exchange response in [3.6](technical-walkthrough-module-launch-ontvangen.html)).
- Het access_token is nog geldig (nodig voor de Task-status-update in stap 1).
- De module kent het `Task.id` uit de launch-context.

### Stap 1 — Task-status bijwerken

Voordat de module de gebruiker terugstuurt, MOET de module de `Task.status` bijwerken naar de juiste waarde die de uitkomst van het modulegebruik weerspiegelt (bijv. `completed`, `failed`, `cancelled`, `in-progress`). Zie [Wijzigen Task-status als module](technical-walkthrough-module-task-status-wijzigen.html) voor de technische details.

Dit is essentieel omdat het PGO na de redirect een `GET /Task/{id}` uitvoert om de actuele status op te halen. Zonder voorafgaande update ziet het PGO een verouderde status.

### Stap 2 — Redirect naar PGO

De module stuurt een HTTP 302 redirect naar de `return_url`. Het PGO kan de `return_url` verrijken met query-parameters zoals `task_id`, zodat het PGO bij terugkomst direct de juiste taak kan tonen.

#### Normale terugkeer

```http
HTTP/1.1 302 Found
Location: https://pgo.example.nl/launch_callback?task_id=abc
```

#### Snelle terugkeer bij foutstatus

Voor taken met de status `entered-in-error`, `failed`, `cancelled` of `rejected` MAG de module de gebruiker direct terugsturen naar het PGO. De module KAN daarbij optioneel een `status`- en `message`-parameter meegeven, zodat het PGO meteen een gebruikersvriendelijke melding kan tonen zonder te wachten op de her-synchronisatie:

```http
HTTP/1.1 302 Found
Location: https://pgo.example.nl/launch_callback?task_id=abc&status=error&message=taak-is-cancelled
```

Voor andere foutsituaties (bijvoorbeeld `temporarily_unavailable`) volstaat een `error`-parameter:

```http
HTTP/1.1 302 Found
Location: https://pgo.example.nl/launch_callback?task_id=abc&error=temporarily_unavailable
```

> **DVA is leidend voor `Task.status`.** De query-parameters `status` / `message` zijn slechts een hint voor een snelle UX-melding. Het PGO MOET na terugkeer de taak opnieuw ophalen bij de DVA en uitsluitend de daar verzamelde status overnemen.

#### TypeScript voorbeeld

```typescript
function redirectToPgo(
    returnUrl: string,
    options?: { status?: string; message?: string; error?: string },
) {
    const url = new URL(returnUrl);
    if (options?.status) url.searchParams.set("status", options.status);
    if (options?.message) url.searchParams.set("message", options.message);
    if (options?.error) url.searchParams.set("error", options.error);
    // Express: res.redirect(302, url.toString());
    window.location.href = url.toString();
}
```

#### Wat het PGO doet na terugkeer

* Ontvangt de gebruiker op de `return_url`, eventueel met `task_id` als query-parameter.
* MOET de taak opnieuw ophalen bij de DVA via `GET /Task/{id}` om de actuele status vast te stellen.
* MOET uitsluitend de status uit de DVA-respons als waarheid overnemen — een meegegeven `status`-query-parameter is alleen een UX-hint.
* KAN op basis van een meegegeven `status` / `message` direct een gebruikersvriendelijke melding tonen, zonder te wachten op de her-synchronisatie.

#### Mobiele apps

De `return_url` werkt ook voor mobiele apps: voor iOS via **Universal Links** en voor Android via **App Links**. Dit is de verantwoordelijkheid van de app-bouwers.

### Sessie-management

De sessie geldt zowel tussen persoon en aanbiedermodule als tussen aanbiedermodule en DVA. De sessie heeft een beperkte geldigheidsduur met een sliding window:

* **Maximale sessieduur**: 180 minuten (3 uur).
* **Access_token geldigheid**: 900 seconden (15 minuten), conform `core.autorisatie.204`.
* **Sliding window**: de module MAG de geldigheidsduur van het access_token tussen de 10e en 15e minuut telkens met 15 minuten verlengen, via een refresh_token (RFC 6749 §6).
* **AM/DVA verplichtingen**:
  - DVA MOET access_token en refresh_token na de maximale duur van het access_token automatisch vernietigen.
  - AM MOET de sessie beëindigen bij het bereiken van de duur van het (huidige ofwel laatste) access_token.
  - AM MAG om een nieuw access_token en nieuw refresh_token verzoeken.
  - DVA MOET een verzoek om nieuw access_token en nieuw refresh_token inwilligen zolang de maximale sessieduur nog niet bereikt is.
  - DVA MOET ervoor zorgen dat de `expires_in` van het access_token binnen de geldigheidsduur van het sliding window valt.

> Het refresh-proces hier wijkt af van MedMij Verzamelen: het gaat om het verlengen van een actieve sessie. Is de sessie 900 seconden of langer offline, dan verloopt de sessie.

De sessie eindigt wanneer:
1. De maximale sessieduur is bereikt.
2. De persoon de sessie beëindigt.

### Discussie

Openstaand: locatie van `return_url` in de SMART-context. Het Confluence-document vermeldt dat de `return_url` meekomt in de launch-context (stap 3.6). De exacte positie in de token response (top-level veld vs. `authorization_details`) is nog af te stemmen.

Openstaand: welke `error`-waarden zijn gestandaardiseerd? Het voorbeeld gebruikt `temporarily_unavailable`; een volledige lijst van foutcodes is nog niet vastgelegd.
