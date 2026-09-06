# AshScenario Architecture

## Overview

AshScenario is a testing and data generation framework for Ash resources that provides a declarative way to create test data with automatic dependency resolution. The architecture follows a modular design with clear separation of concerns between DSL definition, execution strategies, and resource creation. Around the core, three optional submodules provide developer-facing tooling: Clarity introspection dashboards, Tailwind CSS asset management, and a pre-commit formatting hook.

## Core Components

### 1. DSL (Domain Specific Language)

The DSL layer provides the declarative syntax for defining prototypes within Ash resources.

#### Key Modules:
- **`AshScenario.Dsl`** - Main DSL extension that integrates with Ash resources
- **`AshScenario.Dsl.Prototype`** - Defines the structure of individual prototypes
- **`AshScenario.Info`** - Introspection API for accessing DSL-defined prototypes

#### Example Usage:
```elixir
defmodule MyApp.User do
  use Ash.Resource, extensions: [AshScenario.Dsl]

  prototypes do
    prototype :admin_user do
      attr(:name, "Admin")
      attr(:role, :admin)
      attr(:organization_id, :test_org)  # References another prototype
    end
  end
end
```

### 2. Scenario Module

The Scenario module is the core public API for all prototype execution.

#### Key Modules:
- **`AshScenario.Scenario`** - Main entry point with functions like `run/2`, `run_all/2`, `run_scenario/3`
- **`AshScenario.Scenario.Registry`** - Manages prototype registration and dependency resolution
- **`AshScenario.Scenario.Helpers`** - Shared utility functions for attribute resolution and resource tracking

#### Responsibilities:
- Provides the public API surface
- Determines execution strategy from options (`:database` or `:struct`)
- Routes requests to appropriate execution strategies
- Manages the prototype registry

### 3. Executors

The Executor implements a strategy pattern for prototype execution, allowing different behaviors for database persistence vs in-memory struct creation.

#### Core Executor:
- **`AshScenario.Scenario.Executor`** - Central execution engine that:
  - Resolves dependencies between prototypes
  - Manages execution order
  - Handles attribute preparation and resolution
  - Delegates actual resource creation to strategies

#### Strategy Pattern:
The Executor uses a behavior-based strategy pattern with two implementations:

##### DatabaseStrategy (`AshScenario.Scenario.Executor.DatabaseStrategy`)
- Uses `Ash.create/2` for database persistence
- Wraps execution in database transactions for atomicity
- Extracts tenant information for multi-tenant resources
- Returns persisted resources with database-generated IDs

##### StructStrategy (`AshScenario.Scenario.Executor.StructStrategy`)
- Creates in-memory structs without database interaction
- Generates UUIDs for primary keys
- Preserves relationship references as structs (not IDs)
- Ideal for unit tests that don't require persistence

### 4. Public API

The public API provides multiple entry points for different use cases, all routing through a common execution pipeline.

#### API Functions:
- `run/2` - Execute prototypes with specified strategy (`:database` or `:struct`)
- `run_all/2` - Execute all prototypes defined in a resource
- `run_scenario/3` - Execute a named scenario from a test module

#### Strategy Selection:
```elixir
# Database persistence (default)
{:ok, resources} = AshScenario.run(prototypes, strategy: :database)

# In-memory structs
{:ok, resources} = AshScenario.run(prototypes, strategy: :struct)
```

## Data Flow

### 1. Prototype Definition
```
Ash Resource → DSL Extension → Prototype Registration
```

### 2. Execution Flow
```
Public API (Scenario.run/2)
    ↓
Determine strategy from options
    ↓
Executor.execute_prototypes/3
    ↓
Registry.resolve_dependencies/1  [Dependency Resolution]
    ↓
Execute ordered prototypes
    ↓
Strategy.create_resource/3  [DatabaseStrategy or StructStrategy]
    ↓
Return created resources
```

### 3. Dependency Resolution
```
Prototype references (:admin → User)
    ↓
Registry resolves to {Module, :prototype_name}
    ↓
Topological sort based on dependencies
    ↓
Execution in dependency order
```

## Key Design Patterns

### Strategy Pattern
The Executor uses strategies to vary resource creation behavior:
- Strategies implement a common behavior (`@behaviour`)
- Selection happens via the `:strategy` option in the public API
- Each strategy encapsulates its creation logic
- Default strategy is `:database`

### Dependency Injection
Prototypes can reference other prototypes by atom:
- `:org_id` references are resolved to actual created resources
- Dependencies are automatically created in the correct order
- Circular dependencies are detected and prevented

### Builder Pattern
The DSL provides a fluent interface for prototype construction:
- Attributes can be defined incrementally
- Overrides can be applied at runtime
- Custom functions can replace default creation logic

## Extension Points

### Custom Creation Functions
Prototypes can specify custom creation functions:
```elixir
prototypes do
  create function: {MyFactory, :create_user, []}

  prototype :custom_user do
    attr(:name, "Custom")
  end
end
```

### Multitenancy Support
The framework automatically handles multi-tenant resources:
- Detects tenant configuration via Ash multitenancy
- Extracts tenant values from attributes
- Passes tenant context to Ash.create

### Transformers
DSL transformers validate and process prototype definitions:
- **`ValidatePrototypes`** - Ensures prototype validity
- **`RegisterPrototypes`** - Registers prototypes with the registry

## Optional Submodules

### Clarity Integration (`lib/ash_scenario/clarity/`)

An optional integration with Clarity that adds LiveView dashboards for browsing and running prototypes from inside the Clarity UI. The `Introspector` and `Vertex.Prototypes` modules are guarded by `if Code.ensure_loaded?(Clarity)` (`introspector.ex:1`, `vertex/prototypes.ex:1`), so they compile away when Clarity is not a dependency. The two LiveViews (`prototype_live.ex:1`, `prototypes_dashboard_live.ex:1`) are plain modules that depend on `phoenix_live_view` (an optional dependency in `mix.exs`) and do not compile away; they reference `AshScenario.Tailwind.Assets` defensively via `Code.ensure_loaded?` (`prototype_live.ex:100`, `prototypes_dashboard_live.ex:116`).

#### Key Modules:
- **`AshScenario.Clarity.Introspector`** (`introspector.ex`) - Implements `@behaviour Clarity.Introspector` (`introspector.ex:12`); enabled by adding the module to the host app's `:clarity_introspectors` configuration (`introspector.ex:6`)
- **`AshScenario.Clarity.Vertex.Prototypes`** (`vertex/prototypes.ex`) - Clarity vertex for the global "All Prototypes" hub (unique id `"ash_scenario:prototypes"`, dot shape `"folder"`)
- **`AshScenario.Clarity.PrototypeLive`** (`prototype_live.ex`) - Per-resource LiveView for a resource's prototypes
- **`AshScenario.Clarity.PrototypesDashboardLive`** (`prototypes_dashboard_live.ex`) - Global dashboard across all resources that have prototypes

#### How it attaches:
`Introspector.introspect/1` augments Clarity's `:digraph` graph in two ways:
- A global prototypes vertex is attached to the Clarity root vertex, with the `PrototypesDashboardLive` mounted as its content (`introspector.ex:37-52`)
- For every resource vertex satisfying `Info.has_prototypes?(resource)`, a `"Prototypes"` content vertex is attached that mounts `PrototypeLive` for that resource (`introspector.ex:54-66`)

#### Capabilities:
- **Per-resource page** (`PrototypeLive`): lists prototypes and their attributes/virtuals/functions from `Info.prototypes/1`; each prototype can be run with the `:database` or `:struct` strategy via `AshScenario.run/2` (`prototype_live.ex:39`), or all at once via `AshScenario.run_all/1` (`prototype_live.ex:63`); related Ash resources with prototypes are linked for navigation
- **Dashboard** (`PrototypesDashboardLive`): discovers all loaded Ash resources with prototypes by scanning `Application.loaded_applications()` modules (`prototypes_dashboard_live.ex:305`), supports per-resource selection and batch execution via `AshScenario.run_all/1` (`prototypes_dashboard_live.ex:85`)
- Both LiveViews inject the Tailwind CSS assets inline when available (`prototype_live.ex:101`, `prototypes_dashboard_live.ex:117`)

### Tailwind Assets (`lib/ash_scenario/tailwind/assets.ex`)

Optional Tailwind CSS support for the Clarity dashboards, guarded by `if Code.ensure_loaded?(Tailwind)` (`assets.ex:1`). The compiled stylesheet `priv/static/ash_scenario.css` is embedded at compile time via `@external_resource` (`assets.ex:9`) with an MD5-based hash for cache busting (`assets.ex:17-18`).

#### Public API (`AshScenario.Tailwind.Assets`):
- `css_content/0`, `css_hash/0`, `css_path/0`, `compiled?/0` - access to the embedded stylesheet
- `build_css/0` - runs `mix tailwind ash_scenario --minify`, only outside `:prod` (`assets.ex:56-57`)
- `style_tag/0` - inline `<style>` tag with the CSS content
- `link_tag/1` - `<link>` tag pointing at the CSS file with a cache-busting `?v=` parameter (`assets.ex:96-97`)
- `inject/1` - convenience for LiveView templates; `inline: true` yields `style_tag/0`, otherwise `link_tag/1` (`assets.ex:125`)
- `available?/0` - whether CSS is compiled (warns in `:dev` when it isn't) (`assets.ex:139`)
- `classes/2` - Tailwind classes with a `:fallback` when unavailable (`assets.ex:164`)

#### Security:
This module is the asset/HTML-rendering surface and was the site of sobelow `XSS.Raw` findings, fixed in commit 3e7c809:
- `link_tag/1` HTML-escapes the caller-supplied path via `Phoenix.HTML.html_escape/1` before emitting it into the `href` attribute (`assets.ex:102`), rather than interpolating it raw
- `style_tag/0` returns safe iodata directly instead of interpolating CSS content into a `Phoenix.HTML.raw` heredoc

Regression tests for the escaping behavior live in `test/ash_scenario/tailwind/assets_test.exs` (commit 9c96cb8).

### Pre-Commit Formatter (`lib/ash_scenario/pre_commit/formatter.ex`)

A developer-tooling hook — not part of the runtime library — that keeps staged code formatted.

`AshScenario.PreCommit.Formatter.run/1` (`formatter.ex:11`):
1. Gets staged files via `git diff --cached --name-only --diff-filter=d` (`formatter.ex:23`)
2. Filters to Elixir files (`.ex`, `.exs`) and HEEx templates (`.heex`) (`formatter.ex:39`)
3. Runs `mix format` on them (`formatter.ex:46`)
4. Re-stages the formatted files with `git add` (`formatter.ex:55`)

Returns `:ok` on success or `{:error, reason}` if any git/mix step fails. Any step with no matching files is a no-op.
