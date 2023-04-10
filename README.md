# ReslicedExtension

This reproduces an issue when attempting to re-slice an extension. It is an
extremely pared down and simplified example of the issues John Moehrke has
reported on Zulip
[in](https://chat.fhir.org/#narrow/stream/215610-shorthand/topic/slicing.20an.20extension.20on.20a.20slice)
[several](https://chat.fhir.org/#narrow/stream/179252-IG-creation/topic/slicing.20sliced.20extension)
[threads](https://chat.fhir.org/#narrow/stream/215610-shorthand/topic/Help.20with.20slicing.20on.20an.20extension.20value/near/347451729).
I can't investigate the more complicated bits until I can get past the crash.

In short:
1. We create a profile on [AuditEvent](https://hl7.org/fhir/R4/auditevent.html).
2. We specify that `AuditEvent.entity` can have 0..* [auditevent-Instance](https://hl7.org/fhir/R4/extension-auditevent-instance.html)
extensions.
3. We attempt to re-slice those `auditevent-Instance` extensions by the `type` of their `valueIdentifier`.

FHIR Shorthand representation:
```
Alias: $AEInstance = http://hl7.org/fhir/StructureDefinition/auditevent-Instance

Profile: MyAuditEvent
Parent: AuditEvent
Description: "An example reproducing issue with reslicing extensions."
* entity.extension contains $AEInstance named aeinst 0..*
* entity.extension[aeinst] ^slicing.discriminator[+].type = #value
* entity.extension[aeinst] ^slicing.discriminator[=].path = "url"
* entity.extension[aeinst] ^slicing.discriminator[+].type = #pattern
* entity.extension[aeinst] ^slicing.discriminator[=].path = "value.type"
* entity.extension[aeinst] ^slicing.rules = #open
```

Corresponding generated differential:
```json
{
  "element": [
    {
      "id": "AuditEvent.entity.extension:aeinst",
      "path": "AuditEvent.entity.extension",
      "sliceName": "aeinst",
      "slicing": {
        "discriminator": [
          { "type": "value", "path": "url" },
          { "type": "pattern", "path": "value.type" }
        ],
        "rules": "open"
      },
      "min": 0,
      "max": "*",
      "type": [{
        "code": "Extension",
        "profile": ["http://hl7.org/fhir/StructureDefinition/auditevent-Instance"]
      }]
    }
  ]
}
```

This causes the IG Publisher to crash with the following message:

> java.lang.Exception: Error generating snapshot for /Users/cmoesel/data/fsh/ReslicedExtension/fsh-generated/resources/StructureDefinition-MyAuditEvent(MyAuditEvent): Unable to generate snapshot for http://example.org/StructureDefinition/MyAuditEvent in /Users/cmoesel/data/fsh/ReslicedExtension/fsh-generated/resources/StructureDefinition-MyAuditEvent because Slicing rules on differential (value:url, pattern:value.type (/open)) do not match those on base (value:url (/open) "Extensions are always sliced by (at least) url") - disciminator @ AuditEvent.entity.extension (http://hl7.org/fhir/StructureDefinition/AuditEvent)
>	  at org.hl7.fhir.igtools.publisher.Publisher.generateSnapshots(Publisher.java:5899)
>	  at org.hl7.fhir.igtools.publisher.Publisher.loadConformance(Publisher.java:5006)
>  	at org.hl7.fhir.igtools.publisher.Publisher.createIg(Publisher.java:1082)
>  	at org.hl7.fhir.igtools.publisher.Publisher.execute(Publisher.java:912)
>  	at org.hl7.fhir.igtools.publisher.Publisher.main(Publisher.java:10973)
> Caused by: org.hl7.fhir.exceptions.FHIRException: Unable to generate snapshot for http://example.org/StructureDefinition/MyAuditEvent in /Users/cmoesel/data/fsh/ReslicedExtension/fsh-generated/resources/StructureDefinition-MyAuditEvent because Slicing rules on differential (value:url, pattern:value.type (/open)) do not match those on base (value:url (/open) "Extensions are always sliced by (at least) url") - disciminator @ AuditEvent.entity.extension (http://hl7.org/fhir/StructureDefinition/AuditEvent)
>  	at org.hl7.fhir.igtools.publisher.Publisher.generateSnapshot(Publisher.java:5974)
>  	at org.hl7.fhir.igtools.publisher.Publisher.generateSnapshots(Publisher.java:5897)
>  	... 4 more
> Caused by: org.hl7.fhir.exceptions.DefinitionException: Slicing rules on differential (value:url, pattern:value.type (/open)) do not match those on base (value:url (/open) "Extensions are always sliced by (at least) url") - disciminator @ AuditEvent.entity.extension (http://hl7.org/fhir/StructureDefinition/AuditEvent)
>  	at org.hl7.fhir.r5.conformance.profile.ProfilePathProcessor.processPathWithSlicedBaseDefault(ProfilePathProcessor.java:881)
>  	at org.hl7.fhir.r5.conformance.profile.ProfilePathProcessor.processPathWithSlicedBase(ProfilePathProcessor.java:865)
>  	at org.hl7.fhir.r5.conformance.profile.ProfilePathProcessor.processPaths(ProfilePathProcessor.java:179)
>  	at org.hl7.fhir.r5.conformance.profile.ProfilePathProcessor.processSimplePathWithEmptyDiffMatches(ProfilePathProcessor.java:740)
>  	at org.hl7.fhir.r5.conformance.profile.ProfilePathProcessor.processSimplePath(ProfilePathProcessor.java:219)
>  	at org.hl7.fhir.r5.conformance.profile.ProfilePathProcessor.processPaths(ProfilePathProcessor.java:171)
>  	at org.hl7.fhir.r5.conformance.profile.ProfilePathProcessor.processPaths(ProfilePathProcessor.java:145)
>  	at org.hl7.fhir.r5.conformance.profile.ProfileUtilities.generateSnapshot(ProfileUtilities.java:594)
>  	at org.hl7.fhir.igtools.publisher.Publisher.generateSnapshot(Publisher.java:5966)
>  	... 5 more