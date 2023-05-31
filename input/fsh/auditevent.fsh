Alias: $AEAltId = http://hl7.org/fhir/StructureDefinition/auditevent-AlternativeUserID

Profile: MyAuditEventProfile
Parent: AuditEvent
Description: "An example reproducing an issue with reslicing extensions."
// agent can have 0..* auditevent-AlternativeUserID extensions.
* agent.extension contains $AEAltId named altid 0..*
// Re-slice the auditevent-AlternativeUserID extensions by their identifier system.
// NOTE: We start w/ the default #value discriminator to ensure we keep that one too.
* agent.extension ^slicing.discriminator[+].type = #value
* agent.extension ^slicing.discriminator[=].path = "url"
* agent.extension ^slicing.discriminator[+].type = #pattern
* agent.extension ^slicing.discriminator[=].path = "value.system"
* agent.extension ^slicing.rules = #open
// Setup a few slices for NPI and SSN
// NOTE: For now, we need to repeat the slicing rules here too in order to keep SUSHI
// happy, but in the future, the rules should ONLY be on the base element slicing.
* agent.extension[altid] ^slicing.discriminator[+].type = #value
* agent.extension[altid] ^slicing.discriminator[=].path = "url"
* agent.extension[altid] ^slicing.discriminator[+].type = #pattern
* agent.extension[altid] ^slicing.discriminator[=].path = "value.system"
* agent.extension[altid] ^slicing.rules = #open
* agent.extension[altid] contains npi 0..1 and ssn 0..1
* agent.extension[altid][npi].valueIdentifier.system 1..1
* agent.extension[altid][npi].valueIdentifier.system = "http://hl7.org/fhir/sid/us-npi"
* agent.extension[altid][ssn].valueIdentifier.system 1..1
* agent.extension[altid][ssn].valueIdentifier.system = "http://hl7.org/fhir/sid/us-ssn"

Instance: MyAuditEventInstance
InstanceOf: MyAuditEventProfile
Title: "My Audit Event Instance"
Description: "An instance of an audit even reproducing an issue with resclicing extensions"
* code = http://dicom.nema.org/resources/ontology/DCM#110122 "Login"
* recorded = "2013-06-20T23:41:23Z"
* agent.who = Reference(Bob)
* agent.extension[altid][npi].valueIdentifier.value = "12345"
* agent.extension[altid][ssn].valueIdentifier.value = "67890"
* source.observer = Reference(Bob)

Instance: Bob
InstanceOf: Patient
Title: "Bob"
Description: "It's Bob!"
* name.given = "Bob"