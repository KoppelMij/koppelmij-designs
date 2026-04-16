Deze walkthrough beschrijft hoe een module de gebruiker na afloop terugbrengt naar de PGO. Het PGO levert een `return_url` mee in de launch-context; afhankelijk van het integratiepatroon (iframe, zelfde window, nieuw tabblad) gebruikt de module die URL of een andere cross-window-communicatiemethode. Zie voor de onderliggende afwegingen en security-overwegingen ook [Terugkeren na Module Afsluiten](module_terugkeer.html).

### Overzicht

1. **Lees de `return_url`** uit de launch-context (ontvangen in de Token Exchange response in [3.6](technical-walkthrough-module-launch-ontvangen.html)).
2. **Bied een UI-element** ("Terug naar PGO") aan de gebruiker.
3. **Voer de terugkeer uit** volgens het gekozen integratiepatroon.

### Voorwaarden

- De module heeft de `return_url` uit de Token Exchange response opgeslagen **server-side** (de backend, niet de browser — het access_token mag de browser niet verlaten).
- De module weet of zij draait in iframe, zelfde window, of nieuw tabblad (typisch afgeleid uit een parameter in de launch-URL of detectie van `window.parent`/`window.opener`).

### Stap 1 — return_url ophalen

Tijdens Stap 4 van walkthrough #3 retourneert de DVA samen met het access_token ook de launch-context. Afhankelijk van de DVA kan `return_url` als top-level veld of binnen `authorization_details` meekomen.

#### Example (token response met return_url)

```JSON
{
    "access_token": "{access_token}",
    "token_type": "Bearer",
    "expires_in": 3600,
    "scope": "launch openid fhirUser patient/*.read patient/Task.write",
    "patient": "Patient/789",
    "fhirUser": "Patient/789",
    "return_url": "https://pgo.example.nl/patient/789/modules?task=456"
}
```

De backend slaat `return_url` op in de sessie en exposeert uitsluitend de `return_url` (geen access_token) aan de frontend via bijvoorbeeld `GET /api/module/context`.

### Stap 2 — Variant A: zelfde window

De module navigeert de browser direct naar `return_url`. Optioneel worden status en timestamp als query parameters meegestuurd.

```typescript
function closeToReturnUrl(returnUrl: string, status: "completed" | "failed" | "cancelled") {
    const url = new URL(returnUrl);
    url.searchParams.set("module_status", status);
    url.searchParams.set("timestamp", new Date().toISOString());
    window.location.href = url.toString();
}
```

### Stap 2 — Variant B: iframe

De module draait binnen een iframe in de PGO. Gebruik [`postMessage`](https://developer.mozilla.org/docs/Web/API/Window/postMessage) om het PGO-window te notificeren; de PGO verwijdert/sluit de iframe.

```typescript
function closeFromIframe(status: "completed" | "failed" | "cancelled", taskId: string) {
    const pgoOrigin = "https://pgo.example.nl"; // concrete origin, geen "*"
    window.parent.postMessage(
        { type: "module-close", status, taskId, timestamp: new Date().toISOString() },
        pgoOrigin,
    );
}
```

PGO-kant (ter illustratie):

```typescript
window.addEventListener("message", (event) => {
    const trustedOrigins = ["https://module.example.nl"];
    if (!trustedOrigins.includes(event.origin)) return;
    if (event.data?.type !== "module-close") return;
    // Sluit iframe en update UI
    closeModuleIframe();
    updateTaskStatus(event.data.taskId, event.data.status);
});
```

### Stap 2 — Variant C: nieuw tabblad

De module is in een nieuw tabblad geopend. Gebruik [`BroadcastChannel`](https://developer.mozilla.org/docs/Web/API/BroadcastChannel) of `window.opener.postMessage` om het PGO-tabblad te notificeren, sluit daarna het eigen tabblad.

```typescript
function closeFromNewTab(status: "completed" | "failed" | "cancelled", taskId: string) {
    const channel = new BroadcastChannel("module-communication");
    channel.postMessage({ type: "module-closed", status, taskId });
    channel.close();
    window.close();
}
```

Fallback als `window.close()` geblokkeerd wordt (niet door script geopend tabblad): toon een instructie aan de gebruiker dat hij het tabblad handmatig kan sluiten en dat de PGO al geüpdatet is.

### Security

- **Valideer `return_url` aan PGO-zijde** — whitelist van toegestane hostnames/paths om open-redirect te voorkomen.
- **Gebruik concrete origins** in `postMessage` (geen `"*"`), en valideer `event.origin` aan de ontvangende kant.
- **Exposeer het access_token niet aan de browser** — backend slaat het veilig op, de frontend ontvangt alleen `return_url` en launch-context via een eigen endpoint.

### Discussie

Openstaand: locatie van `return_url` in het SMART-antwoord. Als top-level veld is praktisch maar niet in SMART v2 standaard gedefinieerd; `authorization_details` is SMART-conform maar complexer. Afstemmen tussen DVA-leveranciers.

Openstaand: verplichting ondersteuning per patroon. Moeten modules alle drie de patronen ondersteunen, of is per module één patroon bilateraal afgesproken met de zorgaanbieder?

Openstaand: graceful handling van "gebruiker drukt browser-back of sluit tabblad". Moet de module bij laatste kans via `beforeunload` nog een status naar de PGO sturen, of is de PGO verantwoordelijk voor detectie van niet-teruggekomen sessies?
