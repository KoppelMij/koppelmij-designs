
### Inleiding

Bij het lanceren van modules vanuit een PGO is het essentieel om een goede gebruikerservaring te bieden bij het afsluiten van de module. De gebruiker moet op een intuïtieve manier terug kunnen keren naar de PGO context waar de module vandaan werd gestart. Dit document beschrijft de verschillende opties voor module integratie en de bijbehorende terugkeer mechanismen.

### Module Integratie Opties

Modules kunnen op drie verschillende manieren worden geïntegreerd in de PGO gebruikersinterface:

#### 1. Iframe Integratie
De module wordt geladen binnen een iframe in de PGO interface.

#### 2. Zelfde Window
De module vervangt de huidige PGO pagina in hetzelfde browser window.

#### 3. Nieuw Tabblad
De module opent in een nieuw browser tabblad of window.

### Terugkeer Mechanismen per Integratie Type

#### 1. Iframe Integratie

**Kenmerken:**
- Module draait binnen de PGO context
- PGO behoudt controle over de gebruikersinterface
- Terugkeer is impliciet - gebruiker blijft in PGO

**Terugkeer mechanisme:**
- **Sluiten button**: PGO biedt een sluiten button buiten de iframe
- **PostMessage API**: Module kan via window.postMessage communiceren met PGO
- **Event handling**: PGO luistert naar specifieke events van de module

**Voorbeeld PostMessage implementatie:**
```javascript
// Module stuurt bericht bij afsluiten
window.parent.postMessage({
  type: 'module-close',
  status: 'completed',
  data: {
    taskId: '123',
    outcome: 'success'
  }
}, '*'); // In productie: gebruik specifieke origin

// PGO luistert naar berichten
window.addEventListener('message', (event) => {
  if (event.data.type === 'module-close') {
    // Verwijder iframe of verberg module container
    closeModuleIframe();
  }
});
```

**Voordelen:**
- Naadloze integratie
- Geen navigatie vereist
- PGO behoudt sessie en context

**Nadelen:**
- Beperkte schermruimte
- Mogelijke compatibiliteitsproblemen
- Security overwegingen (sandbox attributen)

#### 2. Zelfde Window met return_url

**Kenmerken:**
- Module vervangt volledig de PGO interface
- Vereist expliciete terugkeer navigatie
- return_url wordt meegegeven in FHIR context

**⚠️ BELANGRIJKE SECURITY WAARSCHUWING:**
De token response met het access_token wordt ALLEEN verwerkt door de module backend server en mag NOOIT gedeeld worden met de browser/frontend. De module backend extraheert veilige context informatie (zoals return_url) en stuurt alleen deze naar de frontend.

**Terugkeer mechanisme:**
De `return_url` parameter wordt meegegeven als onderdeel van de FHIR context tijdens de module launch. De module backend verwerkt deze informatie en maakt deze beschikbaar voor de frontend zonder het access_token te exposeren:

##### Optie A: Direct in token response (backend-only)
```json
{
  "access_token": "[GEHEIM - alleen backend]",
  "patient": "123",
  "resource": "Task/789",
  "return_url": "https://pgo.example.com/patient/123/modules?task=789&status=active"
}
```
**Let op**: Het `access_token` wordt NOOIT naar de frontend/browser gestuurd!

##### Optie B: Via authorization_details (experimenteel, backend-only)
```json
{
  "access_token": "[GEHEIM - alleen backend]",
  "authorization_details": [{
    "type": "fhir_context",
    "locations": ["https://fhir.example.org"],
    "patient": "123",
    "resource": "Task/789",
    "return_url": "https://pgo.example.com/patient/123/modules?task=789"
  }]
}
```
**Let op**: Het `access_token` wordt NOOIT naar de frontend/browser gestuurd!

**Module backend implementatie:**
```python
# Python voorbeeld - backend verwerkt token response
def handle_token_response(token_response):
    """
    Deze functie draait op de module backend server,
    NIET in de browser/frontend
    """
    # Extract veilige context informatie voor frontend
    safe_context = {
        'patient_id': token_response.get('patient'),
        'task_id': token_response.get('resource'),  # bijv. "Task/789"
        'return_url': token_response.get('return_url')
    }

    # Sla access_token veilig op in server sessie
    session['access_token'] = token_response['access_token']

    # Stuur alleen veilige context naar frontend
    # NOOIT het access_token
    return safe_context
```

**Module frontend implementatie:**
```javascript
// Frontend krijgt alleen veilige context info van backend
let moduleContext = null;

// Haal context op van module backend (niet direct van DVA)
async function initializeModule() {
  const response = await fetch('/api/module/context', {
    credentials: 'include' // Gebruik sessie cookies
  });
  moduleContext = await response.json();
  // moduleContext bevat return_url maar GEEN access_token
}

// Bij afsluiten module
function closeModule(status = 'completed') {
  if (moduleContext && moduleContext.return_url) {
    // Voeg optioneel status parameter toe
    const url = new URL(moduleContext.return_url);
    url.searchParams.append('module_status', status);
    url.searchParams.append('timestamp', new Date().toISOString());

    // Navigeer terug naar PGO
    window.location.href = url.toString();
  } else {
    // Fallback: toon melding aan gebruiker
    alert('Sluit dit venster om terug te keren naar uw PGO');
  }
}

// FHIR calls gaan via module backend, nooit direct vanuit browser
async function getFHIRResource(resourceType, id) {
  // Backend gebruikt opgeslagen access_token
  const response = await fetch(`/api/fhir/${resourceType}/${id}`, {
    credentials: 'include'
  });
  return response.json();
}
```

**URL constructie door PGO:**
```javascript
// PGO genereert return_url tijdens Token Exchange
function generateReturnUrl(taskId, patientId) {
  const baseUrl = 'https://pgo.example.com';
  const returnPath = `/patient/${patientId}/modules`;

  const params = new URLSearchParams({
    task: taskId,
    session: generateSessionToken(),
    return_timestamp: new Date().toISOString()
  });

  return `${baseUrl}${returnPath}?${params.toString()}`;
}
```

**Voordelen:**
- Volledige schermruimte voor module
- Eenvoudige implementatie
- Duidelijke navigatie flow

**Nadelen:**
- PGO verliest context tijdens module uitvoering
- Gebruiker kan navigatie onderbreken
- Sessie management complexiteit

#### 3. Nieuw Tabblad

**Kenmerken:**
- Module opent in separaat browser tabblad
- PGO blijft open in originele tabblad
- Gebruiker kan tussen tabbladen schakelen

**Terugkeer mechanisme:**
- **Window.close()**: Module sluit eigen tabblad
- **Return_url met window.opener**: Communicatie met parent window
- **BroadcastChannel API**: Cross-tab communicatie

**Voorbeeld implementatie met BroadcastChannel:**
```javascript
// PGO luistert naar module status updates
const channel = new BroadcastChannel('module-communication');

channel.addEventListener('message', (event) => {
  if (event.data.type === 'module-closed') {
    // Update UI om module status te tonen
    updateModuleStatus(event.data.taskId, event.data.status);

    // Focus PGO tabblad (optioneel)
    window.focus();
  }
});

// Module stuurt bericht bij afsluiten
function closeModuleTab() {
  const channel = new BroadcastChannel('module-communication');

  channel.postMessage({
    type: 'module-closed',
    taskId: getCurrentTaskId(),
    status: 'completed',
    timestamp: new Date().toISOString()
  });

  // Sluit het tabblad
  window.close();
}
```

**Window.opener alternatief:**
```javascript
// Module communiceert met opener window
function notifyAndClose() {
  if (window.opener && !window.opener.closed) {
    // Roep functie aan in PGO window
    window.opener.postMessage({
      type: 'module-complete',
      taskId: '789'
    }, 'https://pgo.example.com');
  }

  // Sluit module tabblad
  setTimeout(() => window.close(), 100);
}
```

**Voordelen:**
- PGO blijft beschikbaar
- Gebruiker kan heen en weer schakelen
- Geen context verlies in PGO

**Nadelen:**
- Pop-up blockers kunnen problemen veroorzaken
- Gebruiker kan tabbladen kwijtraken
- Complexere communicatie tussen windows

### Security Overwegingen

#### Return URL Validatie

De DVA moet return_url's valideren om open redirect kwetsbaarheden te voorkomen:

```javascript
// DVA valideert return_url tijdens Token Exchange
function validateReturnUrl(returnUrl, allowedDomains) {
  try {
    const url = new URL(returnUrl);

    // Controleer protocol
    if (!['https:', 'http:'].includes(url.protocol)) {
      return false;
    }

    // Controleer tegen whitelist van toegestane domeinen
    const isAllowed = allowedDomains.some(domain => {
      return url.hostname === domain ||
             url.hostname.endsWith(`.${domain}`);
    });

    if (!isAllowed) {
      throw new Error(`Return URL domain niet toegestaan: ${url.hostname}`);
    }

    return true;
  } catch (error) {
    console.error('Return URL validatie fout:', error);
    return false;
  }
}
```

#### CORS en Origin Policies

Voor iframe en cross-window communicatie:

```javascript
// Strikte origin controle voor postMessage
window.addEventListener('message', (event) => {
  // Valideer origin
  const trustedOrigins = ['https://module1.example.com', 'https://module2.example.com'];

  if (!trustedOrigins.includes(event.origin)) {
    console.warn('Bericht van niet-vertrouwde origin:', event.origin);
    return;
  }

  // Verwerk bericht
  handleModuleMessage(event.data);
});
```

### Aanbevelingen

#### Keuze Matrix

| Scenario                            | Aanbevolen Integratie | Terugkeer Mechanisme              |
|-------------------------------------|-----------------------|-----------------------------------|
| Eenvoudige module, korte interactie | Iframe                | PostMessage + close button        |
| Complexe module, volledige UI nodig | Zelfde window         | return_url in FHIR context        |
| Module naast PGO workflow           | Nieuw tabblad         | BroadcastChannel of window.opener |
| Gevoelige data, strikte security    | Zelfde window         | return_url met sessie validatie   |

#### Best Practices

1. **Altijd een fallback bieden**
   - Als return_url ontbreekt, toon instructies aan gebruiker
   - Bied alternatieve terugkeer opties

2. **Status informatie meegeven**
   - Voeg module completion status toe aan return navigatie
   - Include timestamp voor audit logging

3. **Sessie continuïteit waarborgen**
   - Gebruik sessie tokens in return_url
   - Implementeer sessie timeout handling

4. **Gebruiker informeren**
   - Toon duidelijke navigatie indicatoren
   - Waarschuw bij verlaten van module zonder opslaan

### Implementatie Richtlijnen

#### Voor PGO Ontwikkelaars

1. **Bepaal integratie strategie** op basis van:
   - Module complexiteit
   - Security vereisten
   - Gebruikerservaring doelen

2. **Implementeer robuuste return handling**:
   - Valideer return parameters
   - Update UI om module status te reflecteren
   - Log navigatie events voor audit

3. **Test verschillende scenarios**:
   - Normale flow
   - Gebruiker onderbreekt flow
   - Sessie timeout
   - Network fouten

#### Voor Module Ontwikkelaars

1. **Ondersteun meerdere terugkeer mechanismen**:
   - Check voor return_url in context
   - Implementeer postMessage voor iframe scenario's
   - Bied UI fallback optie

2. **Communiceer status duidelijk**:
   - Stuur completion events
   - Include relevante data in return navigatie
   - Handel errors gracefully af

### Conclusie

De keuze voor een terugkeer mechanisme hangt af van de specifieke integratie methode en use case requirements. Door return_url op te nemen in de FHIR context bieden we een gestandaardiseerde oplossing voor het "zelfde window" scenario, terwijl andere integratie types hun eigen optimale terugkeer strategieën hebben.

Het is essentieel dat zowel PGO's als modules flexibel zijn in hun implementatie en meerdere terugkeer mechanismen ondersteunen om de beste gebruikerservaring te kunnen bieden in verschillende contexten.
