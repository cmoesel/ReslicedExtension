Alias: $AEAltId = http://hl7.org/fhir/StructureDefinition/auditevent-AlternativeUserID

Profile: MyAuditEventProfile
Parent: AuditEvent
Description: "An example reproducing an issue with reslicing extensions."
// agent can have 0..* auditevent-AlternativeUserID extensions.
* agent.extension contains $AEAltId named altid 0..*
// Slice the auditevent-AlternativeUserID extensions by their identifier system.
// Since we're already in a slice, this is setting up re-slicing rules.
* agent.extension[altid] ^slicing.discriminator[+].type = #value
* agent.extension[altid] ^slicing.discriminator[=].path = "url"
* agent.extension[altid] ^slicing.discriminator[+].type = #pattern
* agent.extension[altid] ^slicing.discriminator[=].path = "value.system"
* agent.extension[altid] ^slicing.rules = #open
// Setup a few slices for NPI and SSN
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
// Add NPI data in the NPI slice. This causes a QA error:
// Element matches more than one slice - altid, altid/npi
* agent.extension[altid][npi].valueIdentifier.value = "12345"
// Add SSN data in the SSN slice. This causes a QA error:
// Element matches more than one slice - altid, altid/ssn
* agent.extension[altid][ssn].valueIdentifier.value = "67890"
* source.observer = Reference(Bob)

Instance: Bob
InstanceOf: Patient
Title: "Bob"
Description: "It's Bob!"
* name.given = "Bob"