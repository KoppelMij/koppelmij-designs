Profile: KoppelMijTask
Parent: Task
Id: MedMij-Task
Description: "The (FHIR) Task (resource) describes an eHealth task, that is, an eHealth activity assigned to a patient."
* insert DefaultNarrative
* ^status = #draft
* insert PublisherAndContact
* ^purpose = "KoppelMij allows a patient, from the portal or from a personal health environment (PGO), to use a module (from a third party) at the instruction of the healthcare provider (for example, to complete a questionnaire)."
* insert Copyright
* .
  * ^short = "Task"
  * ^alias = "Task"
* insert Origin
* .
^definition = "An eHealth activity assigned to a patient."
* extension contains
    KT2_Instantiates named instantiates 0..*
* extension[instantiates] ^short = "Reference to ActivityDefinition"
  * ^definition = "Reference to the ActivityDefinition, which conforms to the MedMij ActivityDefinition profile."
  * ^comment = "Use this extension to refer to the ActivityDefinition it instantiates."
  * ^isModifier = false
* instantiatesCanonical only Canonical(MedMij-ActivityDefinition)
  * ^comment = "As of 2023-11-02 this element is no longer used in Koppeltaal 2.0. Use the extension `instantiates` instead."
* partOf only Reference(MedMij-Task)
* code from $koppeltaal-task-code-vs (extensible)
* code ^comment = "See [Koppeltaal Implementation Guide](https://simplifier.net/guide/koppeltaal/Home/Profile-Specific-Notes/Task.page.md?version=current) for more information on the ValueSet"
* for 1..
* for only Reference(http://nictiz.nl/fhir/StructureDefinition/nl-core-Patient)
  * ^definition = "The patient who benefits from the performance of the service specified in the task."
  * ^comment = "In Koppeltaal this element always refers to the patient for whom the task is intended."
  * ^requirements = "Used to track tasks outstanding for a beneficiary.  Do not use to track the task owner or creator (see owner and creator respectively).  This _can_ also affect access control."
* requester only Reference(http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-PractitionerRole)
  * ^comment = """
    Each occurrence of the zib HealthProfessional is normally represented by _two_ FHIR resources: a PractitionerRole resource (instance of [nl-core-HealthProfessional-PractitionerRole](http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-PractitionerRole)) and a Practitioner resource (instance of [nl-core-HealthProfessional-Practitioner](http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-Practitioner)). The Practitioner resource is referenced from the PractitionerRole instance. For this reason, sending systems should fill the reference to the PractitionerRole instance here, and not the Practitioner resource. Receiving systems can then retrieve the reference to the Practitioner resource from that PractitionerRole instance.

    In rare circumstances, there is only a Practitioner instance, in which case it is that instance which will be referenced here. However, since this should be the exception, the nl-core-HealthProfessional-Practitioner profile is not explicitly mentioned as a target profile.
    """
  * ^definition = "In Koppeltaal this element contains a reference to the person requesting the eHealth Task"
* owner 1..
* owner only Reference(http://nictiz.nl/fhir/StructureDefinition/nl-core-CareTeam or http://nictiz.nl/fhir/StructureDefinition/nl-core-Patient or http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-PractitionerRole or http://nictiz.nl/fhir/StructureDefinition/nl-core-ContactPerson)
  * ^definition = "Practitioner, CareTeam, RelatedPerson or Patient currently responsible for task execution."
  * ^comment = "In Koppeltaal the patient is usually the person who executes the task.\r\n\r\nNote, this element is not intended to be used for access restriction. That is left to the relevant applications.\r\n\r\nEach occurrence of the zib HealthProfessional is normally represented by _two_ FHIR resources: a PractitionerRole resource (instance of [nl-core-HealthProfessional-PractitionerRole](http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-PractitionerRole)) and a Practitioner resource (instance of [nl-core-HealthProfessional-Practitioner](http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-Practitioner)). The Practitioner resource is referenced from the PractitionerRole instance. For this reason, sending systems should fill the reference to the PractitionerRole instance here, and not the Practitioner resource. Receiving systems can then retrieve the reference to the Practitioner resource from that PractitionerRole instance.\r\n\r\nIn rare circumstances, there is only a Practitioner instance, in which case it is that instance which will be referenced here. However, since this should be the exception, the nl-core-HealthProfessional-Practitioner profile is not explicitly mentioned as a target profile."

Extension: KT2_Instantiates
Id: instantiates
Description: "Extension added to a Task to refer to the ActivityDefinition which is instantiated by this Task"
Context: Task
* ^url = "http://vzvz.nl/fhir/StructureDefinition/instantiates"
* ^status = #draft
* insert ContactAndPublisher
* value[x] 1..
* value[x] only Reference(MedMij-ActivityDefinition)
  * ^short = "Reference to a MedMij ActivityDefinition"
  * ^definition = "Use this reference rather than the element `Task.instantiatesCanonical` to refer to the ActivityDefinition which is instantiated by this Task."

ValueSet: KoppeltaalTaskCode_VS
Id: koppeltaal-task-code
Title: "Koppeltaal Task Code"
Description: "ValueSet for Task.code"
* ^name = "KoppeltaalTaskCode_ValueSet"
* ^meta.profile = "http://hl7.org/fhir/StructureDefinition/shareablevalueset"
* ^url = "http://vzvz.nl/fhir/ValueSet/koppeltaal-task-code"
* ^identifier.use = #official
* ^identifier.value = "http://vzvz.nl/fhir/ValueSet/koppeltaal-task-code"
* ^status = #active
* ^experimental = false
* ^date = 2024-07-15T12:00:00+02:00
* ^experimental = false
* insert ContactAndPublisher
* include codes from system KoppeltaalTaskCode
* include codes from system http://hl7.org/fhir/CodeSystem/task-code
* include codes from system http://hl7.org/fhir/smart-app-launch/CodeSystem/smart-codes

CodeSystem: KoppeltaalTaskCode
Id: koppeltaal-task-code
Title: "Koppeltaal Task Code"
Description: "Type of Task.code specifically used in Koppeltaal"
* ^status = #active
* ^content = #complete
* ^meta.profile = "http://hl7.org/fhir/StructureDefinition/CodeSystem"
* ^date = 2024-07-15T12:00:00+02:00
* insert ContactAndPublisher
* ^url = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-task-code"
* ^identifier.use = #official
* ^identifier.value = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-task-code"
* ^version = "2024-07-15"
* ^experimental = false
* ^caseSensitive = true
* ^count = 1
* #view "This task can be viewed"

CodeSystem: SmartOnFhirCodes
Id: smart-codes
Title: "SMART on FHIR terminology."
Description: "Codes used in profiles related to SMART on FHIR."
* ^url = "$SmartCodes"
* ^version = "2.2.0"
* ^name = "SmartOnFhirCodes"
* ^status = #active
* ^experimental = false
* ^date = "2024-04-30T19:24:31+00:00"
* insert PublisherInternational
* ^caseSensitive = true
* ^description = "Codes used in profiles related to SMART on FHIR."
* ^content = #complete
* ^count = 4
* #launch-app-ehr "Launch application using the SMART EHR launch"
  * ^definition = "The task suggest launching an application using the SMART on FHIR EHR launch."
* #launch-app-standalone "Launch application using the SMART standalone launch"
  * ^definition = "The task suggest launching an application using the SMART on FHIR standalone launch."
* #smartonfhir-application "SMART on FHIR application URL."
  * ^definition = "The URL of a SMART on FHIR application."
* #smartonfhir-appcontext "Application context related to this launch."
  * ^definition = "The application context (appContext) to be passed to the application after launch."




