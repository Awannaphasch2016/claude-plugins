---
name: shelve
description: Decide what a piece of writing IS and where it goes, by the age test. Use when the user asks "where does this go", "what kind of doc is this", "is this a record or a rule", "shelve this", or before placing any new agent-facing writing (a lesson, a rule, a procedure, a plan, a one-off report) — and when another skill is about to write an agent-facing file and has not yet said which shelf it belongs on.
---

# Shelve

Two questions, asked of a **passage** — never of a file, because one file can
hold several answers and the failure this skill exists to find is a
record-shaped passage sitting on a rule-shaped shelf.

1. **The age test** — *what event would make this untrue?* The answer is the
   type: record · standing rule · procedure · preference · working note ·
   tripwire. A passage will describe itself as a spec while being a history;
   it cannot lie about what would falsify it.
2. **The shelf** — *when must this enter an agent's context?* Every session ·
   when invoked by name · when searched or linked · once by link · when its
   observer looks. Location falls out of the answer.

## The contract — read first, stop if absent

`docs/agents/authoring.md` names this repo's shelf policy (`storage.md`) and
run log. **No contract file → stop and say to run
`/authoring:setup-anak-skills`.** The tables defining the types and shelves
live in the policy file; read them before every run, never answer from
memory — the shelves are editable and this skill must follow them.

## The stations

Walk in order; skip none; say which you are at.

| Station | What happens | Output |
|---|---|---|
| **trigger** | the scope: a path, a folder, or one pasted passage — and which mode asked | the scope, restated |
| **perceive** | split the scope into passages: a heading and its body, a paragraph, a comment block above a check, a code-fence entry. Number them | the passage list, counted |
| **interpret** | the age test per passage: name the **falsifying event** in one clause, then the type it implies. The event comes first; the type is derived, never chosen directly | per passage: event → type |
| **evaluate** | the shelf the type needs vs the shelf the passage is on. A mismatch is a finding; say which direction (costlier than needed, or cheaper) | the mismatch list, with reasons |
| **decide** · **stop** | every passage whose falsifying event is genuinely ambiguous is put to the person with the candidate types and what each would mean. **Do not pick.** | the person's answers |
| **plan** | the moves: destination file and section; the one-line pointer left behind; what must not be rewritten (a record is appended to, never edited) | the move plan |
| **execute** | produce the moves as a **diff** — do not write to the tree. A record file may only grow at its end | the diff |
| **verify** | the repo's own checks (whatever its docs name — lint, guards, link checks); every pointer resolves; every record file changed only by appending | findings, or "none" |
| **confirm** · **stop** | the person approves the diff, or sends it back with a reason | approval |
| **continue** | apply the diff if approved; append the run to the log; if a finding belongs on the repo's issue tracker, say so — filing goes through that tracker's own confirm, never from here | the log entry |

A stop is passed only by the person's answer. Nothing here infers, defaults
or "assumes approval" at **decide** or **confirm**; if the person is not
available, the run parks there and the log says so.

## Modes

| Mode | Trigger | Runs stations | Stops at |
|---|---|---|---|
| `age` | one passage | trigger → interpret | after interpret — reports event and type, nothing moves |
| `where` | one passage or file | trigger → evaluate, then plan | after plan — reports the shelf and the move; asks before executing |
| `audit` | a file or folder | trigger → evaluate | after evaluate — reports every mismatch, grouped by direction, with counts per type |

No mode named → `where` for one thing, `audit` for many.

## Rules the stations must obey

- **Passage, not file.** Never report a whole file as one type.
- **Event before type.** A classification without the falsifying event named
  beside it is not a finding; it is an opinion. Write the event.
- **A record is never rewritten.** Moving one means appending it verbatim at
  the destination and leaving a pointer; correcting one means appending a
  correction. If a move would require editing the text, stop and say why.
- **A rule without a check is reported as such** — its own finding; whether
  it gets a check or is demoted to a record is the person's decision.
- **Code state is out of scope.** A move needing a source change, migration
  or script is named in the plan, and the run stops there.
- **The shelves come from the policy file.** A passage fitting no row is a
  finding about the policy — "no shelf" — never a new row invented mid-run.

## The log — every run, no exceptions

Append one entry to the run log the contract names. Append only:

```
## run N · YYYY-MM-DD · <mode> · <scope>

passages: <count>   types: record <n> · standing rule <n> · procedure <n> · preference <n> · working note <n> · tripwire <n> · no shelf <n>
mismatches: <count> (<n> costlier than needed · <n> cheaper)
stops: decide — <n> put to the person; answers: <summary or "parked">
       confirm — <approved | sent back: reason | parked>
moves: <count applied · count refused>   code-state changes named: <n>
felt: <the person's word, or —>
notes: <anything the stations could not say, one line each>
```

`felt` is the person's word, asked at **continue**, never filled by the agent.

## What this skill does not do

It does not file issues, run migrations, or write a check. It does not decide
an ambiguous type. It does not move a file whose move would change what code
reads. It reports, asks, and — once told — applies a diff.
