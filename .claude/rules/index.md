# Index

## Source Directories
- `lib/ash_scenario/` -- Main library code
- `lib/ash_scenario/dsl/` -- Spark DSL entities: Prototype, Attr, Actor, Create, transformers
- `lib/ash_scenario/scenario/` -- Execution engine: Executor, Registry, Helpers
- `lib/ash_scenario/scenario/executor/` -- Strategy implementations (DatabaseStrategy, StructStrategy)
- `lib/ash_scenario/scenario_dsl/` -- Named scenario DSL: PrototypeOverride, AttributeOverride, transformers
- `lib/ash_scenario/clarity/` -- Optional Clarity dashboard integration
- `lib/ash_scenario/tailwind/` -- Tailwind asset helpers
- `lib/ash_scenario/pre_commit/` -- Git pre-commit formatter hook
- `lib/mix/tasks/ash_scenario/` -- Mix tasks (css_status)
- `test/` -- ExUnit test suite
- `test/support/` -- Test helpers and fixture resources
- `config/` -- Environment-specific configuration
- `examples/` -- Self-contained demo Mix project
- `documentation/` -- Additional docs shipped with hex package
- `assets/` -- CSS source for Clarity integration

## Key Config Files
- `mix.exs` -- Project definition, deps, hex package, aliases, test coverage config
- `mix.lock` -- Dependency lock file
- `config/config.exs` -- Logger and tailwind config
- `config/dev.exs` -- Dev environment config
- `config/test.exs` -- Test environment config
- `usage-rules.md` -- AI agent usage rules (shipped with hex package)

## Important Files
- `lib/ash_scenario.ex` -- Public API: run, run_all, run_scenario, prototype introspection
- `lib/ash_scenario/dsl.ex` -- Spark DSL extension defining the `prototypes` section
- `lib/ash_scenario/info.ex` -- Introspection API for reading prototypes from compiled resources
- `lib/ash_scenario/scenario.ex` -- Core scenario module: Spark DSL + execution routing
- `lib/ash_scenario/scenario/executor.ex` -- Central execution engine with dependency resolution
- `lib/ash_scenario/scenario/executor/database_strategy.ex` -- Ash.create-based persistence strategy
- `lib/ash_scenario/scenario/executor/struct_strategy.ex` -- In-memory struct creation strategy
- `lib/ash_scenario/scenario/registry.ex` -- GenServer prototype registry
- `lib/ash_scenario/sequence.ex` -- Per-attribute sequence counters for runtime evaluation
- `lib/ash_scenario/multitenancy.ex` -- Multi-tenant resource detection and handling
- `lib/ash_scenario/scenario_dsl.ex` -- Named scenario DSL (scenario blocks with extends)
- `README.md` -- Comprehensive usage guide
- `ARCHITECTURE.md` -- Detailed architecture overview
