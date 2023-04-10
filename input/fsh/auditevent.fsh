Alias: $AEInstance = http://hl7.org/fhir/StructureDefinition/auditevent-Instance

Profile: MyAuditEvent
Parent: AuditEvent
Description: "An example reproducing issue with reslicing extensions."
// entity can have 0..* auditevent-Instance extensions.
* entity.extension contains $AEInstance named aeinst 0..*
// Slice the auditevent-Instance extensions by their identifier type.
// Since we're already in a slice, this is setting up re-slicing rules.
* entity.extension[aeinst] ^slicing.discriminator[+].type = #value
* entity.extension[aeinst] ^slicing.discriminator[=].path = "url"
* entity.extension[aeinst] ^slicing.discriminator[+].type = #pattern
* entity.extension[aeinst] ^slicing.discriminator[=].path = "value.type"
* entity.extension[aeinst] ^slicing.rules = #open

// I won't even bother defining the slices yet, because just setting up
// the slicing rules already causes the IG Publisher to crash:
//
// > Unable to generate snapshot for http://example.org/StructureDefinition/MyAuditEvent
// > in /path-to/ReslicedExtension/fsh-generated/resources/StructureDefinition-MyAuditEvent
// > because Slicing rules on differential (value:url, value:value.type (/open)) do not
// > match those on base (value:url (/open) "Extensions are always sliced by (at least) url")
// > - disciminator @ AuditEvent.entity.extension