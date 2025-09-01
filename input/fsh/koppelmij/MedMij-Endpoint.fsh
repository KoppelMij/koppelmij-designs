Profile: MedMijEndpoint
Parent: Endpoint
Id: MedMij-Endpoint
Description: "The (FHIR) Endpoint (resource) is a representation of a technical contact point of an application that offers one or more eHealth services for a healthcare provider."
* ^status = #draft
* insert ContactAndPublisher
* insert Origin
* connectionType from $koppeltaal-endpoint-connection-type-vs (extensible)
* managingOrganization only Reference(http://nictiz.nl/fhir/StructureDefinition/nl-core-HealthcareProvider-Organization)

ValueSet: EndpointConnectionTypeValueSet
Id: endpoint-connection-type
Title: "Endpoint connection type ValueSet"
Description: "Endpoint connection type ValueSet"
* ^meta.versionId = "1"
* ^meta.lastUpdated = "2023-09-26T12:00:00+02:00"
* ^meta.profile = "http://hl7.org/fhir/StructureDefinition/ValueSet"
* ^extension.url = "http://hl7.org/fhir/StructureDefinition/resource-effectivePeriod"
* ^extension.valuePeriod.start = "2023-09-26T12:00:00+02:00"
* ^url = "http://vzvz.nl/fhir/ValueSet/endpoint-connection-type"
* ^identifier.use = #official
* ^identifier.value = "http://vzvz.nl/fhir/ValueSet/endpoint-connection-type"
* ^version = "2023-09-26"
* ^status = #draft
* ^experimental = false
* ^date = "2023-09-26T12:00:00+02:00"
* insert ContactAndPublisher
* include codes from system KoppeltaalEndpointConnectionType
* include codes from system $endpoint-connection-type

CodeSystem: KoppeltaalEndpointConnectionType
Id: koppeltaal-endpoint-connection-type
Title: "Koppeltaal Endpoint Connection Type"
Description: "Type of endpoint connection as used in Koppeltaal"
* ^status = #draft
* ^content = #complete
* ^meta.versionId = "1"
* ^meta.lastUpdated = "2023-09-26T12:00:00+02:00"
* ^meta.profile = "http://hl7.org/fhir/StructureDefinition/CodeSystem"
* ^extension.url = "http://hl7.org/fhir/StructureDefinition/resource-effectivePeriod"
* ^extension.valuePeriod.start = "2023-09-26T12:00:00+02:00"
* ^url = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-endpoint-connection-type"
* ^identifier.use = #official
* ^identifier.value = "http://vzvz.nl/fhir/CodeSystem/koppeltaal-endpoint-connection-type"
* ^version = "0.1"
* ^experimental = false
* ^date = "2023-09-26T12:00:00+02:00"
* insert ContactAndPublisher
* ^caseSensitive = true
* ^count = 1
* #hti-smart-on-fhir "HTI Smart on FHIR"