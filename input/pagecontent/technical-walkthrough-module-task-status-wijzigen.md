Deze walkthrough beschrijft hoe een module de status van de `Task` waarvoor zij is gelaunched bijwerkt tijdens en na afloop van haar werk. De module gebruikt het access_token verkregen in [Ontvangen van een launch als module](technical-walkthrough-module-launch-ontvangen.html) en schrijft via standaard FHIR R4 REST terug naar de DVA FHIR Resource Server.

### Overzicht

1. **Lees de huidige `Task`** (voor ETag en voor de volledige resource).
2. **Werk `Task.status` bij** via `PUT`, met `If-Match` voor optimistic locking.
3. **Optioneel**: schrijf bij completion ook `Task.output` (referenties naar resultaten zoals een `QuestionnaireResponse`).

### Voorwaarden

- Access_token uit de SMART-flow is beschikbaar en geldig.
- Scope `patient/Task.write` (of enger) is toegekend.
- De module kent het `Task.id` uit de launch-context (`patient` en eventueel een resource-referentie uit Token Exchange response).

### Stap 1 — Lees de huidige Task

Voor optimistic locking en om de volledige resource te hebben voor een `PUT`, haal je de Task eerst op.

#### Parameters

* `iss`, de DVA FHIR base URL.
* `taskId`, het id uit de launch-context.
* `accessToken`, Bearer access_token.

```typescript
async function getTask(iss: string, taskId: string, accessToken: string) {
    const resp = await fetch(`${iss}/Task/${taskId}`, {
        headers: {
            Authorization: `Bearer ${accessToken}`,
            Accept: "application/fhir+json",
        },
    });
    if (!resp.ok) {
        throw new Error(`GET /Task/${taskId} failed: ${resp.status}`);
    }
    const etag = resp.headers.get("ETag");
    const task = await resp.json();
    return { task, etag };
}
```

#### Response value

* De FHIR `Task`-resource en de `ETag` header (nodig voor `If-Match` in Stap 2).

##### Example

```http
HTTP/1.1 200 OK
Content-Type: application/fhir+json
ETag: W/"3"

{
    "resourceType": "Task",
    "id": "456",
    "status": "requested",
    "intent": "order",
    "for": { "reference": "Patient/789" },
    "instantiatesCanonical": "ActivityDefinition/copd-questionnaire"
}
```

### Stap 2 — Werk Task.status bij via PUT

De module wijzigt `Task.status` op de volledige resource en schrijft die terug via `PUT`. De `If-Match` header met de ETag uit Stap 1 beschermt tegen conflicten bij gelijktijdige schrijvers.

De toegestane waardes voor `Task.status` zijn gedefinieerd in de [FHIR Task valueset](http://hl7.org/fhir/R4/valueset-task-status.html). Typische life cycle voor een module:

`requested` → `received` → `accepted` → `in-progress` → `completed` (of `failed`, `cancelled`).

#### Parameters

* `iss`, de DVA FHIR base URL.
* `task`, de volledige Task-resource uit Stap 1, met het aangepaste `status`-veld.
* `etag`, de ETag uit Stap 1.
* `accessToken`, Bearer access_token.

```typescript
async function putTask(
    iss: string,
    task: any,
    etag: string,
    accessToken: string,
) {
    const resp = await fetch(`${iss}/Task/${task.id}`, {
        method: "PUT",
        headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/fhir+json",
            "If-Match": etag,
            Accept: "application/fhir+json",
        },
        body: JSON.stringify(task),
    });
    if (!resp.ok) {
        throw new Error(`PUT /Task/${task.id} failed: ${resp.status}`);
    }
    return resp.json();
}

// Gebruik:
// const { task, etag } = await getTask(iss, "456", accessToken);
// task.status = "in-progress";
// await putTask(iss, task, etag, accessToken);
```

#### Response value

* `200 OK` (of `201 Created` bij first write) met de bijgewerkte resource en nieuwe `ETag`.
* `409 Conflict` als de `If-Match` niet matcht — lees de resource opnieuw en probeer nogmaals.
* `422 Unprocessable Entity` bij een niet-toegestane status-transitie (door DVA business rules).

### Stap 3 — Optioneel: Task.output schrijven bij completion

Bij afronden van een vragenlijst of meting kan de module het resultaat als aparte FHIR resource plaatsen (bv. `QuestionnaireResponse`) en de referentie daarnaar toevoegen aan `Task.output` in dezelfde of een opvolgende update.

```typescript
// Voorbeeld: volledige Task met output bij completion
task.status = "completed";
task.output = [
    {
        type: { text: "questionnaire-response" },
        valueReference: { reference: "QuestionnaireResponse/abc-123" },
    },
];
await putTask(iss, task, etag, accessToken);
```

De `QuestionnaireResponse` zelf wordt typisch eerst via `POST /QuestionnaireResponse` aangemaakt; de referentie daaruit gaat dan naar `Task.output`.

### Discussie

Openstaand: `PUT` vs. `PATCH`. In deze walkthrough wordt `PUT` gebruikt conform de [MedMij-R4-KoppelMij Technical Design](https://simplifier.net/guide/medmij-r4-provider-module-ig/) prozabeschrijving. De overzichtstabel in datzelfde document noemt echter `PATCH [base]/Task/[id]`. Deze tegenstrijdigheid in de bron moet worden opgelost; tot die tijd gaan we uit van `PUT` als de standaard schrijfmethode voor Task-statuswijzigingen.

Openstaand: welke status-transities zijn door de DVA afgedwongen? FHIR Task staat meer overgangen toe dan in een module-context zinvol is. Voorstel: DVA valideert de life cycle `requested` → `accepted` → `in-progress` → `completed`/`failed`/`cancelled` en weigert andere.

Openstaand: modelleringsvraag rond `Task.output`. De FHIR-specificatie laat veel vrijheid in `output.type.text` — afstemming met Koppeltaal-profielen is wenselijk.
