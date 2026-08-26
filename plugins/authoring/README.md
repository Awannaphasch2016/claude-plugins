# authoring

Discipline for agent-facing writing, extracted from live use on a production
repo (incubated there per its skills-incubation path, promoted here):

| Skill | What it does |
|---|---|
| `/authoring:setup-anak-skills` | Writes the per-repo contract the other two read. **Run once, first.** |
| `/authoring:semantic-refactor` | Change the repo's curated vocabulary without breaking it — nine stations, borrow-or-coin, a Human Gate at confirm |
| `/authoring:shelve` | Decide what a passage IS (age test) and where it goes (shelf), logging every run |

## The host-repo contract

These skills ship **procedure only**. Everything repo-specific lives in files
the host repo owns, named by one contract file:

```
docs/agents/authoring.md    ← written by setup; names the four paths below
├─ glossary                 (default CONTEXT.md — holds terms + marker rules in its header)
├─ ADR home                 (default docs/adr/)
├─ records home             (default docs/record/)
└─ shelve run log           (default docs/record/shelve-runs.md)
```

A skill invoked before the contract exists **stops and says to run setup** —
it never assumes a path and never writes into a repo that has not opted in.

## Cost

Check `claude plugin details authoring` before installing; the description of
every skill here is always-on context in each session. Skills fire on demand.

## Two channels

- **Subscribe** (this plugin): read-only, updates when the marketplace pin moves.
- **Fork**: copy `skills/` into your repo's `.claude/skills/` and own the files.
  The origin repo runs forked copies itself; the plugin is the promotion channel.

Pick one per repo — both at once loads every skill twice.
