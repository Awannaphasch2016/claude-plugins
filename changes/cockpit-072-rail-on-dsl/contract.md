# Change cockpit-072-rail-on-dsl — contract

## 1 · Intent
Sponsor's veto of the agent's deferral, 2026-08-30: "I want to do it now.
Plugin will be updated frequently and the workflow is quite simple — simple
enough to dogfood the DSL, to notice when it breaks, and to fix by
reimplementing the workflow with DSL."

## 2 · Delta record
- plugins/cockpit/rail/rail.line.json — the rail as a Karant DSL line
  (ORGANIZATION layer): stations [trigger, perceive, verify, confirm,
  continue]; one decision, plugin_landing.land, at confirm, surface
  approval, authority human_gate (explicitly CHOSEN)
- plugins/cockpit/rail/rail.mjs — the EXECUTION layer: binds stations to
  steps, revalidates core.ts's two invariants for the JSON caller, honors
  the human stop; merge/tag/push live in `continue` (post-confirm), per
  the factory's own semantics
- scripts/land.sh — now a thin wrapper over the rail; CLI unchanged
- version 0.7.1 → 0.8.0

## 3 · Admission criteria + verdicts
| criterion | verdict |
|---|---|
| the line compiles through the REAL Karant DSL (src/lib/dsl/core.ts) | compiled: {"id":"plugin_landing","uses":[1,2,9,10,11],"decisions":[{"id":"land","at":"confirm"}]} · authority plugin_landing.land → human_gate · surface approval (run 2026-08-30, node 24, via line()/compile()/authorities()/surfaces()) |
| the rail gates ITSELF green | run before landing; SUMMARY in the landing commit |
| CLI compatibility | land.sh --check / land.sh <id> unchanged |

## 4 · Landing decision
The sponsor's explicit "I want to do it now" (2026-08-30) covers build AND
landing; the walk still passes through the confirm stop by construction.

## 5 · Continuation clause
Consumers read rail.line.json for the workflow's truth and rail.mjs for the
step bindings. Deliberately NOT decided: promotion of plugin_landing into
karant's lines.ts (parity with WORKFLOW_TYPES forbids an 11th line there —
the rail stays a JSON caller until DSL v2 relocates that constraint); the
#86 chain-tier preview should treat this as its third trail family.
