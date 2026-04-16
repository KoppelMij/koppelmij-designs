// Bundle with FHIR test instances in FSH format for ProviderTasks test scenario 2
Instance: ProviderTasks-ServiceRequest-Bloeddrukmeting
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-ServiceRequest
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* identifier
  * system = "http://medrie/servicerequest/id"
  * value = "2025-999999"
* status = #active
* intent = #order
* subject = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* occurrenceTiming.repeat
  * boundsPeriod.start = "2025-12-22"
  * boundsPeriod.end = "2025-12-28"
  * period = 1
  * periodUnit = #d
  * frequency = 2
  * frequencyMax = 2
* requester = Reference(ProviderTasks-PractitionerRole-De-Haard) "A. de Haard, Huisarts"
* patientInstruction = """
Beste patiënt,

U gaat gedurende 1 week zelf uw bloeddruk meten. Volg hierbij deze stappen:

1. Meet uw bloeddruk elke ochtend vóór het ontbijt (nuchter).
2. Meet uw bloeddruk elke avond vóór het avondeten.
3. Noteer de waarden direct na de meting in uw app.
4. Voer dit dagelijks uit gedurende 7 dagen en neem de resultaten mee naar uw volgende afspraak.
"""

Instance: ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-ActivityDefinition
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
  * valueReference = Reference(ProviderTasks-Endpoint-Minddistrict)
* identifier
  * system = "https://ns.minddistrict.com/content/id"
  * value = "481365c2-a85c-49cc-bb74-d6d8a6a53b46"
* version = "1.0.0"
* name = "MeetopdachtBloeddrukmeting"
* title = "Bloeddrukmeting"
* status = #active
* publisher = "Minddistrict"
* description = "Bloeddrukmeting volgens NHG protocol. 1 week, 2x per dag, 's ochtends en 's avonds"
* timingTiming.repeat
  * boundsDuration.value = 7
  * boundsDuration.system = "http://unitsofmeasure.org"
  * boundsDuration.code = #d
  * boundsDuration.unit = "day"
  * frequency = 2
  * period = 1
  * periodUnit = #d

Instance: ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "MAINTASK-Bloeddruk"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk voor 1 week, 2x per dag, 's ochtends en 's avonds"
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-22"
  * end = "2025-12-28"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-1
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-1"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-22"
  * end = "2025-12-22"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-2
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-2"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-22"
  * end = "2025-12-22"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-3
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-3"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-23"
  * end = "2025-12-23"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-4
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-4"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-23"
  * end = "2025-12-23"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-5
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-5"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-24"
  * end = "2025-12-24"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-6
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-6"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-24"
  * end = "2025-12-24"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-7
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-7"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-25"
  * end = "2025-12-25"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-8
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-8"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-25"
  * end = "2025-12-25"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-9
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-9"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-26"
  * end = "2025-12-26"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-10
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-10"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-26"
  * end = "2025-12-26"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-11
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-11"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-27"
  * end = "2025-12-27"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-12
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-12"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-27"
  * end = "2025-12-27"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-13
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-13"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-28"
  * end = "2025-12-28"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-SubTask-Meetopdracht-Bloeddrukmeting-14
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Meetopdracht-Bloeddrukmeting)
    * type = "ActivityDefinition"
* basedOn = Reference(ProviderTasks-ServiceRequest-Bloeddrukmeting)
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Bloeddruk-14"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* partOf = Reference(ProviderTasks-MainTask-Meetopdracht-Bloeddrukmeting)
* status = #received
* intent = #order
* priority = #routine
* description = "Meet je bloeddruk in de ochtend nuchter (voor het ontbijt) en in de avond voor het avondeten. Noteer de waarde in de app. Je metingen helpen je zorgverlener om te zien hoe het met je gaat en of je behandeling moet worden aangepast."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-28"
  * end = "2025-12-28"
* authoredOn = "2025-12-22T08:00:00+01:00"
* lastModified = "2025-12-22T08:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-ActivityDefinition-Informatie-Cholesterol
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-ActivityDefinition
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
  * valueReference = Reference(ProviderTasks-Endpoint-Minddistrict)
* identifier
  * system = "https://ns.minddistrict.com/content/id"
  * value = "c45485ee-8a42-466b-97ba-ac6537b0bf89"
* version = "1.0.0"
* name = "InformatieCholesterol"
* title = "Wat is cholesterol en wat zijn de risico's?"
* status = #active
* publisher = "Minddistrict"
* description = "Voorlichtingsmodule cholesterol: uitlegmateriaal over wat cholesterol is, cardiovasculaire risico’s en leefstijl-/behandelopties ter ondersteuning van CVRM en gezamenlijke besluitvorming."

Instance: ProviderTasks-Task-Informatie-Cholesterol
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Informatie-Cholesterol)
    * type = "ActivityDefinition"
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Informatie-Cholesterol-1"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* status = #received
* intent = #order
* priority = #routine
* description = "Lees wat cholesterol is, welke risico’s erbij horen en wat je kunt doen met leefstijl en/of medicijnen."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-22"
  * end = "2025-12-28"
* authoredOn = "2025-12-23T07:00:00+01:00"
* lastModified = "2025-12-23T07:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"


Instance: ProviderTasks-ActivityDefinition-Informatie-Thuismeting
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-ActivityDefinition
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
  * valueReference = Reference(ProviderTasks-Endpoint-Minddistrict)
* identifier
  * system = "https://ns.minddistrict.com/content/id"
  * value = "7e5633b6-2cf2-49bf-8f1c-e105c8b82b22"
* version = "1.0.0"
* name = "InformatieBloeddrukmeten"
* title = "Informatie over thuis bloeddruk meten"
* status = #active
* publisher = "Minddistrict"
* description = "Instructiemodule thuismetingen bloeddruk: patiëntinstructie voor correcte meetmethode (rust, houding, manchet, meetmomenten) en registratie, ter verbetering van betrouwbaarheid van thuismetingen"

Instance: ProviderTasks-Task-Informatie-Thuis-Bloeddrukmeten
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Informatie-Thuismeting)
    * type = "ActivityDefinition"
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Informatie-Bloeddruk-1"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* status = #requested
* intent = #order
* priority = #routine
* description = "In deze module leer je stap voor stap hoe je thuis je bloeddruk goed meet. Je krijgt tips over voorbereiding (eerst 5 minuten rustig zitten), de juiste houding, hoe je de manchet plaatst en wanneer je het beste meet. Ook lees je wat je kunt doen om meetfouten te voorkomen (zoals praten tijdens het meten of meten direct na koffie of inspanning) en hoe je je waarden in de app noteert. Zo worden je metingen betrouwbaarder en kan je zorgverlener er beter op sturen."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-22"
  * end = "2025-12-28"
* authoredOn = "2025-12-24T07:00:00+01:00"
* lastModified = "2025-12-24T07:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"


Instance: ProviderTasks-ActivityDefinition-Vragenlijst-Uw-Situatie
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-ActivityDefinition
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension[0]
  * url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
  * valueReference = Reference(ProviderTasks-Endpoint-Minddistrict)
* identifier
  * system = "https://ns.minddistrict.com/content/id"
  * value = "c4bd168d-963c-4360-86fa-39d4b6e08d83"
* version = "1.0.0"
* name = "VragenlijstHartVaatziekten"
* title = "Vragenlijst over uw situatie op gebied van hart- en vaatziekten"
* status = #active
* publisher = "Minddistrict"
* description = "Vragenlijst ‘Uw situatie’ om relevante klachten, leefstijl en risicofactoren rond hart- en vaatziekten te inventariseren als basis voor behandelafspraken."

Instance: ProviderTasks-Task-Vragenlijst-Uw-Situatie
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Task
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $koppeltaal-instantiates
  * valueReference = Reference(ProviderTasks-ActivityDefinition-Vragenlijst-Uw-Situatie)
    * type = "ActivityDefinition"
* identifier
  * system = "http://medrie.nl/taskIdentifier"
  * value = "SUBTASK-Informatie-Situatie-1"
* groupIdentifier
  * system = "https://medrie.nl/fhir/identifiers/task-group"
  * value = "module-CVRM-2025"
  * type.text = "Digitale zorgmodule CVRM"
* status = #failed
* intent = #order
* priority = #routine
* description = "In deze vragenlijst beantwoord je vragen over jouw situatie rond hart- en vaatziekten. Denk aan klachten, leefstijl (zoals bewegen, roken en voeding) en andere factoren die invloed kunnen hebben op je gezondheid. Je antwoorden helpen jou en je zorgverlener om een compleet beeld te krijgen en samen te bepalen welke stappen het meest belangrijk zijn."
* for = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"
* executionPeriod
  * start = "2025-12-22"
  * end = "2025-12-28"
* authoredOn = "2025-12-23T18:00:00+01:00"
* lastModified = "2025-12-23T18:00:00+01:00"
* requester = Reference(ProviderTasks-PractitionerRole-De-Jong) "L. de Jong, Huisarts"
* owner = Reference(ProviderTasks-Patient-De-Groot) "Koos de Groot"

Instance: ProviderTasks-Endpoint-Minddistrict
InstanceOf: http://medmij.nl/fhir/StructureDefinition/pt-Endpoint
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* extension
  * url = $client-id
  * valueString = "dvaAanbiedertaken"
* status = #active
* connectionType = http://terminology.hl7.org/CodeSystem/endpoint-connection-type#hl7-fhir-rest
* managingOrganization = Reference(ProviderTasks-Organization-Huisartsenpraktijk-De-Haard)
* payloadType = $endpoint-payload-type#any
* address = "https://aanbiedermodule.example.org/web/api/smartonfhir/launch?iss=resourceserver.example.dva.nl"

Instance: ProviderTasks-Patient-De-Groot
InstanceOf: http://nictiz.nl/fhir/StructureDefinition/nl-core-Patient
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
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
  * line = "Spui 70"
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName].valueString = "Spui"
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber].valueString = "70"
  * city = "Den Haag"
  * postalCode = "2511 BT"
  * country = "Nederland"
    * extension[http://nictiz.nl/fhir/StructureDefinition/ext-CodeSpecification].valueCodeableConcept = urn:iso:std:iso:3166#NL "Netherlands"

Instance: ProviderTasks-PractitionerRole-De-Jong
InstanceOf: http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-PractitionerRole
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* practitioner = Reference(ProviderTasks-Practitioner-De-Jong) "L. de Jong"
* organization = Reference(ProviderTasks-Organization-Huisartsenpraktijk-De-Haard) "Huisartstenpraktijk de Haard"
* specialty
  * coding = urn:oid:2.16.840.1.113883.2.4.6.7#0110 "Huisarts, apotheekhoudend"

Instance: ProviderTasks-Practitioner-De-Jong
InstanceOf: http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-Practitioner
Usage: #example
* text
  * status = #empty
  * div = "<div xmlns='http://www.w3.org/1999/xhtml'>No human-readable text provided in this case.</div>"
* identifier
  * system = "http://fhir.nl/fhir/NamingSystem/big"
  * value = "28910456"
* name
  * use = #official
  * text = "L. de Jong"
  * family = "de Jong"
    * extension[http://hl7.org/fhir/StructureDefinition/humanname-own-prefix].valueString = "de"
    * extension[http://hl7.org/fhir/StructureDefinition/humanname-own-name].valueString = "Jong"
  * given[0] = "L."
    * extension[http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier].valueCode = #IN
* telecom[0]
  * system = #phone
  * value = "+31655504321"
  * use = #work
* telecom[1]
  * system = #email
  * value = "l.dejong@huisartspraktijk-example.nl"
  * use = #work
