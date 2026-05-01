Deze walkthrough beschrijft hoe een module de status van de `Task` waarvoor zij is gelaunched bijwerkt tijdens en na afloop van haar werk. De module gebruikt het access_token verkregen in [Ontvangen van een launch als module](technical-walkthrough-module-launch-ontvangen.html) en schrijft via standaard FHIR R4 REST terug naar de DVA FHIR Resource Server.

### Overzicht

1. **Werk `Task.status` bij** via `PATCH` (FHIRPath Patch) — een partiële update die alleen het status-veld wijzigt.
2. **Optioneel**: schrijf bij completion ook `Task.output` (referenties naar resultaten zoals een `QuestionnaireResponse`).

### Voorwaarden

- Access_token uit de SMART-flow is beschikbaar en geldig.
- Scope `patient/Task.write` (of enger) is toegekend.
- De module kent het `Task.id` uit de launch-context (`patient` en eventueel een resource-referentie uit Token Exchange response).

### Stap 1 — Werk Task.status bij via PATCH

De module wijzigt `Task.status` via een `PATCH`-request met een [FHIRPath Patch](https://hl7.org/fhir/R4/fhirpatch.html) payload. Dit stuurt alleen de wijziging, niet de volledige resource — dit voorkomt dat andere velden onbedoeld overschreven worden bij gelijktijdige schrijvers.

De toegestane waardes voor `Task.status` zijn gedefinieerd in de [FHIR Task valueset](http://hl7.org/fhir/R4/valueset-task-status.html). Typische life cycle voor een module:

`requested` → `received` → `accepted` → `in-progress` → `completed` (of `failed`, `cancelled`).

#### Parameters

* `iss`, de DVA FHIR base URL.
* `taskId`, het id uit de launch-context.
* `newStatus`, de nieuwe status-waarde.
* `accessToken`, Bearer access_token.

```typescript
async function patchTaskStatus(
    iss: string,
    taskId: string,
    newStatus: string,
    accessToken: string,
) {
    const patch = {
        resourceType: "Parameters",
        parameter: [
            {
                name: "operation",
                part: [
                    { name: "type", valueCode: "replace" },
                    { name: "path", valueString: "Task.status" },
                    { name: "value", valueCode: newStatus },
                ],
            },
        ],
    };
    const resp = await fetch(`${iss}/Task/${taskId}`, {
        method: "PATCH",
        headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/fhir+json",
            Accept: "application/fhir+json",
        },
        body: JSON.stringify(patch),
    });
    if (!resp.ok) {
        throw new Error(`PATCH /Task/${taskId} failed: ${resp.status}`);
    }
    return resp.json();
}

// Gebruik:
// await patchTaskStatus(iss, "456", "in-progress", accessToken);
// await patchTaskStatus(iss, "456", "completed", accessToken);
```

#### Request body (FHIRPath Patch)

```json
{
    "resourceType": "Parameters",
    "parameter": [
        {
            "name": "operation",
            "part": [
                { "name": "type", "valueCode": "replace" },
                { "name": "path", "valueString": "Task.status" },
                { "name": "value", "valueCode": "completed" }
            ]
        }
    ]
}
```

#### Response value

* `200 OK` met de bijgewerkte resource.
* `422 Unprocessable Entity` bij een niet-toegestane status-transitie (door DVA business rules).

### Stap 2 — Optioneel: Task.output schrijven bij completion

Bij afronden van een vragenlijst of meting kan de module het resultaat als aparte FHIR resource plaatsen (bv. `QuestionnaireResponse`) en de referentie daarnaar toevoegen aan `Task.output`. Hiervoor kan een tweede PATCH-operatie worden gebruikt, of een gecombineerde PATCH die zowel `status` als `output` in één request wijzigt:

```json
{
    "resourceType": "Parameters",
    "parameter": [
        {
            "name": "operation",
            "part": [
                { "name": "type", "valueCode": "replace" },
                { "name": "path", "valueString": "Task.status" },
                { "name": "value", "valueCode": "completed" }
            ]
        },
        {
            "name": "operation",
            "part": [
                { "name": "type", "valueCode": "add" },
                { "name": "path", "valueString": "Task" },
                { "name": "name", "valueString": "output" },
                {
                    "name": "value",
                    "part": [
                        {
                            "name": "type",
                            "valueCodeableConcept": { "text": "questionnaire-response" }
                        },
                        {
                            "name": "valueReference",
                            "valueReference": { "reference": "QuestionnaireResponse/abc-123" }
                        }
                    ]
                }
            ]
        }
    ]
}
```

De `QuestionnaireResponse` zelf wordt typisch eerst via `POST /QuestionnaireResponse` aangemaakt; de referentie daaruit gaat dan naar `Task.output`.

### Discussie

Openstaand: welke status-transities zijn door de DVA afgedwongen? FHIR Task staat meer overgangen toe dan in een module-context zinvol is. Voorstel: DVA valideert de life cycle `requested` → `accepted` → `in-progress` → `completed`/`failed`/`cancelled` en weigert andere.

Openstaand: modelleringsvraag rond `Task.output`. De FHIR-specificatie laat veel vrijheid in `output.type.text` — afstemming met Koppeltaal-profielen is wenselijk.
