// Bundle with FHIR test instances in FSH format for KoppelMij test scenario 2

Instance: KoppelMij-Task-Questionnaire-De-Groot
InstanceOf: http://medmij.nl/fhir/StructureDefinition/MedMij-Task
Usage: #example
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of a task</div>"
* insert NLlang
* extension[+]
  * url = $task-instantiates
  * valueReference = Reference(KoppelMij-ActivityDefinition-Angststoornis-Questionnaire)
    * type = "ActivityDefinition"
* identifier
  * system = "http://medmij.nl/taskIdentifier"
  * value = "38e5d3a9-ae79-497a-9071-169d189bae34"
* status = #requested
* intent = #order
* priority = #routine
* code = $SmartCodes#launch-app-standalone "Launch application using the SMART standalone launch"
* description = "Invullen angststoornis vragenlijst t.b.v. CGT sessie"
* for = Reference(KoppelMij-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-08-01T09:00:00+01:00"
  * end = "2025-10-01T12:00:00+01:00"
* authoredOn = "2025-08-01T09:00:00+01:00"
* lastModified = "2025-08-01T09:00:00+01:00"
* requester = Reference(KoppelMij-PractitionerRole-Vonk) "M. Vonk, Psychiater"
* owner = Reference(KoppelMij-Patient-De-Groot) "Koos de Groot"

Instance: KoppelMij-ActivityDefinition-Angststoornis-Questionnaire
InstanceOf: http://medmij.nl/fhir/StructureDefinition/MedMij-ActivityDefinition
Usage: #example
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an ActivityDefinition</div>"
* insert NLlang
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
  * valueReference = Reference(KoppelMij-Endpoint-Vragenlijst-Angststoornis)
* identifier
  * system = "http://{name}/content/id"
  * value = "cb2ca8b6-4d5f-480b-a8fe-4c574f1e38ae"
* version = "1.0.0"
* name = "Angststoornis vragenlijst"
* url = "https://example.com/activity1"
* title = "Vragenlijst ......."
* status = #active
* description = "Vul deze vragenlijst voorafgaand aan de CGT-sessie in"

Instance: KoppelMij-Endpoint-Vragenlijst-Angststoornis
InstanceOf: http://medmij.nl/fhir/StructureDefinition/MedMij-Endpoint
Usage: #example
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml' xml:lang='nl-NL' lang='nl-NL'>Example of an Endpoint as used in KoppelMij</div>"
* insert NLlang
* status = #active
* connectionType = $koppeltaal-endpoint-connection-type#hti-smart-on-fhir
* managingOrganization = Reference(KoppelMij-Organization-GGZ)
* payloadType = $endpoint-payload-type#any
* address = "https://module.test.5im.nl/web/api/smartonfhir/launch"


Instance: KoppelMij-Patient-De-Groot
InstanceOf: http://nictiz.nl/fhir/StructureDefinition/nl-core-Patient
Usage: #example
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>Patiënt: Koos de Groot<br/>Geboortedatum: 1961-08-02<br/>Geslacht: Man<br/>Nationaliteit: Nederlandse<br/>Telefoon: +31612345600<br/>E-mail: tomvanduinen@tom.com<br/>Adres: Maanweg 174, 2516 AB Den Haag, Nederland</div>"
* extension[http://hl7.org/fhir/StructureDefinition/patient-nationality].extension[code].valueCodeableConcept = urn:oid:2.16.840.1.113883.2.4.4.16.32#0001 "Nederlandse"
* identifier
  * system = "http://fhir.nl/fhir/NamingSystem/bsn"
  * value.extension[http://hl7.org/fhir/StructureDefinition/data-absent-reason].valueCode = #masked // gemaskeerd BSN
* name[0]
  * use = #official
  * text = "Koos de Groot"
  * family = "de Groot"
    * extension[http://hl7.org/fhir/StructureDefinition/humanname-own-prefix].valueString = "de"
    * extension[http://hl7.org/fhir/StructureDefinition/humanname-own-name].valueString = "Groot"
  * given = "Koos"
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier].valueCode = #BR
* name[1]
  * use = #usual
  * given = "Koos"
* telecom[0]
  * system = #phone
    * extension[http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification].valueCodeableConcept = http://terminology.hl7.org/CodeSystem/v3-AddressUse#MC "mobile contact"
  * value = "+31612345611"
* telecom[1]
  * system = #email
  * value = "koosdegrootn@koos.com"
  * use = #home
* gender = #male
  * extension[http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification].valueCodeableConcept.coding = http://terminology.hl7.org/CodeSystem/v3-AdministrativeGender#M "Male"
* birthDate = "1972-09-20"
* deceasedBoolean = false
* address
  * extension[http://nictiz.nl/fhir/StructureDefinition/ext-AddressInformation.AddressType].valueCodeableConcept = http://terminology.hl7.org/CodeSystem/v3-AddressUse#HP "primary home"
  * use = #home
  * type = #both
  * line = "Maanweg 174"
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName].valueString = "Maanweg"
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber].valueString = "174"
  * city = "Den Haag"
  * postalCode = "2516 AB"
  * country = "Nederland"
    * extension[http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification].valueCodeableConcept = urn:iso:std:iso:3166#NL "Netherlands"

Instance: KoppelMij-PractitionerRole-Vonk
InstanceOf: http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-PractitionerRole
Usage: #example
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>Zorgverlenerrol: Psychiater<br/>Zorgverlener: Vonk<br/>Organisatie: GGZ</div>"
* practitioner = Reference(KoppelMij-Practitioner-Vonk) "M. Vonk"
* organization = Reference(KoppelMij-Organization-GGZ) "GGZ "
* specialty
  * coding = urn:oid:2.16.840.1.113883.2.4.6.7#0329 "Psychiatrie"

Instance: KoppelMij-Practitioner-Vonk
InstanceOf: http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-Practitioner
Usage: #example
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>Zorgverlener: M. Vonk<br/>BIG-nummer: 12082100<br/>Telefoon: +31612555600<br/>E-mail: vonk@ggz.nl<br/>Adres: Simon Smitweg 1, 2353 GA Leiderdorp, Nederland</div>"
* identifier
  * system = "http://fhir.nl/fhir/NamingSystem/big"
  * value = "12082100"
* name
  * use = #official
  * text = "M. Vonk"
  * family = "Vonk"
    * extension[http://hl7.org/fhir/StructureDefinition/humanname-own-name].valueString = "Vonk"
  * given[0] = "M."
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier].valueCode = #IN
* telecom[0]
  * system = #phone
  * value = "+31612555600"
  * use = #work
* telecom[1]
  * system = #email
  * value = "vonk@ggz.nl"
  * use = #work
* address
  * extension[http://nictiz.nl/fhir/StructureDefinition/ext-AddressInformation.AddressType].valueCodeableConcept = http://terminology.hl7.org/CodeSystem/v3-AddressUse#WP "Work Place"
  * use = #work
  * line = "Simon Smitweg 1"
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName].valueString = "Simon Smitweg"
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber].valueString = "1"
  * city = "Leiderdorp"
  * postalCode = "2353 GA"
  * country = "Nederland"
    * extension[http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification].valueCodeableConcept = urn:iso:std:iso:3166#NL "Netherlands"

Instance: KoppelMij-Organization-GGZ
InstanceOf: http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthcareProvider-Organization
Usage: #example
* text
  * status = #generated
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>Organisatie: GGZ <br/>AGB-code: 12095095<br/>Telefoon: +31653603740<br/>E-mail: huisartsenpraktijk-dehaard@huisarts.nl<br/>Adres: Herculeslaan 1, 3584 AB Utrecht</div>"
* identifier
  * system = "http://fhir.nl/fhir/NamingSystem/agb-z"
  * value = "12095095"
* name = "GGZ"
* telecom[0]
  * system = #phone
  * value = "+31653603740"
  * use = #work
* telecom[1]
  * system = #email
  * value = "ggz@ggz.nl"
  * use = #work
* address
  * extension[http://nictiz.nl/fhir/StructureDefinition/ext-AddressInformation.AddressType].valueCodeableConcept = http://terminology.hl7.org/CodeSystem/v3-AddressUse#WP "Work Place"
  * use = #work
  * line = "Herculeslaan 1"
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName].valueString = "Herculeslaan"
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber].valueString = "1"
  * city = "Utrecht"
  * postalCode = "3584 AB"
