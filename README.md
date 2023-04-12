# ReslicedExtension

This reproduces an issue when attempting to re-slice an extension. It is a pared down and simplified example of the issues John Moehrke has reported on Zulip [in](https://chat.fhir.org/#narrow/stream/215610-shorthand/topic/slicing.20an.20extension.20on.20a.20slice) [several](https://chat.fhir.org/#narrow/stream/179252-IG-creation/topic/slicing.20sliced.20extension) [threads](https://chat.fhir.org/#narrow/stream/215610-shorthand/topic/Help.20with.20slicing.20on.20an.20extension.20value/near/347451729).

In short:
1. We create a profile on [AuditEvent](https://hl7.org/fhir/auditevent.html).
2. We specify that `AuditEvent.agent` can have 0..* [auditevent-AlternativeUserID](https://hl7.org/fhir/extensions/StructureDefinition-auditevent-AlternativeUserID.html)
extensions (using slicename `altid`).
3. We re-slice the `altid` extension slice by `value.system` to create `altid/npi` and `altid/ssn` reslices.
4. We create an instance of the profile that puts data in the `altid/npi` and `altid/ssn` reslices.

When we run it through the IG Publisher, we get QA errors like the following:
> * Profile http://example.org/reslicedextension/StructureDefinition/MyAuditEventProfile|0.1.0, Element matches more than one slice - altid, altid/npi
> * Profile http://example.org/reslicedextension/StructureDefinition/MyAuditEventProfile|0.1.0, Element matches more than one slice - altid, altid/ssn

It seems to me that, by definition, an instance matching a reslice _should_ also match the base slice. As such, these errors seem wrong to me.

FHIR Shorthand representation of the profile:
```
Alias: $AEAltId = http://hl7.org/fhir/StructureDefinition/auditevent-AlternativeUserID

Profile: MyAuditEventProfile
Parent: AuditEvent
Description: "An example reproducing an issue with reslicing extensions."
* agent.extension contains $AEAltId named altid 0..*
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
```

Corresponding generated differential:
```json
{
  "element": [
    {
      "id": "AuditEvent.agent.extension",
      "path": "AuditEvent.agent.extension",
      "slicing": {
        "discriminator": [
          { "type": "value", "path": "url" }
        ],
        "ordered": false,
        "rules": "open"
      }
    },
    {
      "id": "AuditEvent.agent.extension:altid",
      "path": "AuditEvent.agent.extension",
      "sliceName": "altid",
      "slicing": {
        "discriminator": [
          { "type": "value", "path": "url" },
          { "type": "pattern", "path": "value.system" }
        ],
        "rules": "open"
      },
      "min": 0,
      "max": "*",
      "type": [
        {
          "code": "Extension",
          "profile": [
            "http://hl7.org/fhir/StructureDefinition/auditevent-AlternativeUserID"
          ]
        }
      ]
    },
    {
      "id": "AuditEvent.agent.extension:altid/npi",
      "path": "AuditEvent.agent.extension",
      "sliceName": "altid/npi",
      "min": 0,
      "max": "1"
    },
    {
      "id": "AuditEvent.agent.extension:altid/npi.valueIdentifier",
      "path": "AuditEvent.agent.extension.valueIdentifier",
      "min": 1,
      "max": "1"
    },
    {
      "id": "AuditEvent.agent.extension:altid/npi.valueIdentifier.system",
      "path": "AuditEvent.agent.extension.valueIdentifier.system",
      "min": 1,
      "patternUri": "http://hl7.org/fhir/sid/us-npi"
    },
    {
      "id": "AuditEvent.agent.extension:altid/ssn",
      "path": "AuditEvent.agent.extension",
      "sliceName": "altid/ssn",
      "min": 0,
      "max": "1"
    },
    {
      "id": "AuditEvent.agent.extension:altid/ssn.valueIdentifier",
      "path": "AuditEvent.agent.extension.valueIdentifier",
      "min": 1,
      "max": "1"
    },
    {
      "id": "AuditEvent.agent.extension:altid/ssn.valueIdentifier.system",
      "path": "AuditEvent.agent.extension.valueIdentifier.system",
      "min": 1,
      "patternUri": "http://hl7.org/fhir/sid/us-ssn"
    }
  ]
}
```

FHIR Shorthand representation of the example instance:
```
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
```

Corresponding JSON example instance:
```json
{
  "resourceType": "AuditEvent",
  "id": "MyAuditEventInstance",
  "meta": {
    "profile": [
      "http://example.org/reslicedextension/StructureDefinition/MyAuditEventProfile"
    ]
  },
  "agent": [
    {
      "extension": [
        {
          "valueIdentifier": {
            "system": "http://hl7.org/fhir/sid/us-npi",
            "value": "12345"
          },
          "url": "http://hl7.org/fhir/StructureDefinition/auditevent-AlternativeUserID"
        },
        {
          "valueIdentifier": {
            "system": "http://hl7.org/fhir/sid/us-ssn",
            "value": "67890"
          },
          "url": "http://hl7.org/fhir/StructureDefinition/auditevent-AlternativeUserID"
        }
      ],
      "who": {
        "reference": "Patient/Bob"
      }
    }
  ],
  "code": {
    "coding": [
      {
        "code": "110122",
        "system": "http://dicom.nema.org/resources/ontology/DCM",
        "display": "Login"
      }
    ]
  },
  "recorded": "2013-06-20T23:41:23Z",
  "source": {
    "observer": {
      "reference": "Patient/Bob"
    }
  }
}
```