// All RuleSets used in KoppelMij
RuleSet: Origin
* extension contains
    KT2_ResourceOrigin named resource-origin 0..*
* extension[resource-origin] ^isModifier = false

Extension: KT2_ResourceOrigin
Id: resource-origin
Description: "Defines the author of the resource"
Context: "Account | ActivityDefinition | AdverseEvent | AllergyIntolerance | Appointment | AppointmentResponse | AuditEvent | Basic | BiologicallyDerivedProduct | BodyStructure | CapabilityStatement | CarePlan | CareTeam | CatalogEntry | ChargeItem | ChargeItemDefinition | Claim | ClaimResponse | ClinicalImpression | CodeSystem | Communication | CommunicationRequest | CompartmentDefinition | Composition | ConceptMap | Condition | Consent | Contract | Coverage | CoverageEligibilityRequest | CoverageEligibilityResponse | DetectedIssue | Device | DeviceDefinition | DeviceMetric | DeviceRequest | DeviceUseStatement | DiagnosticReport | DocumentManifest | DocumentReference | EffectEvidenceSynthesis | Encounter | Endpoint | EnrollmentRequest | EnrollmentResponse | EpisodeOfCare | EventDefinition | Evidence | EvidenceVariable | ExampleScenario | ExplanationOfBenefit | FamilyMemberHistory | Flag | Goal | GraphDefinition | Group | GuidanceResponse | HealthcareService | ImagingStudy | Immunization | ImmunizationEvaluation | ImmunizationRecommendation | ImplementationGuide | InsurancePlan | Invoice | Library | Linkage | List | Location | Measure | MeasureReport | Media | Medication | MedicationAdministration | MedicationDispense | MedicationKnowledge | MedicationRequest | MedicationStatement | MedicinalProduct | MedicinalProductAuthorization | MedicinalProductContraindication | MedicinalProductIndication | MedicinalProductIngredient | MedicinalProductInteraction | MedicinalProductManufactured | MedicinalProductPackaged | MedicinalProductPharmaceutical | MedicinalProductUndesirableEffect | MessageDefinition | MessageHeader | MolecularSequence | NamingSystem | NutritionOrder | Observation | ObservationDefinition | OperationDefinition | OperationOutcome | Organization | OrganizationAffiliation | Patient | PaymentNotice | PaymentReconciliation | Person | PlanDefinition | Practitioner | PractitionerRole | Procedure | Provenance | Questionnaire | QuestionnaireResponse | RelatedPerson | RequestGroup | ResearchDefinition | ResearchElementDefinition | ResearchStudy | ResearchSubject | RiskAssessment | RiskEvidenceSynthesis | Schedule | SearchParameter | ServiceRequest | Slot | Specimen | SpecimenDefinition | StructureDefinition | StructureMap | Subscription | Substance | SubstanceNucleicAcid | SubstancePolymer | SubstanceProtein | SubstanceReferenceInformation | SubstanceSourceMaterial | SubstanceSpecification | SupplyDelivery | SupplyRequest | Task | TerminologyCapabilities | TestReport | TestScript | ValueSet | VerificationResult | VisionPrescription"
* ^url = "http://koppeltaal.nl/fhir/StructureDefinition/resource-origin"
* ^version = "0.8.0"
* ^status = #draft
* ^date = "2023-01-24"
* insert ContactAndPublisher
* . ..1
* . ^definition = "Defines the author of the resource."
* . ^comment = "Part of the authorisation model. Upon creation of the resource this extension is set to the device that created it."
* value[x] only Reference(KT2_Device)

RuleSet: PublisherAndContact
* ^publisher = "MedMij"
* ^contact.name = "MedMij"
* ^contact.telecom.system = #email
* ^contact.telecom.value = "info@medmij.nl"
* ^contact.telecom.use = #work

RuleSet: Copyright
* ^copyright = "Copyright and related rights waived via CC0, https://creativecommons.org/publicdomain/zero/1.0/. This does not apply to information from third parties, for example a medical terminology system. The implementer alone is responsible for identifying and obtaining any necessary licenses or authorizations to utilize third party IP in connection with the specification or otherwise."

RuleSet: DefaultNarrative
* ^text.status = #empty
* ^text.div = "<div xmlns=\"http://www.w3.org/1999/xhtml\">No narrative is provided for definitional resources. A human-readable rendering can be found in the implementation guide(s) where this resource is used.</div>"

RuleSet: ContactAndPublisher
* ^publisher = "VZVZ"
* ^contact.name = "VZVZ"
* ^contact.telecom.system = #email
* ^contact.telecom.value = "standaardisatie@vzvz.nl"
* ^contact.telecom.use = #work
* ^copyright = "VZVZ"
* ^jurisdiction = urn:iso:std:iso:3166#NL "Netherlands" 
* ^language = urn:ietf:bcp:47#nl-NL

RuleSet: NLlang
* language = urn:ietf:bcp:47#nl-NL

RuleSet: PublisherInternational
* ^publisher = "HL7 International / FHIR Infrastructure"
* ^contact.name = "HL7 International / FHIR Infrastructure"
* ^contact.telecom.system = #email
* ^contact.telecom.value = "fhir@lists.HL7.org"
* ^contact.telecom.system = #url
* ^contact.telecom.value = "http://www.hl7.org/Special/committees/fiwg"
* ^jurisdiction = $Juristriction#001 "World" 