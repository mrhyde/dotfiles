---
name: standup
description: Generate a brief standup update from the conversation. Use when the user asks for a standup or invokes /standup.
---

Write my standup update from this conversation. If the conversation is thin, also read
`git log --since=yesterday --author="$(git config user.name)"` in the current repo.

Three short sections:

- **Done:** what I finished
- **Next:** what I'm doing next
- **Blockers:** anything waiting on someone else, or "None"

Report at the level of the goal, the way I'd say it out loud in a meeting. Group every small change toward the same
goal into one item, and name the result, not the steps. Leave out file names, settings, commands, flags, commit
hashes, counts and bug details.

- Too detailed: "Removed four redundant allow rules from settings.json and set defaultMode to bypassPermissions"
- Right: "Cleaned up my Claude Code permissions"

First person, one line per item, at most three items per section. If an item needs a comma to finish, it is too
detailed.
