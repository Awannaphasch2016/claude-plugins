---
name: felt
description: This skill should be used when the user says "/felt", "mark this as rot", "this session feels tangled", "feels fine", or wants to record how the session feels right now. It appends one timestamped line to felt.log — the ground truth the instrument dials are later checked against.
disable-model-invocation: true
---

# felt

*(0.7.1 — the mark's home matured from file to append-only table, per the
sponsor's data-maturity ruling 2026-08-30: subjective ground truth is the
least regenerable data there is, so it lives where nothing can rewrite it.)*

Record the mark in `cockpit_felt` on the ops database, falling back to the
file so a mark is NEVER lost to an unreachable database:

```bash
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ); TR="${COCKPIT_TRANSCRIPT:--}"
# WORD = first argument verbatim; NOTE = the rest verbatim
doppler run --project ops --config dev -- bash -c \
  'psql "$COCKPIT_DB_URL" -v ON_ERROR_STOP=1 -c \
   "insert into cockpit_felt (felt_at,transcript,word,note) values (\$\$'"$TS"'\$\$,nullif(\$\$'"$TR"'\$\$,\$\$-\$\$),\$\$'"$WORD"'\$\$,nullif(\$\$'"$NOTE"'\$\$,\$\$\$\$))"' \
  || printf '%s\t%s\t%s\t%s\n' "$TS" "$TR" "$WORD" "$NOTE" \
       >> "${COCKPIT_DATA:-$HOME/.claude/cockpit}/felt.log"
```

Print back one line — `<TS>\t<TR>\t<word>\t<note>` plus `→ cockpit_felt` or
`→ felt.log (db unreachable)` — and nothing else. `cockpit_writer` holds
INSERT+SELECT only; append-only is enforced by grants AND policy, so the
skill could not rewrite history even if asked. A fallback line in felt.log
is REPLAYED into the table by the next successful write (check the file,
insert its lines with their original felt_at, then truncate it).

One Bash call. Never interpret the mark, never suggest a remedy — this exists to collect
ground truth for one keystroke, and commentary would make it cost more than that. The
comparison happens later, in `/cockpit:report`.
