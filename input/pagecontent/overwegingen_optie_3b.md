# Overwegingen voor de keuze van Optie 3b

Bij het evalueren van de verschillende architectuurbenaderingen voor veilige module launches zijn er verschillende belangrijke overwegingen die hebben geleid tot de keuze voor Optie 3b: DVA-geïnitieerde Module Launch met SMART on FHIR.

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

### Optie 3a: Token Exchange met Gebruikersidentificatie

**Belangrijkste bezwaar: Meerdere login sessies vereist**

Hoewel Optie 3a sterke security biedt en de DVA ruimte geeft voor optimalisaties, vereist het meerdere authenticaties:

- **Herhaalde authenticatie**: Gebruikers zouden zich, in principe, bij elke module launch opnieuw authenticeren
- **DVA kan optimaliseren**: Deze oplossingsrichting biedt de DVA wel de ruimte om voorzieningen te treffen voor verbeterde gebruikerservaring
- **Mogelijke optimalisaties**: DVA kan via een gedoogconstructie gebruik maken van een sessie-cookie of alternatieve manieren van authenticeren.
- **Implementatiedruk**: De DVA moet SMART on FHIR app launch in all aspecten implementeren.
- **Trade-off**: Security versus gebruikerservaring - DVA bepaalt de balans

## Algemeen: Waarom Optie 3b de beste keuze is

Optie 3b lost de bezwaren van de andere opties op door:

### 1. **Respecteert DVA architectuur**
- DVA wordt niet gedwongen vanuit het afsprakenstelsel sessies te beheren
- Past binnen bestaande DVA capabilities
- Gebruikt DVA's natuurlijke rol als data eigenaar en toestemmingshub

### 2. **Behoudt DVA controle over authenticatie**
- DVA kan gebruikers direct authenticeren wanneer nodig
- Flexibele authenticatie strategieën per module
- Volledige audit trail onder DVA controle

### 3. **Schaalbaarheid voor PGO's**
- Eenvoudige PGO integratie (alleen redirect naar Module)
- Geen complexe token exchange implementatie vereist
- Lage drempel voor PGO adoptie

### 4. **Gebruikerservaring**
- Single Sign-On via DVA sessie uit verzamelfase is mogelijk
- Consistente flow voor alle modules

### 5. **Security en Compliance**
- DVA behoudt volledige controle over toegang
- Centrale logging en monitoring



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

### Optie 3a: Token Exchange met Gebruikersidentificatie

**Gebruikers ZONDER langdurige toestemming:**
- PGO login: 1x per PGO sessie
- DVA login tijdens verzamelen: 1x per verzamelsessie
- DVA login tijdens ELKE module launch: 1x per launch
- **Totaal: 2+ logins** (1x PGO + 1x DVA verzamelen + 1x per module)

**Gebruikers MET langdurige toestemming:**
- PGO login: 1x per PGO sessie
- DVA login tijdens verzamelen: 1x per 6 maanden
- DVA login tijdens ELKE module launch: 1x per launch
- **Totaal: 2+ logins** (1x PGO + 1x DVA verzamelen + 1x per module)

### Optie 3b: DVA-geïnitieerde Module Launch (GEKOZEN OPTIE)

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
| **Optie 3a**    | 2+ logins (extra per module)  | 2+ logins (extra per module) |
| **Optie 3b**    | 2 logins/sessie               | 1-2 logins                   |

Optie 3b biedt samen met optie 2a/2b de beste gebruikerservaring qua login frequentie, maar heeft als voordeel dat de DVA controle behoudt over authenticatie.

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

Voor module leveranciers zijn opties 1, 3a en 3b daarom aantrekkelijk: het combineert standaard SMART on FHIR implementatie met optimale gebruikerservaring.


