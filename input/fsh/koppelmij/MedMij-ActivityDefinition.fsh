Profile: MedMijActivityDefinition
Parent: ActivityDefinition
Id: MedMij-ActivityDefinition
Description: "The (FHIR) ActivityDefinition (resource) describes an eHealth activity that is available for assignment to a patient. When assigning an eHealth activity to a patient, an eHealth Task is created, in which sub-activities are included as contained resources that refer to the main task via Task.partOf."
* ^status = #draft
* insert PublisherAndContact
* . ^short = "Description of an eHealth activity"
* . ^comment = "The (FHIR) ActivityDefinition describes an eHealth activity available to assign to a patient. The assignment of an eHealth activity to a patient creates an eHealth Task (Task resource). This task can contain sub activities as contained resources which refer to the main task using the Task.partOf element."
* insert Origin
* insert Copyright
* . 
  * ^short = "ActivityDefnition"
  * ^alias = "ActivityDefinition"
* extension contains
    KT2_EndpointExtension named endpoint 1..* and
    KT2_PublisherId named publisherId 0..*
* extension[endpoint] ^short = "Endpoint to the service application"
  * ^definition = "Mandatory reference to the service application (endpoint) that provides the eHealth activity. Can be more than one endpoint."
* extension[publisherId] ^isModifier = false
* url 1..
* title 1..
* useContext
  * ^definition = "The context for the content of the eHealth activity"
  * ^comment = "E.g. the activity is targeted to a certain age group"
* topic from KoppeltaalDefinitionTopic_VS (extensible)
  * ^short = "E.g. Self-Treatment and Self-Assessment, etc."
  * ^definition = "Descriptive topics related to the content of the activity. The topic is used to indicate that the activity is intended or suitable for initialization by patients."
  * ^binding.description = "High-level categorization of the definition, used for indicating special patient initialised activities"

Extension: KT2_EndpointExtension
Id: KT2EndpointExtension
Description: "Reference extension to the service application (endpoint) that provides the eHealth activity."
Context: ActivityDefinition
* ^meta.versionId = "9"
* ^meta.lastUpdated = "2023-01-24T13:04:45.2923549+00:00"
* ^url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2EndpointExtension"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* value[x] only Reference(MedMij-Endpoint)

Extension: KT2_PublisherId
Id: KT2PublisherId
Description: "Identifier of the publisher (organization or individual). This extension is used as id in the ActivityDefinition."
Context: ActivityDefinition
* ^meta.versionId = "7"
* ^meta.lastUpdated = "2023-01-24T13:04:50.8095698+00:00"
* ^url = "http://koppeltaal.nl/fhir/StructureDefinition/KT2PublisherId"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* . ..1
* . ^comment = "This extension allows every module vendor to search for tasks with linked to their module."
* value[x] only id

ValueSet: KoppeltaalDefinitionTopic_VS
Id: koppeltaal-definition-topic
Title: "Koppeltaal Definition Topic"
Description: "High-level categorization of the definition, used for indicating special patient initialised activities"
* ^meta.lastUpdated = "2024-06-18T00:00:00+02:00"
* ^meta.profile = "http://hl7.org/fhir/StructureDefinition/shareablevalueset"
* ^url = "http://vzvz.nl/fhir/ValueSet/koppeltaal-definition-topic"
* ^identifier.use = #official
* ^identifier.value = "http://vzvz.nl/fhir/ValueSet/koppeltaal-definition-topic"
* ^version = "0.9.1"
* ^status = #active
* ^experimental = false
* ^date = "2024-06-18T00:00:00+02:00"
* insert ContactAndPublisher
* ^immutable = true
* include codes from system DefinitionTopic
* include codes from system KoppeltaalDefinitionTopic

CodeSystem: KoppeltaalDefinitionTopic
Id: koppeltaal-definition-topic
Title: "Koppeltaal Definition Topic"
Description: "High-level categorization of the definition, used for indicating special patient initialised activities"
* ^status = #active
* ^content = #complete
* ^meta.lastUpdated = "2024-06-18T00:00:00+02:00"
* ^url = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-definition-topic"
* ^identifier.use = #official
* ^identifier.value = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-definition-topic"
* ^version = "0.9.0"
* ^experimental = false
* ^date = "2024-06-18T00:00:00+02:00"
* insert ContactAndPublisher
* ^caseSensitive = true
* ^count = 2
* #self-treatment "Zelfhulp" "The definition is related to treatment of the patient, executed by the patient."
* #self-assessment "Zelfstarten" "The definition is related to assessment of the patient, executed by the patient."

