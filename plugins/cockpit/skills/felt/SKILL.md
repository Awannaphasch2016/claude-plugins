---
name: felt
description: This skill should be used when the user says "/felt", "mark this as rot", "this session feels tangled", "feels fine", or wants to record how the session feels right now. It appends one timestamped line to felt.log — the ground truth the instrument dials are later checked against.
disable-model-invocation: true
---

# felt

Append one line to `${COCKPIT_DATA:-$HOME/.claude/cockpit}/felt.log`:

```
<ISO-8601 UTC timestamp>\t<transcript>\t<word>\t<optional note>
```

`<word>` is the first argument (`rot`, `tangled`, `fine`, or whatever the user typed); the
note is the rest. `<transcript>` is `$COCKPIT_TRANSCRIPT` if set (the SessionStart hook
persists it), else `-`. Print the line back, and nothing else.

One Bash call. Never interpret the mark, never suggest a remedy — this exists to collect
ground truth for one keystroke, and commentary would make it cost more than that. The
comparison happens later, in `/cockpit:report`.
