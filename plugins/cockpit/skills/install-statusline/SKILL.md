---
name: install-statusline
description: This skill should be used when the user says "/cockpit:install-statusline", "set up the cockpit statusline", or has just installed or updated the cockpit plugin. It points the user-level statusLine setting at the plugin's script, which a plugin cannot do for itself.
disable-model-invocation: true
---

Run exactly this, with one Bash call, and print its output:

```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-statusline.sh"
```

If the path above did not expand, locate the plugin with `claude plugin list` and run
`scripts/install-statusline.sh` from its directory. Do not edit `~/.claude/settings.json`
by hand — the script backs it up, prints the backup name, and writes the one key.
