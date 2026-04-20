#!/usr/bin/env bash
# PreToolUse/Bash hook: require explicit user approval when a git add/commit
# would touch .md files. Emits permissionDecision=ask; otherwise allows.

set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

ask() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

# Only git add / git commit
if ! printf '%s' "$cmd" | grep -qE '\bgit[[:space:]]+(add|commit)\b'; then
  exit 0
fi

# Any explicit .md path in the command line
if printf '%s' "$cmd" | grep -qE '\.md(\b|$)'; then
  ask "Command references .md file(s). Markdown add/commit requires explicit user approval."
fi

# git add with wildcard/all flags -> inspect working tree for .md
if printf '%s' "$cmd" | grep -qE '\bgit[[:space:]]+add[[:space:]]+(\.|-A|--all|-u|--update|\*)'; then
  if git status --porcelain 2>/dev/null | grep -qE '\.md(\s|$)'; then
    ask "git add would stage .md file(s). Markdown add/commit requires explicit user approval."
  fi
fi

# git commit -> inspect staged (and working tree if -a/--all) for .md
if printf '%s' "$cmd" | grep -qE '\bgit[[:space:]]+commit\b'; then
  if git diff --cached --name-only 2>/dev/null | grep -qE '\.md$'; then
    ask "Staged changes include .md file(s). Markdown commit requires explicit user approval."
  fi
  if printf '%s' "$cmd" | grep -qE '\bcommit\b[^|;&]*([[:space:]]-[a-zA-Z]*a[a-zA-Z]*\b|[[:space:]]--all\b)'; then
    if git diff --name-only 2>/dev/null | grep -qE '\.md$'; then
      ask "git commit -a would include modified .md file(s). Markdown commit requires explicit user approval."
    fi
  fi
fi

exit 0
