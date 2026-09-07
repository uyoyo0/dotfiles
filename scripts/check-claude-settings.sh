#!/usr/bin/env bash
# Scan a Claude Code settings.json for credential material.
# Usage: check-claude-settings.sh [file ...]
#        cat settings.json | check-claude-settings.sh -
# Exit 0 = clean, 1 = secret found, 2 = usage/dependency error.

set -uo pipefail

RED="\033[0;31m"; YELLOW="\033[0;33m"; GREEN="\033[0;32m"; RESET="\033[0m"
fail_count=0

if ! command -v jq &>/dev/null; then
  echo "check-claude-settings: jq is required" >&2
  exit 2
fi

# Token shapes that are unambiguously credentials.
PATTERNS='sk-ant-[A-Za-z0-9_-]{20,}
sk-[A-Za-z0-9_-]{32,}
gh[pousr]_[A-Za-z0-9]{20,}
github_pat_[A-Za-z0-9_]{20,}
glpat-[A-Za-z0-9_-]{20,}
AKIA[0-9A-Z]{16}
ASIA[0-9A-Z]{16}
xox[baprs]-[A-Za-z0-9-]{10,}
AIza[0-9A-Za-z_-]{35}
-----BEGIN [A-Z ]*PRIVATE KEY-----'

# Env var names that should never carry a literal value.
SECRET_NAME_RE='(?i)(api_?key|token|secret|password|passwd|credential|private_?key|access_?key)'

check_one() {
  local label="$1" content="$2" found=0

  if ! printf '%s' "$content" | jq -e . >/dev/null 2>&1; then
    printf "${RED}✗ %s: not valid JSON${RESET}\n" "$label"
    return 1
  fi

  # 1. Literal token shapes anywhere in the file.
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    if printf '%s' "$content" | grep -qE -- "$pat"; then
      printf "${RED}✗ %s: matches credential pattern /%s/${RESET}\n" "$label" "$pat"
      found=1
    fi
  done <<< "$PATTERNS"

  # 2. env entries whose NAME looks secret and whose value is a literal.
  local bad_env
  bad_env=$(printf '%s' "$content" | jq -r --arg re "$SECRET_NAME_RE" '
    [ paths(type == "object") as $p
      | select($p[-1] == "env")
      | getpath($p) | to_entries[]
      | select(.key | test($re))
      | select(.value | type == "string" and length > 0)
      | select(.value | test("^\\$\\{?[A-Za-z_][A-Za-z0-9_]*\\}?$") | not)
      | (($p | map(tostring) | join("."))+"."+.key) ]
    | .[]' 2>/dev/null)
  if [ -n "$bad_env" ]; then
    while IFS= read -r k; do
      printf "${RED}✗ %s: %s holds a literal value${RESET}\n" "$label" "$k"
      found=1
    done <<< "$bad_env"
  fi

  # 3. Any headers object with a hardcoded value (not a $VAR reference).
  local bad_hdr
  bad_hdr=$(printf '%s' "$content" | jq -r '
    [paths(type == "object" and has("headers")) as $p
     | {p: $p, h: (getpath($p).headers // {})}
     | select(.h | type == "object")
     | .p as $pp | .h | to_entries[]
     | select(.value | type == "string")
     | select(.value | test("\\$\\{?[A-Za-z_]") | not)
     | (($pp | map(tostring) | join(".")) + ".headers." + .key)]
    | .[]' 2>/dev/null)
  if [ -n "$bad_hdr" ]; then
    while IFS= read -r h; do
      printf "${RED}✗ %s: %s is a hardcoded header value${RESET}\n" "$label" "$h"
      found=1
    done <<< "$bad_hdr"
  fi

  # 4. Advisory: keys that point at credential providers.
  local helpers
  helpers=$(printf '%s' "$content" | jq -r '
    [ "apiKeyHelper","otelHeadersHelper","awsCredentialExport","proxyAuthHelper" ]
    | map(select(. as $k | $ARGS.named.doc | has($k)))
    | .[]' --argjson doc "$(printf '%s' "$content")" 2>/dev/null)
  if [ -n "$helpers" ]; then
    while IFS= read -r h; do
      printf "${YELLOW}! %s: %s points at credentials, confirm intentional${RESET}\n" "$label" "$h"
    done <<< "$helpers"
  fi

  return $found
}

[ $# -eq 0 ] && { echo "usage: check-claude-settings.sh <file|-> ..." >&2; exit 2; }

for f in "$@"; do
  if [ "$f" = "-" ]; then
    check_one "(stdin)" "$(cat)" || fail_count=$((fail_count + 1))
  elif [ -f "$f" ]; then
    check_one "$f" "$(cat "$f")" || fail_count=$((fail_count + 1))
  else
    echo "check-claude-settings: no such file: $f" >&2
    exit 2
  fi
done

if [ "$fail_count" -gt 0 ]; then
  printf "\n${RED}Credential material detected. Commit blocked.${RESET}\n"
  exit 1
fi
printf "${GREEN}✓ no credential material found${RESET}\n"
exit 0
