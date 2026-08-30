#!/usr/bin/env bash
# land.sh — thin wrapper; the rail itself is a Karant DSL line executed by
# plugins/cockpit/rail/rail.mjs (org layer: rail.line.json). Same CLI as v1:
#   land.sh --check <id>   walk to the human stop (gates only)
#   land.sh <id>           the landing word
set -euo pipefail
D="$(cd "$(dirname "$0")/.." && pwd)"
if [ "${1:-}" = "--check" ]; then shift; exec node "$D/plugins/cockpit/rail/rail.mjs" "${1:?change-id}"; fi
exec node "$D/plugins/cockpit/rail/rail.mjs" "${1:?change-id}" --land
