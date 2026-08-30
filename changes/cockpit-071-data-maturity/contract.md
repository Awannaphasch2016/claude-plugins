# Change cockpit-071-data-maturity — contract

Per docs/agents/changework.md (karant repo): branch + contract IS the
Change; no PR layer; landing is the sponsor's word.

## 1 · Intent
Sponsor, 2026-08-30: "felt.log + pace.json should be matured to be stored
append-only in database (pace over time, felt over time) rather than in
file. And board spec and golden copy worth a spot in the plugin."

## 2 · Delta record
- plugins/cockpit/skills/felt/SKILL.md — write path: cockpit_felt first
  (via doppler ops COCKPIT_DB_URL), felt.log as never-lose-a-mark fallback
  with replay; charter voice (never interpret the mark) preserved
- plugins/cockpit/ops/0001_cockpit_data.sql + 0001b_policies.sql — the
  applied migration, versioned (password parameterized, never committed)
- plugins/cockpit/boards/BOARD-SPEC.md + APPROVED-run29-baseline.html —
  the Move Board instrument design ships with the plugin (structure only;
  per-run facts are generated)
- version 0.7.0 → 0.7.1

## 3 · Admission criteria + verdicts (run live, 2026-08-30, ops project)
| criterion | verdict |
|---|---|
| tables exist, backfill landed | felt rows: 2 · pace rows: 1 (counts read back via cockpit_writer) |
| append-only holds | UPDATE and DELETE as cockpit_writer: both "permission denied" |
| ensure_rls honored | ops event trigger auto-enabled RLS; per-command INSERT/SELECT policies added; no UPDATE/DELETE policy exists |
| credential canary WRITES | backfill itself was the write; read-back via doppler-stored COCKPIT_DB_URL returned 2 |

## 4 · Landing decision
PENDING — the sponsor lands this branch on main (that act IS the release
of 0.7.1). The database side is already live; landing versions the code
and assets that speak to it.

## 5 · Continuation clause
Consumers read: ops/*.sql for the schema truth · boards/BOARD-SPEC.md for
the board's structure law · the felt skill for the write pattern (DB-first,
file-fallback, replay). Deliberately NOT decided: pace write automation
(karant lens.md appends cockpit_pace rows manually for now); the felt.log
retirement date (file stays as fallback until the replay loop has run in
anger); cockpit_report reading from the table instead of the file.
