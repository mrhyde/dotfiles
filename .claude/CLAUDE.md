# Claude Instructions

## General Principles
- Focus on business impact, build what moves key metrics
- Choose boring, proven solutions over novel ones (unless novel solves a real problem better)
- Scope appropriately: build for known requirements, design for likely evolution
- Delete code aggressively (less code = less maintenance)
- Question whether you need to build it at all (buy/use SaaS when it makes sense)
- Measure what matters (user impact, revenue, costs), not vanity metrics

## Code Style & Formatting
- Use Prettier defaults with single quotes
- 2-space indentation for TypeScript/JavaScript
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
- Meaningful commit messages (imperative mood, all lowercase, NO Conventional Commits prefixes like "fix:", "feat:")
- Small, focused commits
- Feature branches, PR reviews before merge
- Squash commits before merging to main
- Tag releases (semantic versioning)
- Never attribute or co-author Claude in git commits or PRs
- Never commit CLAUDE.md or any Claude-related files (they are gitignored intentionally, never use -f to force add them)

## Dependencies & Tooling
- Justify new dependencies (bundle size, maintenance, cost)
- Pin versions in package.json
- Prefer widely-adopted, maintained libraries
- Use tsx for TypeScript/JavaScript files, never use ts-node
- Use uvx for Python, never call python directly
- Use `npm view <package>` to look up the latest package version instead of web search

## Writing & Communication
- Do not use dashes, long dashes, or em dashes in written output unless absolutely necessary

## Documentation
- Inline comments for complex logic only
- API documentation (auto-generated where possible)
- Update docs with code changes
