# Claude Instructions

## General Principles
- Focus on business impact, build what moves key metrics
- Choose boring, proven solutions over novel ones (unless novel solves a real problem better)
- Scope appropriately: build for known requirements, design for likely evolution
- Delete code aggressively (less code = less maintenance)
- Question whether you need to build it at all (buy/use SaaS when it makes sense)
- Measure what matters (user impact, revenue, costs), not vanity metrics

## Code Style & Formatting
- Use oxfmt for formatting (not Prettier, not Biome); configure via `.oxfmtrc.json`
- Single quotes, 2-space indentation for TypeScript/JavaScript
- Descriptive variable names (avoid single letters except loop counters)
- Prefer const over let, avoid var
- Max line length: 120 characters
- No dead code, no commented-out code, no "just in case" parameters or config
- Don't add types, interfaces, or enums unless they are used in more than one place

## Architecture
- Isolate external dependencies behind interfaces/wrappers to minimize coupling
- Choose patterns appropriate for the problem complexity (don't over-abstract)
- No wrapper functions that just call another function, no "utils" or "helpers" files that become junk drawers
- Inline simple logic; extract only when there are 3+ genuine call sites
- If a file, function, or abstraction layer doesn't justify its existence, delete it

## Error Handling & Logging
- Structured logging (JSON format preferred)
- Log errors with context (user ID, request ID, etc.)
- Don't expose internal errors to API consumers

## Testing
- Mock external dependencies in tests, not internal modules
- Aim for >80% coverage on critical paths
- Test error cases, not just happy paths

## Git & Version Control
- Commit messages: imperative mood, all lowercase, NO Conventional Commits prefixes; single subject line only, no body unless explicitly asked
- Small, focused commits
- Feature branches, PR reviews before merge
- Squash commits before merging to main
- Tag releases (semantic versioning)
- Never commit CLAUDE.md or any Claude-related files (they are gitignored intentionally, never use -f to force add them)

### Undercover Mode
All git output (commit messages, PR titles, PR descriptions, branch names, code comments) must read as if written entirely by a human developer. Never reveal AI involvement.

NEVER include:
- "Claude", "Claude Code", "AI", "LLM", "assistant", "generated", or any AI-related terms
- Co-Authored-By, Generated-By, or any AI attribution trailers
- Phrases like "as requested", "happy to help", "here's what I did", or other assistant-style language
- Comments in code like "AI-generated", "added by Claude", or similar markers

## Dependencies & Tooling
- Justify new dependencies (bundle size, maintenance, cost)
- Pin versions in package.json
- Prefer widely-adopted, maintained libraries
- Use tsx for running TypeScript/JavaScript files, never use ts-node
- Use `npm view <package>` to look up the latest package version instead of web search

### TypeScript / JavaScript
- Always target the latest stable TypeScript version
- **Linting**: oxlint (not ESLint, not Biome); configure via `oxlint.config.ts`
- **Formatting**: oxfmt (not Prettier, not Biome); configure via `.oxfmtrc.json`
- **Building libraries**: tsdown (Rolldown + oxc under the hood) for ESM output and .d.ts generation
- **Building apps**: Vite for dev/build; prefer Astro for web apps/sites (not Next.js, not Nest.js)
- **Testing**: Vitest with v8 coverage (not Jest)
- **Package validation**: publint + arethetypeswrong for library packages before publish
- **Package manager**: pnpm (not npm, not yarn, not Turbopack)

### Python
- NEVER use python, python3, pip, or pip3 directly. Always use uv/uvx:
  - Run a script: `uv run script.py` (not `python script.py`)
  - Run with deps: `uv run --with package script.py` (not `pip install package && python script.py`)
  - Run a CLI tool: `uvx tool` (not `pip install tool && tool`)
  - Add a dependency: `uv add package` (not `pip install package`)
  - Run in a project: `uv run` respects pyproject.toml automatically
  - Look up package info: `uv pip show <package>` (not `pip show`)

## Writing & Communication
- Do not use dashes, long dashes, or em dashes in written output unless absolutely necessary

## Documentation
- Inline comments for complex logic only
- API documentation (auto-generated where possible)
- Update docs with code changes
- When asked to "add/update documentation", update user-facing files (docs/, README, ADRs, etc.) — NOT CLAUDE.md. CLAUDE.md is only updated when explicitly asked.

