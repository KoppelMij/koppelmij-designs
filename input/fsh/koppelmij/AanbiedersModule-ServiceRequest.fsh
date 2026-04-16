Profile: ProviderTasksServiceRequest
Parent: ServiceRequest
Id: pt-ServiceRequest
Description: "Clinical order for a patient-specific digital activity that a healthcare professional requests for a specific patient, such as completing a questionnaire, performing home measurements, viewing educational content, or launching a third-party module."
* insert DefaultNarrative
* ^status = #draft
* insert PublisherAndContactMedMij
* ^purpose = "To represent the clinical order to start or perform a specific digital (eHealth) activity for a patient. This ServiceRequest provides the clinical intent, context, requested schedule, and patient-specific instructions, and can serve as the basis for one or more Task resources that manage execution and tracking of the activity."
* insert Copyright
* .
  * ^short = "ServiceRequest"
  * ^alias = "Zorgopdracht"
* insert Origin
* .
^definition = "Patient-specific clinical order for requesting a digital (eHealth) activity in the ProviderTasks context. It links the patient, the requested activity definition, timing/schedule, and clinical rationale, and may include patient-specific instructions. It can be referenced by Task resources that coordinate execution and status tracking."
* subject only Reference(Patient or Group or Location or Device or http://nictiz.nl/fhir/StructureDefinition/nl-core-Patient)
  * ^definition = "The patient for whom the activity is requested."
* requester only Reference(Practitioner or PractitionerRole or Organization or Patient or RelatedPerson or Device or http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-PractitionerRole)
  * ^comment = """
    Each occurrence of the zib HealthProfessional is normally represented by _two_ FHIR resources: a PractitionerRole resource (instance of [nl-core-HealthProfessional-PractitionerRole](http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-PractitionerRole)) and a Practitioner resource (instance of [nl-core-HealthProfessional-Practitioner](http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthProfessional-Practitioner)). The Practitioner resource is referenced from the PractitionerRole instance. For this reason, sending systems should fill the reference to the PractitionerRole instance here, and not the Practitioner resource. Receiving systems can then retrieve the reference to the Practitioner resource from that PractitionerRole instance.

    In rare circumstances, there is only a Practitioner instance, in which case it is that instance which will be referenced here. However, since this should be the exception, the nl-core-HealthProfessional-Practitioner profile is not explicitly mentioned as a target profile.
    """
* patientInstruction
  * ^short = "Patient-specific instructions"
  * ^definition = "Patient or consumer-oriented instructions related to the requested activity. Use this element to convey patient-specific guidance that should be shown alongside the Task(s) executing this order (e.g. e.g., home blood pressure monitoring for 8 weeks, once daily in the morning)."