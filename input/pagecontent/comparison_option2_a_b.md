### Gemeenschappelijke basis
Beide opties gebruiken het **PGO als SMART on FHIR authorization server** en lossen hetzelfde probleem op: veilige browser authenticatie tijdens het launch proces zonder extra login stappen voor de gebruiker.

### Optie 2a: PGO Token Exchange
**Kern concept**: Het PGO voert de Token Exchange uit namens de module

**Werkwijze**:
- Module doet standaard SMART on FHIR flow met PGO
- **PGO voert Token Exchange uit** tijdens de `/token` stap
- PGO stuurt module's JWT assertion naar DVA als actor_token
- DVA genereert delegation token en stuurt terug naar PGO
- **PGO geeft finale delegation token** aan module
- Token response bevat **`aud` veld** met DVA FHIR URL

**Voordelen**:
- Module hoeft Token Exchange niet te implementeren
- Eenvoudiger voor module ontwikkelaars
- PGO heeft volledige controle over delegation proces

### Optie 2b: Module Token Exchange
**Kern concept**: De module voert zelf de Token Exchange uit

**Werkwijze**:
- Module doet standaard SMART on FHIR flow met PGO
- **PGO geeft tijdelijk token** (5 minuten geldig)
- **Module voert zelf Token Exchange uit** bij DVA
- Module gebruikt tijdelijk token als subject_token
- DVA genereert delegation token direct voor module
- **Geen `aud` veld** in PGO response, wel Token Exchange endpoint info

**Voordelen**:
- Module heeft volledige controle over timing
- Geen delegatie van gevoelige tokens via PGO
- Flexibiliteit in Token Exchange uitvoering
- Kortere token levensduur verhoogt beveiliging

### Belangrijkste verschillen

| Aspect                     | Optie 2a                             | Optie 2b                        |
|----------------------------|--------------------------------------|---------------------------------|
| **Token Exchange locatie** | PGO voert uit                        | Module voert uit                |
| **PGO token response**     | Finale delegation token + `aud` veld | Tijdelijk token + endpoint info |
| **Module complexiteit**    | Lager                                | Hoger                           |
| **Token levensduur**       | Standaard (bijv. 1 uur)              | Tijdelijk token: 5 minuten      |
| **Controle**               | PGO heeft controle                   | Module heeft controle           |
| **Delegatie risico**       | PGO handelt gevoelige tokens         | Directe module-DVA communicatie |

#### Compliance beoordeling

#### **Optie 2b is meer compliant** om de volgende redenen:

#### **1. RFC 8693 Token Exchange compliance**
- **Optie 2b**: Module voert Token Exchange direct uit met DVA - dit is de bedoelde werking van RFC 8693
- **Optie 2a**: PGO handelt namens module, wat een extra delegatielaag toevoegt

#### **2. SMART on FHIR specificatie**
- **Optie 2b**: Gebruikt standaard SMART response zonder non-standaard `aud` veld
- **Optie 2a**: Voegt custom `aud` veld toe buiten SMART/OIDC specificaties

#### **3. Security best practices**
- **Optie 2b**: Minimale token levensduur (5 min) en directe client-server communicatie
- **Optie 2a**: Langere token levensduur en extra tussenpartij (PGO)

#### **4. Principe van least privilege**
- **Optie 2b**: Module krijgt alleen wat nodig is voor Token Exchange
- **Optie 2a**: PGO krijgt volledige toegang tot module's authenticatie context

#### Aanbeveling

**Optie 2b wordt aanbevolen** vanwege:
- ✅ Betere compliance met RFC 8693 en SMART on FHIR
- ✅ Hogere beveiliging door korte token levensduur
- ✅ Geen custom velden buiten standaarden
- ✅ Directe authenticatie relatie tussen module en DVA
- ✅ Minder delegatie risico's

**Nadeel**: Hogere implementatie complexiteit voor modules, maar dit weegt niet op tegen de compliance en security voordelen.
