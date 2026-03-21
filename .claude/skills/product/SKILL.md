# Product Skill -- ash_scenario

## Product Summary
A test data generation library for Ash Framework applications. Provides a Spark DSL for defining reusable "prototypes" directly on Ash resources, with automatic dependency resolution, scenario composition, and both database-persisted and in-memory execution strategies. Used for tests, staging seeding, and development data. Published as a hex package.

## Domain/Feature Index
| Feature | Entry Point | Description |
|---------|------------|-------------|
| Prototype DSL | `AshScenario.Dsl` | `prototypes do ... end` blocks on Ash resources defining named test data templates |
| Prototype execution | `AshScenario.run/2` | Create prototypes with automatic dependency resolution |
| Run all | `AshScenario.run_all/2` | Execute every prototype defined on a resource |
| Named scenarios | `AshScenario.Scenario` / `use AshScenario.Scenario` | `scenario :name do ... end` blocks in test modules with attribute overrides |
| Scenario execution | `AshScenario.run_scenario/3` | Run a named scenario from a test module |
| Scenario inheritance | `extends :base_scenario` | Scenarios can extend others, inheriting and overriding prototypes |
| Database strategy | `DatabaseStrategy` | Creates real records via `Ash.create/2` in transactions |
| Struct strategy | `StructStrategy` | Creates in-memory structs without DB (for unit tests) |
| Overrides | `overrides:` option | Per-tuple or top-level attribute overrides at runtime |
| Custom functions | `create function: {M, :f, []}` | Replace default create action with custom factory functions |
| Virtual attributes | `attr :password, "x", virtual: true` | Pass action arguments that are not resource attributes |
| MFA runtime eval | `attr :email, {M, :f, []}` | Evaluate attribute values at runtime with sequence support |
| Authorization | `attr :actor, :admin_user, virtual: true` | Specify actors for policy-aware prototype creation |
| Multitenancy | `AshScenario.Multitenancy` | Auto-detects tenant config and passes tenant context |
| Clarity integration | `AshScenario.Clarity.Introspector` | Optional Prototypes tab in Clarity dashboard |
| Sequence counters | `AshScenario.Sequence` | Per-attribute sequence for unique value generation |

## Core Entities
- **Prototype**: Named test data template defined on an Ash resource with default attributes and relationship references
- **Scenario**: Named test setup in a test module that overrides prototype attributes and composes multiple prototypes
- **Registry**: Global GenServer holding all registered prototype definitions across modules
- **Executor**: Orchestrates dependency resolution, attribute preparation, and strategy-based creation
- **Sequence**: Counter per `{Resource, :prototype, :attr}` for MFA-based unique values

## External Integrations
- **Ash Framework**: Core dependency for resource introspection and data creation
- **Spark**: DSL engine for both prototype and scenario definitions
- **Clarity** (optional): Dashboard integration showing prototypes per resource
- **Phoenix LiveView** (optional): Required only for Clarity integration UI

## Known Limitations
- Circular dependencies between prototypes are detected and raise errors
- Struct strategy does not persist to database; relationship IDs are generated UUIDs not linked records
- Sequence counters must be manually reset between tests via `AshScenario.Sequence.reset()`
- Clarity integration is compile-time optional; requires both Clarity and Phoenix LiveView to be present
- No built-in support for update/destroy actions; prototypes only cover creation
