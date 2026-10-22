#!/usr/bin/env bash
# Python hooks. PreToolUse/Bash: block python and pip invocations so uv is used instead.
# PostToolUse/Edit|Write: format edited .py files with ruff.
# Reads the tool call JSON on stdin; exit 2 blocks the call and sends stderr back.

set -u

input=$(cat)

case $(jq -r '.hook_event_name // ""' <<<"$input") in
  PreToolUse)
    cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
    invocation='(^|[;&|(]|`|\$\(|\bsudo |\benv |\bxargs |\btime |\bnice )[[:space:]]*([^[:space:];&|]*/)?(python[0-9.]*|pip[0-9]*)([[:space:]]|$)'
    if printf '%s\n' "$cmd" | grep -qE "$invocation"; then
      echo 'BLOCKED: Never use python/pip directly. Use uv run, uvx, or uv add instead. See CLAUDE.md for examples.' >&2
      exit 2
    fi
    ;;
  PostToolUse)
    file=$(jq -r '.tool_input.file_path // ""' <<<"$input")
    case $file in
      *.py) uvx ruff format "$file" >/dev/null 2>&1 ;;
    esac
    ;;
esac

exit 0
