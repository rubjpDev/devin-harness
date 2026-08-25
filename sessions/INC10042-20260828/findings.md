# INC10042 — findings

## Reproduction

Against the DEV mock, with invented data:

```bash
jq -f ../middleware/scripts/normalize.jq fixtures/onboarding-joint-account.json
```

Produces:

```json
{
  "holder": {
    "primaryDoc": "X0000000X",
    "secondaryDoc": ""
  }
}
```

The `""` is still there. The strip runs on `holder`, not inside it.

## The contract

```bash
$ jq '.properties.holder.properties.secondaryDoc' ../middleware/contracts/provider-v3.schema.json
{
  "type": "string",
  "minLength": 9
}
```

`minLength: 9` and not nullable. An empty string **is not valid** against their own
published schema. Our payload is malformed and their rejection is correct.

## Why it starts now

The field has been sent empty forever. What changed is their side: until the 27th
they accepted it and ignored it. Now they validate the schema properly.

```
2026-08-27 17:58  provider-api v3.4.1 -> v3.5.0   (from their public changelog)
2026-08-27 18:03  first rejection matching this pattern
```

Five minutes between their deploy and our first rejection.

## Whose problem this is

**Both, and it should be said that way.** Our payload has been malformed from the
start; their validation change only exposed it. But it arrived in a minor version
with no breaking-change notice, and that breaks compatibility.

Positive finding for the handoff, per `.devin/rules/upstream-vendor.md`:

- The request we send violates their published schema → **ours**.
- The change shipped in a minor with no breaking note → **theirs**.

## Proposed fix, not applied

Extend the empty-value strip to nested objects at
`../middleware/mw-gateway/src/transform/Sanitizer.java:41`. Nine lines.

**Not applied yet**, pending PRV-4417: if they revert the validation, the correct
fix is still the same one but stops being urgent and goes through the normal route
instead of an emergency deploy.

## Status

Handoff package sent 28/08 at 11:20. Their ticket: PRV-4417. No reply yet.
