# Het gebruik van Koppeltaal Domeinen in de context van KoppelMij

Het uitgangspunt van de KoppelMij startnotitie is dat er vanuit het perspectief van de moduleleverancier onderzocht wordt of met dezelfde standaarden en afspraken het mogelijk is modules aan te bieden vanuit een PGO binnen MedMij. Daarnaast staat er in de notitie dat het ook mogelijk moet zijn dezelfde modules via andere kanalen aan te bieden. Tevens blijkt het juridisch onderzoek / aanbevelingen dat het wenselijk is meerdere kanalen de module te kunnen ontsluiten. Vervoegelijk is ervan uitgegaan dat deze tweede ingang vanuit de achterliggende systemen van de zorgaanbieder komt.

## Optie 0: DVA en achterliggende systemen

Optie 0: Het uitgangspunt bij deze optie is dat de plaats en het systeem waar de taak wordt aangemaakt buiten het KoppelMij stelsel ligt. Het KoppelMij stelsel doet geen uitspraken over waar of hoe de taak wordt aangemaakt - dit kan in een Xis (zorginformatiesysteem), een Koppeltaal domein, of een ander achterliggend systeem zijn. De DVA ontsluit deze taken naar de PGO, ongeacht hun oorsprong. Dit is de basislijn voor de PoCs, waarbij we ervanuit gaan dat de PGO een systeem ontsluit dat in staat is taken te tonen en te lanceren.

### Workflow:
- Zorgaanbieder maakt in een achterliggend systeem een taak aan
- DVA laat deze zien bij het "verzamelen taken"
- PGO start de taak met een launch naar de module
- Module haalt de taak op bij de DVA en doet eventueel een update
- PGO verzamelt en ziet de updates

### Architectuur
Bij deze optie is de DVA volledig verantwoordelijk voor het beheer van taken. De architectuur is relatief eenvoudig met een directe koppeling tussen DVA, PGO en module. Dit is de basisimplementatie zoals voorzien in de KoppelMij standaard.

<img src="koppeltaal/optie0.png" alt="Optie 1 Architectuur" style="width: 100%; float: none;"/>

## Optie 1: Coëxistentie Xis en Koppeltaal
In deze optie kunnen taken worden aangemaakt in zowel een Koppeltaal domein als in een extern systeem (Xis). De module moet in dit scenario omgaan met taken uit beide bronnen. Het verschil tussen optie 1a en 1b ligt in de architectuur van de FHIR bron.

## Optie 1a: Coëxistentie Xis en Koppeltaal (Xis als FHIR bron)

Optie 1a: In dit model fungeert een applicatie binnen koppeltaal als FHIR bron. De DVA communiceert rechtstreeks met de applicatie voor het ophalen en updaten van taken.

### Workflow:
- Zorgaanbieder maakt in een koppeltaal applicatie een taak aan
- DVA laat deze zien bij het "verzamelen taken", doet dit door bij het de koppeltaal applicatie de taken voor de client / zorgaanbieder op te halen
- PGO start de taak met een launch naar de module
- Module haalt de taak op bij de DVA en doet eventueel een update
- De DVA stuurt de update naar het EPD
- PGO verzamelt en ziet de updates

### Overwegingen
Deze optie vereist een niet-gestandaardiseerde integratie tussen de DVA en het EPD. De DVA fungeert als een tussenlaag die taken synchroniseert tussen het EPD en de PGO/module omgeving. Dit kan leiden tot complexiteit in de synchronisatie en mogelijk inconsistenties bij concurrent updates. Verder is het zo dat het koppeltaal domein niet de enige bron is van de taken is, de module applicatie kan er niet van uitgaan dat koppeltaal de enige bron van de FHIR resources is

### Architectuur

<img src="koppeltaal/optie1a.png" alt="Optie 2a Architectuur" style="width: 100%; float: none;"/>

## Optie 1b: Coëxistentie Xis en Koppeltaal (DVA als deelnemer)

Optie 1b: In dit model is de FHIR resource service van Koppeltaal de  FHIR bron. De DVA wordt deelnemer in het Koppeltaal domein en communiceert met de Koppeltaal FHIR resource service voor het ophalen en updaten van taken. Dit betekent dat de DVA zich conformeert aan de Koppeltaal standaard als deelnemende applicatie. Verder is het zo dat het koppeltaal domein niet de enige bron is van de taken is, de module applicatie kan er niet van uitgaan dat koppeltaal de enige bron van de FHIR resources is.

### Architectuur

<img src="koppeltaal/optie1b.png" alt="Optie 2 Architectuur" style="width: 100%; float: none;"/>

## Optie 2: Volledige en exclusieve koppeling met een Koppeltaal domein
> ⚠️ **Deze optie(s) voldoet niet aan de uitgangspunten van KoppelMij, omdat deze de aanwezigheid van een koppeltaaldomein _vereist_. Dit houdt in dat een Koppeltaal domein altijd aanwezig en actief moet zijn om de beschreven alternatieven te laten werken. Daarmee wordt niet gesteld dat koppelingen met koppeltaal niet in andere scenario's mogelijk zijn.**

## Optie 2a: Volledige en exclusieve koppeling met een koppeltaal domein

Optie 2a: Zowel een Koppeltaal domein als een MedMij zorgaanbieding coëxisteren. In dit geval worden taken (primair) aangemaakt in het EPD en opgeslagen in de FHIR resource service van het koppeltaaldomein. In dat geval wordt de koppeling tussen de Koppeltaal FHIR service met de DVA gemaakt, en zou dit onderhevig kunnen zijn aan enige vorm van standaardisatie. De DVA zou dan de taken kunnen ophalen en updaten in de context van de PGO sessie van de gebruiker. De module kent in dit scenario twee SMART on FHIR "ingangen", de via de PGO in de context van de gebruiker en via het patiëntportaal in de context van het koppeltaaldomein.

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

<img src="koppeltaal/optie2a.png" alt="Optie 3 Architectuur" style="width: 100%; float: none;"/>

## Optie 2b: Volledige en exclusieve koppeling met een decentrale koppeltaal voorziening

Optie 2a: DVA biedt zowel een decentrale koppeltaalvoorziening als een KoppelMij voorziening aan. Dit maakt het mogelijk om vanuit de DVA zowel modules, EPDs en Patiëntenportalen via de koppeltaalstandaard te koppelen, als PGO's en modules via de KoppelMij standaard.

### Workflow:
- Zorgaanbieder maakt in een EPD of behandelportaal een taak aan, deze wordt in de koppeltaal FHIR service in het koppeltaaldomein zichtbaar
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

<img src="koppeltaal/optie2b.png" alt="Optie 4 Architectuur" style="width: 100%; float: none;"/>

## Optie 3: Harmonisatie van autorisatie, authenticatie en standaarden

Optie 3: Een geharmoniseerde aanpak waarbij het autorisatiemodel per type gebruiker wordt vastgelegd en via SMART on FHIR app launch wordt geëffectueerd. Dit model wordt op termijn geharmoniseerd met Koppeltaal, waardoor coëxistentie van twee verschillende afsprakenstelsels niet vanuit het afsprakenstelsel noodzakelijk is. Indien gewenst kan coëxistentie altijd geïmplementeerd worden door bijvoorbeeld een DVA die ook in een Koppeltaal domein actief is. Alle applicaties worden gestart met SMART on FHIR app launch in de juiste gebruikerscontext, waardoor het proces uniform wordt voor leveranciers van zowel module- als portaalapplicaties.

### Kernprincipe
Door het harmoniseren van het FHIR model, het authenticatie mechanisme en het autorisatiemodel wordt een harmonisatie bereikt op het niveau van standaarden, waardoor optimale schaalbaarheid wordt gerealiseerd.

### Workflow:
- DVA of Koppeltaaldomein start applicaties altijd met de juiste SMART on FHIR context:
  - **Patient context**: Voor het Patiënt Portaal
  - **Practitioner context**: Voor het Behandelportaal
  - **Task context**: Voor directe module toegang
- Patiënt EPD, Portaal, Behandelportaal, en PGO kunnen alle drie modules lanceren
- Module ontvangt altijd de juiste context via SMART on FHIR, onafhankelijk van de bron
- Module is agnostisch voor de herkomst (Koppeltaal domein of een KoppelMij zorgaanbieding)
- Updates worden via dezelfde gestandaardiseerde interface afgehandeld

### Voordelen
- **Geen synchronisatie problemen**: Één afsprakenstelsel voorkomt dubbele data en synchronisatie-issues
- **Uniform autorisatiemodel**: Consistent autorisatiemodel voor alle gebruikerstypes
- **Toekomstbestendig**: Convergeert naar één geharmoniseerd systeem
- **Module-agnostisch**: Modules hoeven geen onderscheid te maken tussen verschillende bronnen
- **Vereenvoudigde architectuur**: Alle communicatie via dezelfde SMART on FHIR standaard

### Implementatie aspecten
- **Gefaseerde harmonisatie**: Geleidelijke convergentie van Koppeltaal naar het geharmoniseerde model
- **Standaard-compliant**: Volledig gebaseerd op SMART on FHIR specificaties
- **Context-aware**: Elke launch bevat de juiste gebruikerscontext
- **Eenvoudige integratie**: Modules implementeren één interface voor alle scenario's

### Architectuur

<img src="koppeltaal/optie3.png" alt="Optie 5 Architectuur" style="width: 100%; float: none;"/>

## Vergelijking van opties

| Aspect                  | Optie 0          | Optie 1a         | Optie 1b         | Optie 2a         | Optie 2b         | Optie 3                  |
|-------------------------|------------------|------------------|------------------|------------------|------------------|--------------------------|
| **Complexiteit**        | Laag             | Middel           | Middel           | Hoog             | Hoog             | Laag-Middel              |
| **Standaardisatie**     | KoppelMij        | Deels            | Deels            | Koppeltaal       | Beide            | Volledig (SMART)         |
| **Flexibiliteit**       | Beperkt          | Middel           | Middel           | Hoog             | Zeer hoog        | Zeer hoog                |
| **Integratie EPD**      | Buiten scope     | Via applicatie   | Via Koppeltaal   | Via Koppeltaal   | Via Koppeltaal   | Via geharmoniseerd model |
| **Onderhoudskosten**    | Laag             | Middel           | Middel           | Hoog             | Zeer hoog        | Laag                     |
| **Gebruikerservaring**  | Eenvoudig        | Complex          | Complex          | Complex          | Middel           | Eenvoudig                |
| **Behandelaar toegang** | Via ext. systeem | Via beide        | Via beide        | Via portaal      | Via portaal      | Via context-aware launch |
| **Synchronisatie**      | N.v.t.           | Nodig            | Nodig            | Complex          | Complex          | Niet nodig               |
| **Toekomstbestendig**   | Basis            | Tijdelijk        | Tijdelijk        | Beperkt          | Overgangsfase    | Zeer hoog                |
| **Module complexiteit** | Enkel KoppelMij  | Dubbel model     | Dubbel model     | Dubbel model     | Dubbel model     | Uniform model            |

## Aanbevelingen

Bij het kiezen tussen deze opties zijn de volgende overwegingen belangrijk:

1. **Huidige infrastructuur**: Welke systemen zijn al aanwezig en hoe kunnen deze het beste geïntegreerd worden?

2. **Toekomstige schaalbaarheid**: Is er behoefte aan ondersteuning voor beide ecosystemen (Koppeltaal en KoppelMij)?

3. **Complexiteit vs. functionaliteit**: De meer complexe opties bieden meer functionaliteit maar tegen hogere implementatie- en onderhoudskosten.

4. **Standaardisatie**: Opties die afwijken van gevestigde standaarden kunnen leiden tot interoperabiliteitsproblemen en hogere onderhoudskosten.

5. **Gebruikerservaring**: Complexere architecturen kunnen leiden tot verwarring bij eindgebruikers, vooral wanneer er meerdere toegangspunten zijn.

De keuze hangt sterk af van de specifieke context en requirements van de implementatie. Voor een eerste implementatie is Optie 1 waarschijnlijk het meest haalbaar, terwijl Optie 4 de meeste flexibiliteit biedt voor organisaties die beide ecosystemen willen ondersteunen.
