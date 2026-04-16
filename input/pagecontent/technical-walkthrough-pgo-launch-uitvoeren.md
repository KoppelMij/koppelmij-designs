Deze walkthrough beschrijft hoe een PGO een module-launch uitvoert nadat het de `launch_code` heeft verkregen. De launch bestaat uit een SMART-on-FHIR standard launch request naar de module, met de DVA FHIR server als `iss` en de `launch_code` als `launch`-parameter. Voorwaarde is dat de PGO de voorbereiding in [Voorbereiden van een launch als PGO](technical-walkthrough-pgo-launch-voorbereiden.html) succesvol heeft afgerond.

### Overzicht

De PGO doorloopt twee stappen om de module te launchen:

1. **Resolveer de module launch URL** via de FHIR-keten `Task → ActivityDefinition → Endpoint.address`. Hierdoor is de launch URL niet hardcoded maar per module configureerbaar door de DVA.
2. **Redirect de browser** naar `{module-launch-url}?iss={DVA_FHIR_BASE_URL}&launch={launch_code}`. De module start daarop zijn SMART-on-FHIR authorization flow bij de DVA (zie walkthrough #3).

### Voorwaarden

- Het PGO beschikt over een `launch_code` uit de voorbereidingsstap.
- Het PGO kent de `Task/{id}` die de module vertegenwoordigt (opgehaald tijdens de verzamelfase).
- Het PGO heeft een geldig DVA access_token (`MEDMIJ_VERZAMELEN_TOKEN`) om FHIR resources bij de DVA op te vragen.
- Het PGO kent de DVA FHIR base URL (`iss`).

### Stap 1 — Resolveer de module launch URL

De launch URL wordt per module door de DVA geconfigureerd via een keten van FHIR resources:

- `Task.instantiatesCanonical` verwijst naar een `ActivityDefinition`.
- `ActivityDefinition.endpoint` verwijst naar een `Endpoint`.
- `Endpoint.address` bevat de daadwerkelijke module launch URL.

Deze ketting geeft de DVA flexibiliteit: zij kan per module een andere launch endpoint configureren, of er bewust voor kiezen om alle launches via een DVA-eigen endpoint te routeren (zie [Overwegingen](overwegingen_optie_3a.html#optie-3b-dva-geïnitieerde-module-launch)).

#### Parameters

* `baseUrl`, de DVA FHIR base URL, bijvoorbeeld `https://dva.example.nl/fhir`.
* `taskId`, het id van de Task-resource die de module-uitvoering vertegenwoordigt.
* `accessToken`, het `MEDMIJ_VERZAMELEN_TOKEN` voor authenticatie richting de DVA FHIR server.

```typescript
async function resolveModuleLaunchUrl(
    baseUrl: string,
    taskId: string,
    accessToken: string,
): Promise<string> {
    const fhirGet = async (path: string) => {
        const resp = await fetch(`${baseUrl}${path}`, {
            headers: {
                Authorization: `Bearer ${accessToken}`,
                Accept: "application/fhir+json",
            },
        });
        if (!resp.ok) {
            throw new Error(`FHIR GET ${path} failed: ${resp.status}`);
        }
        return resp.json();
    };

    const task = await fhirGet(`/Task/${taskId}`);
    const activityDefinitionRef: string = task.instantiatesCanonical;
    if (!activityDefinitionRef) {
        throw new Error("Task.instantiatesCanonical ontbreekt");
    }

    // instantiatesCanonical kan een absolute of relatieve canonical bevatten.
    const activityDefinition = await fhirGet(
        activityDefinitionRef.startsWith("http")
            ? `/ActivityDefinition?url=${encodeURIComponent(activityDefinitionRef)}`
            : `/${activityDefinitionRef}`,
    );

    const endpointRef: string = Array.isArray(activityDefinition.endpoint)
        ? activityDefinition.endpoint[0]?.reference
        : activityDefinition.endpoint?.reference;
    if (!endpointRef) {
        throw new Error("ActivityDefinition.endpoint ontbreekt");
    }

    const endpoint = await fhirGet(`/${endpointRef}`);
    if (!endpoint.address) {
        throw new Error("Endpoint.address ontbreekt");
    }
    return endpoint.address;
}
```

#### Response value

* De `Endpoint.address` string, bijvoorbeeld `https://module.example.nl/launch`. Dit is de URL waarop de module de SMART-on-FHIR launch request verwacht.

##### Example

Relevante velden uit de opgehaalde resources:

```JSON
{
    "resourceType": "Task",
    "id": "456",
    "instantiatesCanonical": "ActivityDefinition/copd-questionnaire",
    "status": "requested",
    "for": { "reference": "Patient/789" }
}
```

```JSON
{
    "resourceType": "ActivityDefinition",
    "id": "copd-questionnaire",
    "endpoint": [
        { "reference": "Endpoint/module-copd" }
    ]
}
```

```JSON
{
    "resourceType": "Endpoint",
    "id": "module-copd",
    "status": "active",
    "address": "https://module.example.nl/launch"
}
```

### Stap 2 — Redirect naar de module launch endpoint

De PGO stuurt een `302 Found` redirect naar de module met `iss` (DVA FHIR base URL) en `launch` (de `launch_code`) als query parameters. Dit volgt de [SMART App Launch specificatie](http://hl7.org/fhir/smart-app-launch/app-launch.html#step-1-app-asks-for-authorization).

#### Parameters

* `moduleLaunchUrl`, uit Stap 1.
* `iss`, de DVA FHIR base URL — dezelfde als `baseUrl` in Stap 1.
* `launch`, de `launch_code` uit [walkthrough #1](technical-walkthrough-pgo-launch-voorbereiden.html#stap-4--token-exchange-voor-de-launch_code).

#### HTTP voorbeeld

PGO stuurt de redirect:

```http
HTTP/1.1 302 Found
Location: https://module.example.nl/launch?iss=https%3A%2F%2Fdva.example.nl%2Ffhir&launch={launch_code}
```

De browser volgt de redirect en doet:

```http
GET /launch?iss=https%3A%2F%2Fdva.example.nl%2Ffhir&launch={launch_code} HTTP/1.1
Host: module.example.nl
```

Wat er aan module-zijde gebeurt is buiten de PGO-scope; zie [Ontvangen van een launch als module](technical-walkthrough-module-launch-ontvangen.html).

#### TypeScript voorbeeld

Voor een typische backend framework response:

```typescript
function buildLaunchRedirect(
    moduleLaunchUrl: string,
    iss: string,
    launchCode: string,
): string {
    const params = new URLSearchParams({
        iss: iss,
        launch: launchCode,
    });
    return `${moduleLaunchUrl}?${params.toString()}`;
}

// Gebruik in een Express-achtige handler:
// res.redirect(302, buildLaunchRedirect(moduleLaunchUrl, issUrl, launchCode));
```

### Volgende stap

Hiermee is de launch vanuit PGO-perspectief afgerond. De module verwerkt de launch parameters en start zijn eigen SMART-on-FHIR authorization flow met de DVA. Zie [Ontvangen van een launch als module](technical-walkthrough-module-launch-ontvangen.html) voor wat de module vervolgens doet.

### Discussie

Openstaand: de vorm van de launch redirect.

* **`302 Found` (GET)** — zoals in deze walkthrough gebruikt. Eenvoudig en standaard voor SMART App Launch. Parameters zichtbaar in browser-history en server logs.
* **`FORM_POST_REDIRECT`** — een `POST` via een autosubmit-form op een tussenpagina. De `launch` parameter komt dan in de body, niet in de URL. Dit voorkomt dat de `launch_code` in referrer headers of browser history terechtkomt, maar vraagt een tussenpagina. Gezien de korte levensduur (180 s) en éénmalig gebruik van de `launch_code` is 302 doorgaans acceptabel; in hoog-risico contexten kan `FORM_POST_REDIRECT` de voorkeur verdienen.

Openstaand: caching en idempotentie van de resolve-stap. Voor de meeste PGO-implementaties kan Stap 1 (`Task → ActivityDefinition → Endpoint`) gecached worden per `Task.instantiatesCanonical`, omdat de keten zelden verandert. De DVA kan echter de `Endpoint.address` wijzigen (bijv. bij verhuizing van een module). Bepaal de TTL in overleg met de DVA.
