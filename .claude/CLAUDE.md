# Claude Instructions

## General Principles (Startup Context)
- Focus on business impact - build what moves key metrics
- Make informed trade-offs: understand the cost of technical debt before taking it on
- Build for maintainability from the start (future you will thank present you)
- Choose boring, proven solutions over novel ones (unless novel solves a real problem better)
- Scope appropriately: build for known requirements, design for likely evolution
- Avoid premature optimization, but don't ignore obvious performance/cost issues
- Delete code aggressively (less code = less maintenance)
- Question whether you need to build it at all (buy/use SaaS when it makes sense)
- Measure what matters (user impact, revenue, costs), not vanity metrics
- When in doubt, prefer simplicity - complex solutions need strong justification

## Code Style & Formatting
- Use Prettier defaults with single quotes
- 2-space indentation for TypeScript/JavaScript
- Descriptive variable names (avoid single letters except loop counters)
- Prefer const over let, avoid var
- Max line length: 100 characters

## Architecture & Design Patterns
- Follow modular architecture (separate concerns)
- Choose patterns appropriate for the problem complexity
- Balance abstraction with simplicity (avoid over-engineering)
- Isolate external dependencies to minimize coupling
- Structure code for the team's familiarity and project needs

## Performance & Cost Optimization
- Profile before optimizing (measure, don't guess)
- Avoid N+1 queries - use joins/eager loading
- Batch operations where possible (bulk inserts, parallel processing)
- Use connection pooling for databases and external services
- Monitor function cold starts and memory allocation
- Cache aggressively (in-memory, distributed cache, CDN)
- Consider pagination/cursor-based loading for large datasets
- Right-size infrastructure (don't over-provision)
- Implement query timeouts to prevent runaway costs
- Archive or delete stale data regularly

## Database & Data Access
- Index for query patterns, not schema purity
- Select only needed fields (avoid SELECT *)
- Use read replicas for heavy read workloads
- Monitor slow query logs and optimize hot paths
- Denormalize when read performance justifies the cost
- Use appropriate data types for the use case
- Consider data retention policies (storage costs add up)

## Caching Strategy
- Cache static/slow-changing data (configurations, reference data)
- Set appropriate TTLs based on data volatility
- Cache at multiple layers (application, CDN, database)
- Invalidate proactively vs lazy expiration based on use case
- Monitor cache hit rates

## API Design
- RESTful endpoints with proper HTTP verbs
- Consistent response format (success/error)
- Version APIs (/v1/, /v2/)
- Validate input with schemas/DTOs
- Document with OpenAPI/Swagger or similar
- Rate limiting to prevent abuse/runaway costs

## Testing & Quality
- Write unit tests for business logic
- Integration tests for API endpoints
- Mock external dependencies in tests
- Aim for >80% coverage on critical paths
- Test error cases, not just happy paths

## Error Handling & Logging
- Use custom exception classes/types
- Log errors with context (user ID, request ID, etc.)
- Don't expose internal errors to API consumers
- Structured logging (JSON format preferred)
- Be mindful of log volume costs

## Security
- Validate and sanitize all user input
- Use parameterized queries (prevent SQL injection)
- Implement rate limiting on public endpoints
- Don't commit secrets (use environment variables)
- Keep dependencies updated

## Git & Version Control
- Meaningful commit messages (imperative mood, all lowercase)
- Small, focused commits
- Feature branches, PR reviews before merge
- Squash commits before merging to main
- Tag releases (semantic versioning)
- Never attribute or co-author Claude in git commits or PRs

## Dependencies & Tooling
- Justify new dependencies (bundle size, maintenance, cost)
- Pin versions in package.json
- Regular dependency audits (npm audit)
- Prefer widely-adopted, maintained libraries
- Document non-obvious tool choices
- Use tsx for TypeScript/JavaScript files, never use ts-node
- Use uvx for Python, never call python directly

## Documentation
- README with setup instructions
- Inline comments for complex logic only
- API documentation (auto-generated where possible)
- Update docs with code changes
- Architecture decision records (ADRs) for major decisions