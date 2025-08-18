# Overwegingen voor de keuze van Optie 3a

Bij het evalueren van de verschillende architectuurbenaderingen voor veilige module launches zijn er verschillende belangrijke overwegingen die hebben geleid tot de keuze voor Optie 3a: Token Exchange met Gebruikersidentificatie.

## Analyse van de alternatieven

### Optie 1: DVA als Authorization Server met Cookie-gebaseerde Browser Correlatie

**Belangrijkste bezwaar: Sessies bij de DVA vereisen is geen reële optie**

De fundamentele uitdaging met Optie 1 is dat de DVA architectuur niet is ontworpen voor het beheren van gebruikerssessies. Dit creëert verschillende problemen:

- **Architectuurconflict**: DVA's zijn typisch stateless services die zich richten op data opslag en toegang, sessie management vanuit het stelsel vereisen verandert dat. Dat sluit niet uit dat de DVA sessie _mag_ gebruiken, deze optie vereist sessies, en dat is niet reëel.
- **Cookie complexiteit**: Het implementeren van cookie-gebaseerde browser correlatie vereist sessie-infrastructuur die misschien niet past bij de DVA architectuur
- **Implementatielast**: DVA's zouden complexe sessie management moeten implementeren voor een functionaliteit die buiten hun kernverantwoordelijkheid valt

### Optie 2a/2b: PGO als Authorization Server

**Belangrijkste bezwaar: DVA heeft geen mogelijkheid de gebruiker te identificeren**

Bij beide Optie 2 varianten fungeert het PGO als authorization server, wat de volgende beperkingen creëert:

- **Authenticatie delegatie**: De DVA moet volledig vertrouwen op de PGO authenticatie zonder eigen verificatie mogelijkheden
- **Security risico's**: DVA kan geen aanvullende authenticatie eisen voor gevoelige operaties of modules
- **Compliance uitdagingen**: Voor bepaalde medische toepassingen kan directe gebruikersverificatie door de DVA vereist zijn
- **Beperkte controle**: DVA heeft geen controle over het authenticatieproces wanneer dit cruciaal is voor bepaalde use cases
- **Standaard deviaties**: Beide opties vereisen significante aanpassingen aan gevestigde standaarden:
  - **SMART on FHIR aanpassingen**: Afwijking van de standaard flow waar de resource server ook de authorization server is
  - **Interoperabiliteit risico's**: Custom implementaties kunnen leiden tot compatibiliteitsproblemen
  - **Onderhoudskosten**: Afwijkingen van standaarden verhogen de complexiteit en onderhoudskosten

### Optie 3a: Token Exchange met Gebruikersidentificatie (GEKOZEN OPTIE)

**Belangrijkste voordeel: Maximale flexibiliteit en controle**

Optie 3a biedt de beste balans tussen security, flexibiliteit en gebruikerservaring:

- **Flexibele authenticatie**: DVA heeft volledige controle over authenticatie-strategieën
- **DVA kan optimaliseren**: Deze oplossingsrichting biedt de DVA de ruimte om voorzieningen te treffen voor verbeterde gebruikerservaring
- **Mogelijke optimalisaties**: DVA kan gebruik maken van sessie-cookies of alternatieve authenticatiemethoden
- **Standaard compliance**: Volledige SMART on FHIR implementatie zonder afwijkingen
- **Toekomstbestendig**: DVA kan de implementatie aanpassen aan veranderende requirements

### Optie 3b: DVA-geïnitieerde Module Launch

**Belangrijke overweging: Optie 3a biedt meer flexibiliteit dan optie 3b**

Een cruciaal verschil tussen beide opties betreft de flexibiliteit van de launch uitvoering:

- **Optie 3b**: Dwingt "by design" af dat de launch altijd via de DVA zelf verloopt. Het PGO kan geen directe launch naar de module uitvoeren. De launch URL is vast gekoppeld aan de DVA.
- **Optie 3a**: Biedt de DVA de keuze. De DVA kan ervoor kiezen om:
  - De launch via de DVA zelf te laten verlopen (zoals in optie 3b)
  - Het PGO direct naar de module te laten doorverwijzen met de juiste parameters

**Technisch verschil in URL resolutie:**
- **Optie 3a**: De launch URL wordt flexibel bepaald via de FHIR keten: Task → ActivityDefinition → Endpoint.address. Dit maakt het mogelijk om per module of use case verschillende launch endpoints te configureren, tevens om zoals in optie 3b de launch via de DVA te laten verlopen.
- **Optie 3b**: De launch URL is altijd gefixeerd op de DVA endpoint, waardoor alle launches verplicht via de DVA verlopen.

Dit betekent dat optie 3a alle mogelijkheden van optie 3b behoudt plus additionele flexibiliteit biedt aan de DVA implementatie. De keuze voor optie 3a geeft de DVA maximale vrijheid in de implementatie.

## Algemeen: Waarom Optie 3a de beste keuze is

Optie 3a lost de bezwaren van de andere opties op en biedt unieke voordelen:

### 1. **Maximale flexibiliteit voor DVA**
- DVA kan kiezen tussen verschillende implementatiestrategieën
- Mogelijkheid om zowel directe module launches als DVA-geleide launches te ondersteunen
- Past binnen bestaande DVA capabilities zonder architectuurwijzigingen op te leggen

### 2. **Behoudt DVA controle over authenticatie**
- DVA kan gebruikers direct authenticeren wanneer nodig
- Flexibele authenticatie strategieën per module
- Volledige audit trail onder DVA controle

### 3. **Schaalbaarheid en standaardisatie**
- Volledige SMART on FHIR compliance
- Flexibele URL resolutie via FHIR keten (Task → ActivityDefinition → Endpoint)
- Herbruikbare implementatie voor module leveranciers

### 4. **Gebruikerservaring optimalisatie mogelijk**
- DVA kan sessie-optimalisaties implementeren
- Mogelijkheid voor Single Sign-On indien gewenst
- DVA bepaalt de beste balans tussen security en gebruiksgemak

### 5. **Security en Compliance**
- DVA behoudt volledige controle over toegang en authenticatie
- Centrale logging en monitoring
- Mogelijkheid voor step-up authenticatie waar nodig



## Analyse: Login frequentie

Een belangrijk aspect van de gebruikerservaring is hoe vaak gebruikers moeten inloggen. Hier is een exact overzicht per optie:

### Optie 1: DVA als Authorization Server met Cookie-gebaseerde Browser Correlatie

**Gebruikers ZONDER langdurige toestemming:**
- PGO login: 1x per PGO sessie
- DVA login tijdens verzamelen: 1x per verzamelsessie
- DVA login tijdens module launch: 0x (cookie hergebruik)
- **Totaal: 2 logins per sessie** (1x PGO + 1x DVA)

**Gebruikers MET langdurige toestemming:**
- PGO login: 1x per PGO sessie
- DVA login tijdens verzamelen: 1x per 6 maanden
- DVA login tijdens eerste module launch: 1x (nieuwe cookie wordt gezet)
- Volgende module launches: 0x (cookie hergebruik)
- **Totaal: 2 logins** (1x PGO + 1x DVA bij eerste module)

### Optie 2a/2b: PGO als Authorization Server

**Gebruikers ZONDER langdurige toestemming:**
- PGO login: 1x per PGO sessie
- DVA login tijdens verzamelen: 1x per verzamelsessie
- Module launch: 0x extra login (PGO sessie)
- **Totaal: 2 logins per sessie** (1x PGO + 1x DVA)

**Gebruikers MET langdurige toestemming:**
- PGO login: 1x per PGO sessie
- DVA login tijdens verzamelen: 1x per 6 maanden (al gebeurd)
- Module launch: 0x extra login (PGO sessie)
- **Totaal: 1 login** (alleen PGO login)

### Optie 3a: Token Exchange met Gebruikersidentificatie (GEKOZEN OPTIE)

**Gebruikers ZONDER langdurige toestemming:**
- PGO login: 1x per PGO sessie
- DVA login tijdens verzamelen: 1x per verzamelsessie
- Module launch: 0-1x per launch (DVA kan optimaliseren met sessie)
- **Totaal: 2 logins** (1x PGO + 1x DVA, met mogelijke optimalisaties)

**Gebruikers MET langdurige toestemming:**
- PGO login: 1x per PGO sessie
- DVA login tijdens verzamelen: 1x per 6 maanden
- Module launch: 0-1x per launch (DVA kan optimaliseren)
- **Totaal: 1-2 logins** (flexibel afhankelijk van DVA implementatie)

### Optie 3b: DVA-geïnitieerde Module Launch

**Gebruikers ZONDER langdurige toestemming:**
- PGO login: 1x per PGO sessie
- DVA login tijdens verzamelen: 1x per verzamelsessie
- Module launch: 0x extra login (DVA sessie hergebruik)
- **Totaal: 2 logins per sessie** (1x PGO + 1x DVA)

**Gebruikers MET langdurige toestemming:**
- PGO login: 1x per PGO sessie
- DVA login tijdens verzamelen: 1x per 6 maanden
- Module launch binnen sessie (bijv. 4 uur): 0x extra login
- Module launch na sessie timeout: 1x DVA login
- **Totaal: 1-2 logins** (1x PGO + sporadisch DVA bij sessie timeout)

### Samenvatting login frequentie

| Optie           | Zonder langdurige toestemming | Met langdurige toestemming   |
|-----------------|-------------------------------|------------------------------|
| **Optie 1**     | 2 logins/sessie               | 2 logins                     |
| **Optie 2a/2b** | 2 logins/sessie               | 1 login                      |
| **Optie 3a**    | 2 logins (met optimalisatie)  | 1-2 logins (flexibel)        |
| **Optie 3b**    | 2 logins/sessie               | 1-2 logins                   |

Optie 3a biedt met de juiste optimalisaties een vergelijkbare gebruikerservaring als optie 3b, maar met het cruciale voordeel van maximale flexibiliteit voor de DVA implementatie.

## Analyse: Module leverancier perspectief

Vanuit het perspectief van module leveranciers is de conformiteit aan standaarden cruciaal:

### Standaard conformiteit per optie

**Optie 1, 3a en 3b**: Volledige SMART on FHIR standaard compliance
- Module implementeert standaard SMART launch flow
- Geen custom code of afwijkingen nodig
- Herbruikbare implementatie voor andere projecten

**Optie 2a/2b**: Vereist afwijkingen van SMART on FHIR standaard
- PGO als authorization server terwijl DVA de resource server is
- Non-standaard token exchange implementatie
- Module moet custom logica implementeren
- Verminderde herbruikbaarheid van code
- Hogere onderhoudskosten door afwijkende implementatie

Voor module leveranciers is optie 3a daarom het meest aantrekkelijk: het combineert volledige SMART on FHIR standaard compliance met de flexibiliteit voor optimale gebruikerservaring.


