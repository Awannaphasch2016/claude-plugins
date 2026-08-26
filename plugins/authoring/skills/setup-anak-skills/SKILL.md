---
name: setup-anak-skills
description: Write the per-repo contract that /authoring:semantic-refactor and /authoring:shelve read. Run once per repo, before first use of either.
disable-model-invocation: true
---

# Setup

Scaffold the configuration the authoring skills assume. Prompt-driven, not a
script: explore, present, confirm, then write.

## 1. Explore

Read what exists; assume nothing:

- `docs/agents/authoring.md` — prior run? If present, show it and offer to
  amend rather than overwrite.
- A glossary: `CONTEXT.md` at root, or anything the repo's `CLAUDE.md` /
  `AGENTS.md` names as the shared-language file.
- `docs/adr/`, `docs/record/` — or where this repo actually keeps decisions
  and dated records (search for existing ADRs before proposing the default).
- `docs/agents/storage.md` — a shelf policy may already exist.

## 2. Present and ask

One section, one answer, defaults first so the user can accept in a word:

- **Glossary** — default `CONTEXT.md` at the repo root. Created if absent,
  from `templates/glossary-header.md`: the marker classes (identity ·
  boundary · ancestry · embodiment), borrow-or-coin, altitude, and
  constitutive-vs-current. If a glossary exists WITHOUT that header, offer to
  prepend it — the rules are what `/authoring:semantic-refactor` runs on.
- **ADR home** — default `docs/adr/`, created lazily on first ADR.
- **Records home** — default `docs/record/`.
- **Shelve policy + run log** — default `docs/agents/storage.md` from
  `templates/storage.md` (the age test is universal; the shelf table's
  locations are adjusted to the answers above) and
  `docs/record/shelve-runs.md`, created empty with its header.

## 3. Write

Write `docs/agents/authoring.md` recording the four paths and the date, then
any template files the answers call for. Show every file written.

Done when: `docs/agents/authoring.md` exists, every path in it resolves, and
the glossary carries the marker-rules header.
