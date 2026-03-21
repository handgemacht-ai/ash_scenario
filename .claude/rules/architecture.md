# Architecture

## Stack
- **Language:** Elixir ~> 1.18
- **Framework:** Ash Framework ~> 3.5, Spark ~> 2.2 (DSL engine)
- **Optional deps:** Phoenix, Phoenix LiveView, Tailwind (for Clarity dashboard integration)
- **Testing:** ExUnit
- **Quality:** Credo, Dialyxir, Sobelow, ex_check, git_hooks

## Key Modules
- **`AshScenario`**: Public API entry point -- `run/2`, `run_all/2`, `run_scenario/3`, prototype introspection delegates
- **`AshScenario.Dsl`**: Spark DSL extension that adds the `prototypes` section to Ash resources
- **`AshScenario.Dsl.Prototype`**: Struct definition for individual prototype entries
- **`AshScenario.Dsl.Transformers.ValidatePrototypes`**: Compile-time validation of prototype definitions
- **`AshScenario.Info`**: Introspection API for reading DSL-defined prototypes from resources
- **`AshScenario.Scenario`**: Core Spark DSL module for named test scenarios; also routes execution to strategies
- **`AshScenario.Scenario.Executor`**: Central execution engine -- resolves dependencies, prepares attributes, delegates to strategies
- **`AshScenario.Scenario.Executor.DatabaseStrategy`**: Creates resources via `Ash.create/2` with transaction support
- **`AshScenario.Scenario.Executor.StructStrategy`**: Creates in-memory structs without persistence
- **`AshScenario.Scenario.Registry`**: GenServer that maintains a global registry of prototype definitions
- **`AshScenario.Scenario.Helpers`**: Shared utilities for attribute resolution and resource tracking
- **`AshScenario.ScenarioDsl`**: DSL for defining named scenarios with `scenario` blocks in test modules
- **`AshScenario.ScenarioDsl.Transformers.ResolveInheritance`**: Processes `extends` directives between scenarios
- **`AshScenario.Sequence`**: Per-attribute sequence counters for MFA-based runtime value generation
- **`AshScenario.Multitenancy`**: Detects and handles multi-tenant resource configuration
- **`AshScenario.Clarity.Introspector`**: Optional Clarity dashboard integration (Prototypes tab)

## Data Flow
1. **Definition** -- Developers annotate Ash resources with `prototypes do ... end` blocks via the Spark DSL. At compile time, `ValidatePrototypes` checks correctness and `RegisterPrototypes` registers them with the `Registry` GenServer.
2. **Dependency resolution** -- When `run/2` or `run_scenario/3` is called, the `Executor` collects all referenced prototypes, discovers transitive dependencies (e.g., `blog_id: :example_blog`), and performs topological sort to determine creation order.
3. **Attribute preparation** -- For each prototype in order, attributes are merged with any scenario overrides. MFA tuples are evaluated via `Sequence`. Relationship atom references are resolved to actual IDs of previously created resources.
4. **Execution** -- The selected strategy (`DatabaseStrategy` or `StructStrategy`) creates the resource. Database strategy uses `Ash.create/2` inside a transaction; struct strategy builds in-memory structs with generated UUIDs.
5. **Result** -- Created resources are collected into a map keyed by `{Module, :prototype_ref}` (for `run/2`) or by `:prototype_ref` atom (for `run_scenario/3`) and returned to the caller.
