---
name: deslop
description: >
  De-LLMify text. Transforms AI-generated prose into text indistinguishable from
  what a working developer would write. Strips vocabulary tells, structural tells,
  and tone tells. Supports intensity levels: clean, dev (default), raw.
  Use when user says "deslop this", "make it sound human", "remove AI voice",
  "too LLM", "sounds like AI", "humanize this", "more human", or invokes /deslop.
---

Strip the LLM off text. Output should read like a developer wrote it on the first try. Not polished. Not perfect. Not enthusiastic. Just normal.

## Persistence

NOT a persistent mode. One-shot transform per invocation. User provides text (or points to a file, diff, PR), you rewrite it, done.

Default: **dev**. Switch: `/deslop clean|dev|raw`.

## Rules

### Replace

LLM vocabulary is the biggest tell. Swap it.

| Kill                        | Use instead                            |
| --------------------------- | -------------------------------------- |
| utilize, leverage           | use                                    |
| implement, facilitate       | build, make, do                        |
| ensure, verify              | check, make sure                       |
| comprehensive               | full, or just drop it                  |
| robust                      | solid, or drop it                      |
| streamline                  | simplify, clean up                     |
| enhance                     | improve, add to                        |
| seamless                    | smooth, easy                           |
| straightforward             | simple, easy                           |
| delve, dive into            | dig into, look at                      |
| multifaceted                | complex, or drop it                    |
| nuanced                     | subtle, tricky                         |
| holistic                    | overall, big picture                   |
| optimal, optimized          | best, fastest, good enough             |
| subsequently, additionally  | then, after that, also                 |
| functionality               | feature, what it does                  |
| methodology                 | approach, way                          |
| in order to                 | to                                     |
| it's worth noting that      | (drop. just state the thing)           |
| it's important to mention   | (drop)                                 |
| as mentioned earlier        | (drop, or "like I said")               |
| Great question!             | (drop entirely)                        |
| Absolutely! / Certainly!    | (drop, or "yeah")                      |
| That's a fantastic approach | (drop, or "that works")                |
| I hope this helps           | (drop)                                 |
| feel free to ask            | (drop, or "lmk if you have questions") |
| key takeaway                | (drop, or "main thing")                |

### Drop

Structural fingerprints that scream "an LLM wrote this."

- Opening paragraph that restates the user's question back to them
- Closing paragraph that summarizes everything you just said
- "Let me explain..." / "Let me walk you through..." openers
- Forced parallel construction on every list item (real lists are messy)
- Every bullet starting with an action verb in the exact same tense
- Numbered lists for fewer than 4 items. Use prose or unordered bullets.
- Excessive **bold**. Bold only genuinely key terms, not every other phrase.
- Em dashes used more than once per paragraph. Use commas, parens, or split the sentence.
- Section headers for content shorter than 3 lines
- "In this section we will..." / "Below you'll find..."
- "Here is a summary of..." / "To summarize..."
- Emoji used as bullet points or section markers (unless the original had them)

### Add

Human markers that real developers actually use in writing.

- **Contractions**: don't, won't, it's, can't, shouldn't, we're, they'll, that's, I'd, there's, hasn't, doesn't
- **Dev abbreviations** where natural: config, repo, env, deps, auth, impl, fn, DB, API, CLI, PR, CI/CD, infra, k8s
- **Casual connectors**: so, basically, anyway, also, plus, though, actually, honestly, fwiw, tbh
- **Sentence fragments** where natural: "Works fine on Linux. Not so much on Windows."
- **Conjunction starters**: But, And, So, Or at the start of sentences
- **Parenthetical asides** (like this one)
- **Uneven paragraph lengths**. Not every paragraph needs 3 sentences.
- **Mixed punctuation in lists**. Some bullets end with periods, some don't. Real people are inconsistent.
- **Short sentences mixed with longer ones.** Vary the rhythm. Don't write every sentence at the same length with the same structure.

## Context

The skill auto-detects what kind of text it's rewriting and adjusts.

**Commit message:**
Strip to bare minimum. Imperative mood. No "This commit..." or "Changes include..."
Body only when the diff doesn't explain the why. One line is usually enough.

**PR description:**
Short summary up top, not a wall of text. Bullet the changes, don't narrate them.
Skip "## Summary" headers for short PRs. Just write the thing.
Test plan can be terse: "tested locally, added unit test for the edge case"

**Code comment:**
One line when one line is enough.
No "This function is responsible for..." Just say what it does.
`// TODO:` and `// HACK:` and `// NOTE:` are fine.

**README / docs:**
More structure is OK here but still cut the fluff.
Don't open with "Welcome to..." or "This project is a comprehensive..."
Get to what it does in sentence one. Examples > explanations.

**Slack / chat / async message:**
Short. Fragments OK. Lowercase OK. Can start mid-thought.
Skip "I hope this message finds you well." Skip sign-offs unless it's formal.

## Intensity

| Level     | What changes                                                                                                                                                                          |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **clean** | Swap LLM vocabulary and tone. Keep structure, full sentences, formatting intact. Minimal intervention. Good for docs that need to stay professional but sound less robotic.           |
| **dev**   | Full Replace + Drop + Add. Sounds like a working developer who writes clearly but doesn't obsess over polish. Contractions, fragments, casual connectors, uneven formatting. Default. |
| **raw**   | Terse, fragments, heavy abbreviations, lowercase starts, dropped words. Sounds like a dev typing in Slack between meetings. Not sloppy, just fast.                                    |

## Examples

### Commit message

Input:

> feat: Implement comprehensive user authentication flow with robust token management and seamless session handling

- clean: `feat: add user auth flow with token management and session handling`
- dev: `feat: add user auth with token refresh and sessions`
- raw: `feat: auth flow + token refresh`

### PR description

Input:

> ## Summary
>
> This pull request implements a comprehensive refactoring of the authentication module to enhance security and streamline the token refresh mechanism. The changes ensure that expired tokens are handled seamlessly, providing a robust user experience. Additionally, the error handling has been improved to facilitate better debugging.
>
> ## Changes
>
> - **Enhanced** the token refresh logic to handle edge cases
> - **Streamlined** the session management flow
> - **Improved** error messages for better debugging experience
> - **Added** comprehensive test coverage for the new functionality

clean:

> Refactored the auth module to improve security and fix token refresh. Expired tokens are now handled properly and error handling is clearer.
>
> - Fixed token refresh edge cases
> - Simplified session management
> - Improved error messages
> - Added tests

dev:

> Refactored auth module. Token refresh was broken for expired sessions, this fixes that plus cleans up error handling.
>
> - fix token refresh edge cases
> - simplify session management
> - better error messages for debugging
> - added tests

raw:

> auth module refactor, token refresh was busted on expired sessions
>
> - fix token refresh edge cases
> - clean up session mgmt
> - better error msgs
> - tests

### Code comment

Input:

> // This function is responsible for validating the user's authentication token
> // by checking its expiration date and ensuring it hasn't been revoked.
> // It leverages the token store to perform comprehensive validation.

- clean: `// Validates the auth token: checks expiration and revocation status.`
- dev: `// check if token is expired or revoked`
- raw: `// validate token (expiry + revocation)`

### README opener

Input:

> Welcome to ProjectX! This is a comprehensive, robust solution designed to streamline your development workflow. ProjectX leverages cutting-edge technology to facilitate seamless integration with your existing tools, ensuring an optimal developer experience.

- clean: `ProjectX simplifies your development workflow. It integrates with your existing tools and gets out of your way.`
- dev: `ProjectX makes your dev workflow simpler. Plugs into your existing tools without a bunch of setup.`
- raw: `ProjectX. Simpler dev workflow, plugs into your existing tools.`

### Slack message

Input:

> I've completed the implementation of the feature and pushed it to the repository. The changes ensure that the authentication flow handles edge cases properly. I've also added comprehensive test coverage. Please let me know if you have any questions or concerns!

- clean: `Finished the feature and pushed it. Auth flow handles edge cases now, and I added tests. Let me know if you have questions.`
- dev: `pushed the auth fix, handles the edge cases now. added tests too. lmk if anything looks off`
- raw: `pushed auth fix + tests, should handle the edge cases now`

## Auto-Clarity

Do NOT deslop:

- Security advisories, CVE descriptions, vulnerability disclosures. Precision matters, casual tone is wrong here.
- Legal text, license headers, terms of service
- Formal API documentation intended for external consumers (OpenAPI descriptions, published SDK docs)
- Compliance text (SOC2, HIPAA, GDPR notices)
- Direct quotes from other people. Don't rewrite someone else's words.
- Text the user explicitly says to leave alone

If the input mixes sensitive and regular text (e.g., a PR with a security note), deslop the regular parts and leave the sensitive parts intact. Call out what you skipped and why.

## Boundaries

**Never touch:**

- Code blocks (fenced or indented)
- Inline code (backtick content)
- URLs, links, file paths
- Command-line invocations
- Version numbers, SHAs, hashes
- Error messages and stack traces (keep exact)
- Structured data (JSON, YAML, TOML, XML)
- Regex patterns
- Environment variable references

**Never invent content.** Output must say the same things as input. Don't add information, opinions, or technical claims that weren't there. Don't remove actual technical content. Only remove stylistic LLM tells.

**Never introduce factual errors.** Casual grammar is fine. Wrong flag names or wrong API calls are not. "config" instead of "configuration" is fine. Changing `--dry-run` to `--dryrun` is not.

**Output the rewritten text only.** Don't explain what you changed. Don't add a "here's what I did" summary. Just output the deslopped text. If the user asks what changed, then explain.
