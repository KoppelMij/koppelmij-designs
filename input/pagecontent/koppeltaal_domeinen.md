# Het gebruik van Koppeltaal Domeinen in de context van KoppelMij

Het uitgangspunt van de KoppelMij startnotitie is het ontwikkelen van een standaard om Koppeltaal eHealth-interventies (modules) beschikbaar te stellen in MedMij PGO's.

Als achtergrondinfo hierbij de tekst uit paragraaf 2.1 Doelen van de startnotitie:

**Het doel is het beschikbaar stellen van Koppeltaal eHealth-interventies (modules) in MedMij PGO's.**

Daarnaast is een lange termijndoel van de beheerders van beide afsprakenstelsels: harmonisatie van Koppeltaal en MedMij. Harmonisatie in de standaarden is nodig om de volgende redenen:

• Vergroten van de regiefunctie van de patiënt middels een PGO.

• Hergebruik en gedane investering van leveranciers en zorgaanbieders

• De drempel wordt lager om nieuwe leveranciers te laten toetreden

• Bevordering van toepassing hybride zorg met landelijke standaarden sectorbreed

Dit project is een eerste stap in de harmonisatie.

De huidige route voor toegang tot modules via clienten-/patient-portalen voor Zorgaanbieders moet in stand blijven. Een client/patient moet zelf kunnen kiezen of hij de taak voor een module wil starten via het clienten/patientenportaal of via de PGO. Daarnaast moet de module toegankelijk zijn, ook als de PGO tijdelijk niet beschikbaar is. Een Zorgaanbieder heeft immers zorgplicht maar geen zeggenschap over de PGO.

## Belangrijke begrippen en onderscheid

Het is belangrijk onderscheid te maken tussen twee concepten die regelmatig door elkaar heen worden gebruikt:

**Co-existentie:** Het wel of niet vereist zijn van een Koppeltaal domein om de MedMij use cases te realiseren.

**Meervoudige toegang:** Het feit dat modules zowel via KoppelMij als via een andere weg toegankelijk moeten zijn.

Deze zaken worden nu door elkaar heen gebruikt, maar het is van belang ze te onderscheiden. Wel is het zo dat uit Meervoudige toegang foutief Co-existentie kan worden geconcludeerd.

- **Meervoudige toegang** is een functionele eis: modules moeten via meerdere kanalen bereikbaar zijn
- **Co-existentie** is een architecturale vraag: of Koppeltaal domein aanwezig moet zijn voor MedMij functionaliteit

Deze begripsverheldering is essentieel voor het juist interpreteren van de verschillende opties die in dit document worden beschreven.

## Optie 0: DVA en achterliggende systemen

Het uitgangspunt bij deze optie is dat de plaats en het systeem waar de taak wordt aangemaakt buiten de scope van de KoppelMij standaard ligt. De KoppelMij standaard doet geen uitspraken over waar of hoe de taak wordt aangemaakt - dit kan in een Xis (zorginformatiesysteem), een Koppeltaal domein, of een ander achterliggend systeem zijn. De DVA ontsluit deze taken naar de PGO, ongeacht hun oorsprong.

Dit scenario is van toepassing voor alle Zorgaanbieders, zowel die wel als die geen Koppeltaal gebruiken. Het Xis kan zowel een KT-Xis als een niet-KT-Xis zijn - de KoppelMij standaard maakt hier geen onderscheid in.

Dit is de basislijn voor de PoCs, waarbij we ervanuit gaan dat de PGO een systeem ontsluit dat in staat is taken te tonen en te lanceren.

### Workflow:
- Zorgaanbieder maakt in een achterliggend systeem een taak aan
- DVA laat deze zien bij het "verzamelen taken"
- PGO start de taak met een launch naar de module
- Module haalt de taak op bij de DVA en doet eventueel een update
- PGO verzamelt en ziet de updates

### Architectuur
Bij deze optie is de DVA verantwoordelijk voor het ontsluiten van taken naar de PGO. De architectuur is relatief eenvoudig met een directe koppeling tussen DVA, PGO en module. Dit is de basisimplementatie zoals voorzien in de KoppelMij standaard.

<img src="koppeltaal/optie0.png" alt="Optie 0 Architectuur" style="width: 100%; float: none;"/>

## Optie 1: Zowel Xis als Koppeltaal-FHIR service als bron van FHIR-taken

In deze optie erkent en beschrijft de KoppelMij standaard expliciet dat taken kunnen worden aangemaakt in zowel een Koppeltaal domein als in een extern systeem (Xis). De standaard doet uitspraken over hoe deze coëxistentie werkt en hoe de module moet omgaan met taken uit beide bronnen. Het verschil tussen optie 1a en 1b ligt in de architectuur van de FHIR bron en de manier waarop de DVA integreert met het Koppeltaal ecosysteem.

## Optie 1a: Zowel Xis als Koppeltaal-FHIR service als bron van FHIR-taken (Xis als FHIR bron)

In dit model fungeert een applicatie binnen koppeltaal als FHIR bron. De DVA communiceert rechtstreeks met de applicatie voor het ophalen en updaten van taken.

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

<img src="koppeltaal/optie1a.png" alt="Optie 1a Architectuur" style="width: 100%; float: none;"/>

## Optie 1b: Zowel Xis als Koppeltaal-FHIR service als bron van FHIR-taken (DVA als deelnemer)

In dit model is de FHIR resource service van Koppeltaal de FHIR bron. De DVA wordt deelnemer in het Koppeltaal domein en communiceert met de Koppeltaal FHIR resource service voor het ophalen en updaten van taken. Dit betekent dat de DVA zich conformeert aan de Koppeltaal standaard als deelnemende applicatie. Verder is het zo dat het koppeltaal domein niet de enige bron is van de taken is, de module applicatie kan er niet van uitgaan dat koppeltaal de enige bron van de FHIR resources is.

### Architectuur

<img src="koppeltaal/optie1b.png" alt="Optie 1b Architectuur" style="width: 100%; float: none;"/>

## Optie 2: Volledige en exclusieve koppeling met een Koppeltaal domein
> ⚠️ **Deze optie(s) voldoet niet aan de uitgangspunten van KoppelMij, omdat deze de aanwezigheid van een koppeltaaldomein _vereist_. Dit houdt in dat een Koppeltaal domein altijd aanwezig en actief moet zijn om de beschreven alternatieven te laten werken. Daarmee wordt niet gesteld dat koppelingen met koppeltaal niet in andere scenario's mogelijk zijn.**

## Optie 2a: Volledige en exclusieve koppeling met een koppeltaal domein

Zowel een Koppeltaal domein als een MedMij zorgaanbieding coëxisteren. In dit geval worden taken (primair) aangemaakt in het EPD en opgeslagen in de FHIR resource service van het koppeltaaldomein. In dat geval wordt de koppeling tussen de Koppeltaal FHIR service met de DVA gemaakt, en zou dit onderhevig kunnen zijn aan enige vorm van standaardisatie. De DVA zou dan de taken kunnen ophalen en updaten in de context van de PGO sessie van de gebruiker. De module kent in dit scenario twee SMART on FHIR "ingangen", de via de PGO in de context van de gebruiker en via het patiëntportaal in de context van het koppeltaaldomein.

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

<img src="koppeltaal/optie2a.png" alt="Optie 2a Architectuur" style="width: 100%; float: none;"/>

## Optie 2b: Volledige en exclusieve koppeling met een decentrale koppeltaal voorziening

DVA biedt zowel een decentrale koppeltaalvoorziening als een KoppelMij voorziening aan. Dit maakt het mogelijk om vanuit de DVA zowel modules, EPDs en Patiëntenportalen via de koppeltaalstandaard te koppelen, als PGO's en modules via de KoppelMij standaard.

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

<img src="koppeltaal/optie2b.png" alt="Optie 2b Architectuur" style="width: 100%; float: none;"/>

## Optie 3: Harmonisatie van autorisatie, authenticatie en standaarden

Een geharmoniseerde aanpak waarbij het autorisatiemodel per type gebruiker wordt vastgelegd en via SMART on FHIR app launch wordt geëffectueerd. Belangrijk hierbij is dat SMART on FHIR wordt gebruikt voor user-level access - toegang tot FHIR resources op basis van de ingelogde gebruiker - in tegenstelling tot SMART on FHIR backend services waar applicaties op applicatie-niveau zonder gebruikerscontext toegang krijgen. Dit model wordt op termijn geharmoniseerd met Koppeltaal, waardoor coëxistentie van twee verschillende afsprakenstelsels niet vanuit het afsprakenstelsel noodzakelijk is. Indien gewenst kan coëxistentie altijd geïmplementeerd worden door bijvoorbeeld een DVA die ook in een Koppeltaal domein actief is. Alle applicaties worden gestart met SMART on FHIR app launch in de juiste gebruikerscontext, waardoor het proces uniform wordt voor leveranciers van zowel module- als portaalapplicaties.

### Kernprincipe
Door het harmoniseren van het FHIR model, het authenticatie mechanisme en het autorisatiemodel wordt een harmonisatie bereikt op het niveau van standaarden, waardoor optimale schaalbaarheid wordt gerealiseerd.

### Autorisatie contexten
Het model voorziet in drie contexten van autorisatie die uiteindelijk beproefd kunnen worden:

**1. Taak context (Task-centric):**
- Een taak die kan worden uitgevoerd door een patiënt, RelatedPerson of behandelaar
- Specifieke taak-gebaseerde autorisatie ongeacht wie de taak uitvoert
- De toegang is beperkt tot de context van die specifieke taak

**2. Patiënt/RelatedPerson context (Personal access):**
- Een Patient of RelatedPerson doet een launch naar een portaal
- De gebruiker ziet alle resources waar zij toegang tot hebben:
  - Patient: eigen gegevens, eigen taken, betrokken zorgverleners
  - RelatedPerson: gegevens van de patiënt(en) waarvoor zij gemachtigd zijn
- Dit is de persoonlijke toegangscontext voor niet-professionals

**3. Behandelaar context (Professional care):**
- De context van de behandelaar: de cliënten en de zorgteams, alles wat er nodig is om behandelingen aan te bieden
- Behandelaar-geïnitieerde toegang tot meerdere patiënten en zorgprocessen
- Professionele toegang met bredere rechten dan persoonlijke toegang

**Aanvullende overwegingen:**
- De scope van de zorgmanager/beheerder kan nog benoemd worden
- Voor EPD-integratie wordt aangenomen dat applicatie-level toegang het meest geschikt is
- Of alle drie contexten binnen scope van het huidige project vallen, staat nog open voor besluitvorming

### Workflow:
- Alle portalen initiëren een SMART on FHIR launch naar modules, waarbij het achterliggende systeem (Koppeltaal domein, DVA of Xis) de SMART on FHIR specificatie implementeert
- Het achterliggende systeem voert authenticatie en autorisatie uit en bepaalt de context op basis van:
  1. **Type gebruiker** (Patient, RelatedPerson, Practitioner)
  2. **Type launch** (Task-specifiek of portaal-breed)

- De contexten worden als volgt toegepast:
  - **Task launch**: Start met **Task context** - beperkte toegang tot resources gerelateerd aan die specifieke taak
  - **Patiëntportaal door Patient**: Start met **Patient context** - toegang tot alle eigen gegevens
  - **Portaal door RelatedPerson**: Start met **RelatedPerson context** - toegang tot geautoriseerde patiëntgegevens
  - **Behandelportaal door Practitioner**: Start met **Practitioner context** - toegang tot meerdere patiënten
  - **PGO door Patient**: Start met **Patient context** - vergelijkbaar met patiëntportaal

- Module ontvangt altijd de juiste context via SMART on FHIR van het achterliggende systeem
- Module is agnostisch voor de herkomst (Koppeltaal domein of een KoppelMij zorgaanbieding)
- Updates worden via dezelfde gestandaardiseerde interface afgehandeld
- **Kernvoordeel**: Modules implementeren één SMART on FHIR interface voor alle scenario's

### Voordelen
- **Geen synchronisatie problemen**: Één afsprakenstelsel voorkomt dubbele data en synchronisatie-issues
- **Uniform autorisatiemodel**: Consistent autorisatiemodel voor alle gebruikerstypes
- **Toekomstbestendig**: Convergeert naar één geharmoniseerd systeem
- **Module-agnostisch**: Modules hoeven geen onderscheid te maken tussen verschillende bronnen
- **Vereenvoudigde architectuur**: Alle communicatie via dezelfde SMART on FHIR standaard

### Synchronisatie van taakstatussen
De harmonisatie op SMART on FHIR niveau maakt synchronisatie tussen portalen (clientportaal en PGO) eenvoudiger:

**SMART on FHIR mechanisme:**
- **Authenticatie**: Gebruiker achter het toetsenbord wordt geauthenticeerd (id_token)
- **Autorisatie**: Gebruiker wordt geautoriseerd voor toegang tot FHIR service (access_token met user-level scope)
- **User-level access**: Toegang tot resources is altijd gekoppeld aan de ingelogde gebruiker
- **Geen backend services**: In tegenstelling tot SMART on FHIR backend services is er altijd een gebruikerscontext
- Werkt in alle afsprakenstelsels hetzelfde na harmonisatie

**Synchronisatie voordelen:**
- Vanuit perspectief van portalen en modules wordt synchronisatie **technisch eenvoudiger**
- Achterliggende systeem (DVA of Koppeltaal) moet zorgen dat alle partijen naar **dezelfde gegevensbron** kijken
- Uniforme FHIR profiles en autorisatiemodel vergemakkelijken gegevensdeling

**FHIR Subscriptions:**
- Portaal kan in gebruikerscontext een **subscription** nemen op FHIR queries (bijvoorbeeld taken)
- Portaal ontvangt dan **off band** updates bij wijzigingen
- **Belangrijke voorwaarde**: Juiste toestemmingen voor subscriptions moeten geregeld zijn

### Implementatie aspecten
- **Gefaseerde harmonisatie**: Geleidelijke convergentie van Koppeltaal naar het geharmoniseerde model
- **Standaard-compliant**: Volledig gebaseerd op SMART on FHIR specificaties
- **Context-aware**: Elke launch bevat de juiste gebruikerscontext
- **Eenvoudige integratie**: Modules implementeren één interface voor alle scenario's

### Ontwikkelingsstappen
**1. Autorisatiemodel ontwikkeling:**
- Het beschrijven/vaststellen van het autorisatiemodel wordt door Koppeltaal gedaan
- Koppeltaal neemt de lead in het definiëren van de geharmoniseerde autorisatie-aanpak

**2. Transitiefase strategie:**
- Koppeltaal gaat in de transitiefase beide modellen ondersteunen (bestaand + geharmoniseerd)
- Het autorisatiemodel van de patiënt wordt beproefd in het KoppelMij traject
- Parallelle ontwikkeling en testing van nieuwe aanpak

**3. Proces aanpak:**
- Eerst een visie-uitspraak hebben over de gewenste eindtoestand
- Dan, op basis van de leveranciers die aan tafel zitten en de use cases die we met elkaar bepalen, aan de standaardisatie werken
- Praktische implementatie gebaseerd op concrete deelnemers en scenario's

**4. Technische wijzigingen:**
- **Belangrijk**: De harmonisatie van SMART on FHIR app launch voor portalen in Koppeltaal vereist een aanpassing in de Koppeltaal standaard
- Coördinatie tussen Koppeltaal en KoppelMij standaard-ontwikkeling is essentieel

### Architectuur

<img src="koppeltaal/optie3.png" alt="Optie 3 Architectuur" style="width: 100%; float: none;"/>

## Optie 3 Light: Gestandaardiseerde SMART on FHIR launch naar modules zonder wijziging portaal toegang

Deze lichtgewicht variant van optie 3 focust zich uitsluitend op het standaardiseren van de launch van portalen naar modules. Portalen hoeven zelf niet via SMART on FHIR app launch opgestart te worden - zij kunnen hun bestaande toegangsmechanismen blijven gebruiken. Wat wel gestandaardiseerd wordt is hoe portalen modules starten: dit gebeurt altijd via een geharmoniseerde SMART on FHIR launch. De portalen initiëren een SMART on FHIR launch naar de module, waarbij deze launch vanuit verschillende bronnen (Koppeltaal domein, DVA of Xis) altijd identiek werkt voor de module applicatie.

Deze optie kan een pragmatische tussenstap zijn naar de volledige realisatie van Optie 3, waarbij eerst de module-launch wordt geharmoniseerd voordat de complete SMART on FHIR harmonisatie voor alle componenten wordt doorgevoerd. In essentie is Optie 3 Light een uitbreiding van Optie 0, waarbij als extra scope het gestandaardiseerd starten van modules vanuit portalen via SMART on FHIR wordt toegevoegd.

### Kernprincipe
Standaardisatie van alleen het launch-mechanisme van portaal naar module:
- **Portalen behouden bestaande toegang**: Portalen hoeven zelf niet via SMART on FHIR opgestart te worden
- **Gestandaardiseerde module launch**: Portalen initiëren wel een SMART on FHIR launch naar modules
- **Uniforme module interface**: Modules ontvangen altijd dezelfde SMART on FHIR launch, ongeacht het portaal
- **Harmonisatie over afsprakenstelsels**: De SMART on FHIR launch werkt identiek in Koppeltaal en KoppelMij contexten
- **Verantwoordelijkheid SMART on FHIR implementatie**: Hoewel portalen de launch initiëren, zijn het Koppeltaal domein, de DVA of het Xis verantwoordelijk voor het daadwerkelijk implementeren van de SMART on FHIR app launch, inclusief authenticatie en autorisatie

### Launch bronnen
De gestandaardiseerde launch kan geïnitieerd worden vanuit verschillende bronnen, waaronder:
1. **Koppeltaal domein**: Via bestaande Koppeltaal infrastructuur
2. **DVA**: Via KoppelMij zorgaanbiedingsdienst
3. **Xis**: Direct vanuit zorginformatiesystemen

### Workflow
- Portaal gebruikt zijn bestaande toegangsmechanisme (geen wijziging nodig)
- Portaal initieert een gestandaardiseerde SMART on FHIR launch naar de module
- Het achterliggende systeem (Koppeltaal domein, DVA of Xis) verwerkt de launch en voert authenticatie/autorisatie uit
- Module ontvangt de SMART on FHIR launch met gebruikerscontext (taak ID, patient ID, etc.)
- Module krijgt via het achterliggende systeem toegang tot FHIR resources op basis van de verkregen autorisatie
- Updates verlopen via de reguliere kanalen (DVA, Koppeltaal, etc.)
- Deze SMART on FHIR launch werkt identiek vanuit elk type portaal

### Voordelen
- **Minimale impact op portalen**: Portalen behouden hun bestaande toegangsmechanismen
- **Uniformiteit voor modules**: Modules ontvangen altijd dezelfde SMART on FHIR launch
- **Lage implementatiedrempel**: Portalen hoeven alleen de module launch aan te passen
- **Flexibiliteit**: Werkt met bestaande portaal infrastructuur
- **Snellere adoptie**: Geen wijziging in hoe portalen zelf worden opgestart
- **Geharmoniseerde standaard**: Eén SMART on FHIR launch standaard voor alle afsprakenstelsels

### Nadelen
- **Beperkte functionaliteit**: Geen volledige SMART on FHIR voordelen
- **Minder toekomstbestendig**: Mogelijk tussenstap naar volledige harmonisatie
- **Context beperking**: Minder rijke context-informatie beschikbaar

### Implementatie aspecten
- **SMART on FHIR launch standaard**: Definiëren van uniforme SMART on FHIR launch vanuit portalen
- **Portaal aanpassing**: Portalen implementeren de SMART on FHIR launch naar modules op een gestandaardiseerde manier
- **Module requirements**: Modules implementeren volledige SMART on FHIR app launch ontvangst
- **Geen wijziging portaal toegang**: Portalen blijven hun huidige toegangsmechanismen gebruiken
- **Backwards compatible**: Kan naast bestaande implementaties functioneren

### Architectuur
In deze optie ligt de nadruk op een uniforme SMART on FHIR launch waarbij:
- Portalen blijven werken met hun bestaande toegangsmechanismen
- Portalen initiëren een gestandaardiseerde SMART on FHIR launch naar modules
- Het achterliggende systeem (Koppeltaal domein, DVA of Xis) implementeert de SMART on FHIR app launch.
- Modules ontvangen altijd dezelfde SMART on FHIR launch, ongeacht het portaal of afsprakenstelsel
- De SMART on FHIR launch is geharmoniseerd over alle implementaties

<img src="koppeltaal/optie3%20light.png" alt="Optie 3 Light Architectuur" style="width: 100%; float: none;"/>

## Vergelijking van opties

| Aspect                  | Optie 0          | Optie 1a       | Optie 1b       | Optie 2a       | Optie 2b       | Optie 3                  | Optie 3 Light             |
|-------------------------|------------------|----------------|----------------|----------------|----------------|--------------------------|---------------------------|
| **Complexiteit**        | Laag             | Middel         | Middel         | Hoog           | Hoog           | Laag-Middel              | Laag                      |
| **Standaardisatie**     | KoppelMij        | Deels          | Deels          | Koppeltaal     | Beide          | Volledig (SMART)         | Launch alleen             |
| **Flexibiliteit**       | Beperkt          | Middel         | Middel         | Hoog           | Zeer hoog      | Zeer hoog                | Hoog                      |
| **Integratie EPD**      | Buiten scope     | Via applicatie | Via Koppeltaal | Via Koppeltaal | Via Koppeltaal | Via geharmoniseerd model | Via bestaande kanalen     |
| **Onderhoudskosten**    | Laag             | Middel         | Middel         | Hoog           | Zeer hoog      | Laag                     | Zeer laag                 |
| **Gebruikerservaring**  | Eenvoudig        | Complex        | Complex        | Complex        | Middel         | Eenvoudig                | Eenvoudig                 |
| **Behandelaar toegang** | Via ext. systeem | Via beide      | Via beide      | Via portaal    | Via portaal    | Via context-aware launch | Via uniforme launch       |
| **Synchronisatie**      | N.v.t.           | Nodig          | Nodig          | Complex        | Complex        | Niet nodig               | Via bestaande mechanismen |
| **Toekomstbestendig**   | Basis            | Tijdelijk      | Tijdelijk      | Beperkt        | Overgangsfase  | Zeer hoog                | Middel                    |
| **Module complexiteit** | Enkel KoppelMij  | Dubbel model   | Dubbel model   | Dubbel model   | Dubbel model   | Uniform model            | Uniform launch            |

## Beslissing: Optie 3 in drie stappen

Er is gekozen voor **Optie 3**, waarbij de implementatie wordt opgedeeld in drie opeenvolgende stappen:

### Stap 1: PGO launch (Solution design 3a)
De eerste stap richt zich op het gestandaardiseerd starten van modules vanuit een PGO. Dit betreft het solution design zoals beschreven in Optie 3 Light, waarbij de SMART on FHIR launch naar modules wordt geharmoniseerd.

**Verantwoordelijkheid**: Deze stap valt onder het **KoppelMij project**.

### Stap 2: Gestandaardiseerd starten van modules vanuit een portaal
De tweede stap breidt de gestandaardiseerde SMART on FHIR launch uit naar alle portalen, waarbij portalen (zowel behandelportalen als patiëntportalen) modules op uniforme wijze kunnen starten.

**Verantwoordelijkheid**: Deze stap valt onder de verantwoordelijkheid van **Koppeltaal**.

### Stap 3: Gestandaardiseerd starten van behandel- en patiëntportalen
De derde en laatste stap voltooit de volledige harmonisatie door ook de launch van behandel- en patiëntportalen te standaardiseren volgens het SMART on FHIR model, zoals beschreven in Optie 3.

**Verantwoordelijkheid**: Deze stap valt onder de verantwoordelijkheid van **Koppeltaal**.

Deze gefaseerde aanpak maakt het mogelijk om stapsgewijs toe te werken naar volledige harmonisatie, waarbij elke stap concrete waarde levert en bouwt op de vorige stap.

## Aanbevelingen

Bij het kiezen tussen deze opties zijn de volgende overwegingen belangrijk:

1. **Huidige infrastructuur**: Welke systemen zijn al aanwezig en hoe kunnen deze het beste geïntegreerd worden?

2. **Toekomstige schaalbaarheid**: Is er behoefte aan ondersteuning voor beide ecosystemen (Koppeltaal en KoppelMij)?

3. **Complexiteit vs. functionaliteit**: De meer complexe opties bieden meer functionaliteit maar tegen hogere implementatie- en onderhoudskosten.

4. **Standaardisatie**: Opties die afwijken van gevestigde standaarden kunnen leiden tot interoperabiliteitsproblemen en hogere onderhoudskosten.

5. **Gebruikerservaring**: Complexere architecturen kunnen leiden tot verwarring bij eindgebruikers, vooral wanneer er meerdere toegangspunten zijn.

De keuze hangt sterk af van de specifieke context en requirements van de implementatie. Voor een eerste implementatie is Optie 1 waarschijnlijk het meest haalbaar, terwijl Optie 2b de meeste flexibiliteit biedt voor organisaties die beide ecosystemen willen ondersteunen.
