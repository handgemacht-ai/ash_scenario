---
title: ash_scenario examples
type: reference
summary: Self-contained Mix project demonstrating ash_scenario prototypes and the scenario DSL across a multi-tenant launch-workspace domain.
owner: ash_scenario
status: current
tags: [elixir, ash, testing]
last_verified: 2026-09-06
---

# ash_scenario examples

This lightweight Mix project demonstrates how to define prototypes and scenarios
with [`ash_scenario`](../README.md). It contains:

- `lib/ash_scenario/examples/` – a small multi-tenant Ash domain modelling a
  product launch workspace (organizations, projects, members, tasks, checklist
  items)
- `test/` – executable tests that double as documentation for setting up launch
  scenarios and updating checklist items

## Getting started

```bash
cd examples
mix deps.get
mix test
```

The tests exercise both `AshScenario.run_scenario/3` (via `AshScenario.Scenario.run_scenario/3`) and the scenario DSL so you
can see how dependency resolution, overrides, and custom creation functions fit
together.
