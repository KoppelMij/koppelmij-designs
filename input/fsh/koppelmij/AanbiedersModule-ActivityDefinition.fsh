Profile: ProviderTasksActivityDefinition
Parent: ActivityDefinition
Id: pt-ActivityDefinition
Description: "This (FHIR) ActivityDefinition profile describes a reusable definition of a launchable digital (eHealth) activity that can be requested for a patient in MedMij and/or Koppeltaal workflows. It captures the clinical intent and the technical launch information (e.g., endpoint) so that systems can consistently create patient-specific Tasks that reference this definition."
* ^status = #draft
* insert PublisherAndContactMedMij
* insert Origin
* insert Copyright
* . 
  * ^definition = "Definition of a launchable digital (eHealth) activity that can be used as a template for patient-specific workflow requests. The definition may describe different activity types (e.g., launching a third-party module, presenting information, completing a questionnaire, or performing a measurement) and includes the technical launch details needed to invoke the activity in the correct context."
* extension contains
    $koppeltaal-endpoint named endpoint 1..* and
    $koppeltaal-publisher-id named publisherId 0..*
* extension[endpoint] ^short = "Endpoint for launching the activity"
  * ^definition = "Mandatory reference to the service application (endpoint) that provides the launchable eHealth activity. Can be more than one endpoint."
* title 1..
* useContext
  * ^definition = "The context for the content of the eHealth activity."
  * ^comment = "E.g. the activity is targeted to a certain age group."
* usage
  * ^definition = "A detailed description of how the activity definition is used from a clinical perspective. In the MedMij use case, this text is intended for the healthcare professional who is selecting and assigning the activity to the patient."
* topic from http://vzvz.nl/fhir/ValueSet/koppeltaal-definition-topic (extensible)
  * ^short = "E.g. Self-Treatment and Self-Assessment, etc."
  * ^definition = "Descriptive topics related to the content of the activity. The topic is used to indicate that the activity is intended or suitable for initialization by patients."
  * ^binding.description = "High-level categorization of the definition, used for indicating special patient initialised activities"
