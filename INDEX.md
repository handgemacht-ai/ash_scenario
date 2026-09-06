---
type: index
last_verified: 2026-09-06
upstream_commit: PLACEHOLDER
sources:
  - README.md
  - CLAUDE.md
  - examples/README.md
---

# ash_scenario — index

Reusable test-data generation for Ash applications: prototypes declared via a
Spark DSL on resources, plus named test scenarios that override and compose
them with automatic dependency resolution. Elixir library, `mix.exs` @version
0.6.0.

- [AshScenario](README.md) — reference for the prototype/scenario DSL, the `run/2` / `run_all/2` / `run_scenario/3` public API, overrides, authorization, and Clarity integration.
- [Mayor Context (ash_scenario)](CLAUDE.md) — minimal session-stub; full agent context is injected by `gt prime` at session start.
- [ash_scenario examples](examples/README.md) — self-contained Mix project demonstrating prototypes and the scenario DSL across a multi-tenant launch-workspace domain.
