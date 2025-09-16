# Het gebruik van Koppeltaal Domeinen in de context van KoppelMij

Het uitgangspunt van de KoppelMij startnotitie is dat er vanuit het perspectief van de moduleleverancier onderzocht wordt of met dezelfde standaarden en afspraken het mogelijk is modules aan te bieden vanuit een PGO binnen MedMij. Daarnaast staat er in de notitie dat het ook mogelijk moet zijn dezelfde modules via andere kanalen aan te bieden. Tevens blijkt het juridisch onderzoek / aanbevelingen dat het wenselijk is meerdere kanalen de module te kunnen ontsluiten. Vervoegelijk is ervan uitgegaan dat deze tweede ingang vanuit de achterliggende systemen van de zorgaanbieder komt.

## Optie 1: DVA en achterliggende systemen

Optie 1: Taken worden aangemaakt in de DVA omgeving, inclusief de achterliggende systemen. Dit is de 0 lijn voor de PoCs, hier gaan we ervanuit dat de PGO een systeem ontsluit dat in staat is taken aan te maken.

### Workflow:
- Zorgaanbieder maakt in een achterliggend systeem een taak aan
- DVA laat deze zien bij het "verzamelen taken"
- PGO start de taak met een launch naar de module
- Module haalt de taak op bij de DVA en doet eventueel een update
- PGO verzamelt en ziet de updates

### Architectuur
Bij deze optie is de DVA volledig verantwoordelijk voor het beheer van taken. De architectuur is relatief eenvoudig met een directe koppeling tussen DVA, PGO en module. Dit is de basisimplementatie zoals voorzien in de KoppelMij standaard.

<img src="koppeltaal/optie1.png" alt="Optie 1 Architectuur" style="width: 100%; float: none;"/>

## Optie 2: EPD als bron

Optie 2: Taken worden aangemaakt in de DVA omgeving en maakt hier gebruik van een EPD om dit te realiseren. Dit is een integratie die vooralsnog niet binnen een standaard valt.

### Workflow:
- Zorgaanbieder maakt in een EPD een taak aan
- DVA laat deze zien bij het "verzamelen taken", doet dit door bij het EPD de taken voor de client / zorgaanbieder op te halen
- PGO start de taak met een launch naar de module
- Module haalt de taak op bij de DVA en doet eventueel een update
- De DVA stuurt de update naar het EPD
- PGO verzamelt en ziet de updates

### Overwegingen
Deze optie vereist een niet-gestandaardiseerde integratie tussen de DVA en het EPD. De DVA fungeert als een tussenlaag die taken synchroniseert tussen het EPD en de PGO/module omgeving. Dit kan leiden tot complexiteit in de synchronisatie en mogelijk inconsistenties bij concurrent updates.

### Architectuur

<img src="koppeltaal/optie2.png" alt="Optie 2 Architectuur" style="width: 100%; float: none;"/>

## Optie 3: Koppeltaal als bron

Optie 3: Zowel een Koppeltaal domein als een MedMij zorgaanbieding coëxisteren. In dit geval worden taken (primair) aangemaakt in het EPD en opgeslagen in de FHIR resource service van het koppeltaaldomein. In dat geval wordt de koppeling tussen de Koppeltaal FHIR service met de DVA gemaakt, en zou dit onderhevig kunnen zijn aan enige vorm van standaardisatie. De DVA zou dan de taken kunnen ophalen en updaten in de context van de PGO sessie van de gebruiker. De module kent in dit scenario twee SMART on FHIR "ingangen", de via de PGO in de context van de gebruiker en via het patiëntportaal in de context van het koppeltaaldomein.

### Vragen die hier opkomen zijn:
- **Hoe gaat de moduleapplicatie om met twee verschillende databronnen en vooral twee verschillende achterliggende authorisatiemodellen:**
  - KoppelMij: autorisatie op persoonsniveau
  - Koppeltaal: autorisatie op applicatieniveau
- **Hoe werkt de synchronisatie tussen DVA en Koppeltaal FHIR service, vooral rond potentiële concurrent updates?**
- **Begrijpt de gebruiker de twee ingangen?**

### Workflow:
- Zorgaanbieder maakt in een EPD een taak aan, deze wordt in de koppeltaal FHIR voorziening opgeslagen
- DVA laat deze zien bij het "verzamelen taken", doet dit door bij de FHIR resource service van Koppeltaal de taken voor de patiënt / zorgaanbieder op te halen
- PGO start de taak met een launch naar de module
- Module haalt de taak op bij de DVA en doet eventueel een update
- De DVA stuurt de update naar de FHIR resource service van Koppeltaal
- Het EPD ontvangt een notificatie van de update van de Taak
- PGO verzamelt en ziet de updates

### Complexiteit en uitdagingen
Deze optie introduceert significante complexiteit door het samenbrengen van twee verschillende ecosystemen:
- **Dubbele autorisatiemodellen**: De module moet beide autorisatiemodellen ondersteunen
- **Synchronisatie uitdagingen**: Bidirectionele synchronisatie tussen DVA en Koppeltaal FHIR service
- **Gebruikersverwarring**: Twee verschillende toegangspunten voor dezelfde functionaliteit

### Architectuur

<img src="koppeltaal/optie3.png" alt="Optie 3 Architectuur" style="width: 100%; float: none;"/>

## Optie 4: DVA biedt een decentrale koppeltaalvoorziening aan

Optie 4: DVA biedt zowel een decentrale koppeltaalvoorziening als een KoppelMij voorziening aan. Dit maakt het mogelijk om vanuit de DVA zowel modules, EPDs en Patiëntenportalen via de koppeltaalstandaard te koppelen, als PGO's en modules via de KoppelMij standaard.

### Workflow:
- Zorgaanbieder maakt in een EPD een taak aan, deze wordt in de koppeltaal FHIR service in het koppeltaaldomein zichtbaar
- DVA laat deze zien bij het "verzamelen taken", doet dit door de taken voor de patiënt / zorgaanbieder op te halen
- Het patiëntportaal of PGO start de taak met een launch naar de module
- Module haalt de taak op bij de FHIR resource en doet eventueel een update
- De DVA stuurt de update naar de FHIR resource service van de DVA
- Het EPD ontvangt een notificatie van de update van de Taak
- PGO verzamelt en ziet de updates

### Voordelen
- **Geïntegreerde oplossing**: De DVA wordt het centrale punt voor beide standaarden
- **Vereenvoudigde architectuur**: Geen externe synchronisatie nodig tussen verschillende systemen
- **Flexibiliteit**: Ondersteuning voor zowel Koppeltaal als KoppelMij ecosystemen

### Uitdagingen
- **Complexiteit DVA implementatie**: De DVA moet beide standaarden volledig implementeren
- **Onderhoudskosten**: Hogere complexiteit betekent hogere onderhoudskosten
- **Standaardisatie**: Mogelijke afwijkingen van beide standaarden om integratie mogelijk te maken

### Architectuur

<img src="koppeltaal/optie4.png" alt="Optie 4 Architectuur" style="width: 100%; float: none;"/>

## Optie 5: DVA met dubbele launch mogelijkheid

Optie 5: De DVA voorziet naast een launch voor de patiënt via de PGO ook een launch voor het behandelportaal. Het behandelportaal kan gestart worden in de context van de cliënt, waarbij de behandelaar taken voor de cliënt kan aanmaken en beheren.

### Workflow:
- Zorgaanbieder start het behandelportaal via de DVA in de context van de cliënt
- Behandelaar maakt in het behandelportaal een taak aan voor de cliënt
- DVA slaat de taak op en maakt deze beschikbaar voor verzameling
- PGO haalt taken op bij de DVA en toont deze aan de patiënt
- Patiënt start de taak met een launch naar de module
- Module haalt de taak op bij de DVA en voert updates uit
- Zowel PGO als behandelportaal kunnen de updates zien

### Voordelen
- **Directe toegang behandelaar**: Behandelaar kan direct in de context van de cliënt werken
- **Geïntegreerde werkstroom**: Taken worden centraal beheerd in de DVA
- **Flexibele toegang**: Zowel patiënt (via PGO) als behandelaar (via behandelportaal) hebben toegang
- **Eenvoudige architectuur**: Alle componenten communiceren via de DVA

### Uitdagingen
- **Dubbele launch implementatie**: DVA moet launches voor zowel PGO als behandelportaal ondersteunen
- **Autorisatie complexiteit**: Verschillende autorisatieniveaus voor patiënt en behandelaar
- **Context beheer**: DVA moet de juiste context doorgeven aan beide portalen

### Architectuur

<img src="koppeltaal/optie5.png" alt="Optie 5 Architectuur" style="width: 100%; float: none;"/>

## Vergelijking van opties

| Aspect                  | Optie 1   | Optie 2   | Optie 3        | Optie 4        | Optie 5        |
|-------------------------|-----------|-----------|----------------|----------------|----------------|
| **Complexiteit**        | Laag      | Middel    | Hoog           | Hoog           | Middel         |
| **Standaardisatie**     | Volledig  | Geen      | Deels          | Deels          | Volledig       |
| **Flexibiliteit**       | Beperkt   | Middel    | Hoog           | Zeer hoog      | Hoog           |
| **Integratie EPD**      | Geen      | Custom    | Via Koppeltaal | Via Koppeltaal | Niet nodig     |
| **Onderhoudskosten**    | Laag      | Middel    | Hoog           | Zeer hoog      | Middel         |
| **Gebruikerservaring**  | Eenvoudig | Eenvoudig | Complex        | Middel         | Eenvoudig      |
| **Behandelaar toegang** | Geen      | Via EPD   | Via portaal    | Via portaal    | Direct via DVA |

## Aanbevelingen

Bij het kiezen tussen deze opties zijn de volgende overwegingen belangrijk:

1. **Huidige infrastructuur**: Welke systemen zijn al aanwezig en hoe kunnen deze het beste geïntegreerd worden?

2. **Toekomstige schaalbaarheid**: Is er behoefte aan ondersteuning voor beide ecosystemen (Koppeltaal en KoppelMij)?

3. **Complexiteit vs. functionaliteit**: De meer complexe opties bieden meer functionaliteit maar tegen hogere implementatie- en onderhoudskosten.

4. **Standaardisatie**: Opties die afwijken van gevestigde standaarden kunnen leiden tot interoperabiliteitsproblemen en hogere onderhoudskosten.

5. **Gebruikerservaring**: Complexere architecturen kunnen leiden tot verwarring bij eindgebruikers, vooral wanneer er meerdere toegangspunten zijn.

De keuze hangt sterk af van de specifieke context en requirements van de implementatie. Voor een eerste implementatie is Optie 1 waarschijnlijk het meest haalbaar, terwijl Optie 4 de meeste flexibiliteit biedt voor organisaties die beide ecosystemen willen ondersteunen.
