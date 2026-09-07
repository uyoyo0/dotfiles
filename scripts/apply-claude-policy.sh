#!/usr/bin/env bash
# Merge Claude Code policy into ~/.claude/settings.json.
#
#   shared   dotfiles/claude/policy.json     tracked, same on every machine
#   local    ~/.claude/policy.local.json     untracked, this machine only
#   prefs    dotfiles/claude/prefs.json      seeds a fresh machine, never overwrites
#
# Arrays are UNIONED, so a local deny list adds to the shared one rather than
# replacing it. Objects are deep-merged. Later layers win on scalar conflicts.
# Idempotent: running twice produces a byte-identical file.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS="$HOME/.claude/settings.json"
SHARED="$DOTFILES/claude/policy.json"
PREFS="$DOTFILES/claude/prefs.json"
LOCAL="$HOME/.claude/policy.local.json"

command -v jq >/dev/null 2>&1 || { echo "apply-claude-policy: jq is required" >&2; exit 2; }
[ -f "$SHARED" ] || { echo "apply-claude-policy: missing $SHARED" >&2; exit 2; }

mkdir -p "$HOME/.claude"

# Fresh machine: seed preferences. Existing machine: leave prefs alone.
if [ ! -f "$SETTINGS" ]; then
  if [ -f "$PREFS" ]; then cp "$PREFS" "$SETTINGS"; echo "seeded preferences from dotfiles"
  else echo '{}' > "$SETTINGS"; fi
fi

for f in "$SETTINGS" "$SHARED"; do
  jq -e . "$f" >/dev/null 2>&1 || { echo "apply-claude-policy: $f is not valid JSON" >&2; exit 2; }
done

cleanup() { [ -n "${TMP_LOCAL:-}" ] && rm -f "$TMP_LOCAL"; [ -n "${TMP_OUT:-}" ] && rm -f "$TMP_OUT"; }
trap cleanup EXIT

if [ -f "$LOCAL" ]; then
  jq -e . "$LOCAL" >/dev/null 2>&1 || { echo "apply-claude-policy: $LOCAL is not valid JSON" >&2; exit 2; }
  LOCAL_SRC="$LOCAL"
else
  TMP_LOCAL="$(mktemp)"; echo '{}' > "$TMP_LOCAL"; LOCAL_SRC="$TMP_LOCAL"
fi

read -r -d '' MERGE <<'JQ' || true
def union(a; b):
  reduce (b | to_entries[]) as $e (a;
    if (($e.value | type) == "object") and ((((.[$e.key]) // null) | type) == "object")
      then .[$e.key] = union(.[$e.key]; $e.value)
    elif (($e.value | type) == "array") and ((((.[$e.key]) // null) | type) == "array")
      then .[$e.key] = ((.[$e.key] + $e.value) | unique)
    else .[$e.key] = $e.value
    end
  );
def overlay(a; b):
  reduce (b | to_entries[]) as $e (a;
    if (($e.value | type) == "object") and ((((.[$e.key]) // null) | type) == "object")
      then .[$e.key] = overlay(.[$e.key]; $e.value)
    else .[$e.key] = $e.value
    end
  );
overlay(.[0]; union(.[1]; .[2]))
JQ

TMP_OUT="$(mktemp)"
jq -s "$MERGE" "$SETTINGS" "$SHARED" "$LOCAL_SRC" > "$TMP_OUT"
jq -e . "$TMP_OUT" >/dev/null || { echo "apply-claude-policy: merge produced invalid JSON" >&2; exit 2; }

if cmp -s "$TMP_OUT" "$SETTINGS"; then
  echo "policy already applied, no change"
else
  cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
  mv "$TMP_OUT" "$SETTINGS"; TMP_OUT=""
  echo "policy applied to $SETTINGS"
fi
[ -f "$LOCAL" ] && echo "  (machine-local overlay: $LOCAL)" || echo "  (no machine-local overlay)"
exit 0
