Profile: ProviderTasksEndpoint
Parent: Endpoint
Id: pt-Endpoint
Description: "This (FHIR) Endpoint profile represents the technical FHIR REST endpoint of a source system (XIS), used by a ProviderModule to retrieve and update task data and the required context for the ProviderModule use case."
* ^status = #draft
* insert PublisherAndContactMedMij
* insert Origin
* extension contains ProviderTaskClientID named clientId 0..*
* connectionType from $koppeltaal-endpoint-connection-type-vs (extensible)
* managingOrganization only Reference(Organization or http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthcareProvider-Organization)