Extension: ProviderTaskClientID
Id: pt-ClientID
Description: "The client ID from the Endpoint resource extension is used as an input parameter named “audience” in the token exchange request between PGO and the DVA authorisation server."
* ^url = "http://medmij.nl/fhir/StructureDefinition/ext-ClientID"
* ^status = #draft
* insert PublisherAndContactMedMij
* . ..1
  * ^comment = """
The purpose of client ID is to perform impersonation during token exchange, which results in a launch token of type: medmij:token-type:one-time-code and a smart_launch_context being stored in the DVA authorisation server for that client ID.
 
The launch token is used again as the value for the launch parameter in the SmartOnFhir launch URL. 
 
The module application that receives the SmartOnFhir launch URL requests a new access token with the same client ID, including the launch token as an additional parameter from the DVA authorisation server, which includes the smart_launch_context in the final token response if both the launch token and client ID match.

Translated with DeepL.com (free version)
 """
* value[x] only string
* ^context[0].type = #element
* ^context[0].expression = "Endpoint.extension"