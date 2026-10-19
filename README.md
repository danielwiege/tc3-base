# tc3-base

The **tc3-base** library provides a reusable foundation for TwinCAT 3 applications.
It includes common data structures, utility functions, base classes, and architectural building blocks, forming an object-oriented framework to standardize and accelerate PLC development.

---

## Why tc3-base?

PLC teams often re-implement the same foundational patterns in every project:

- state handling and mode transitions,
- device abstraction and lifecycle control,
- error/event reporting,
- timing and scheduling helpers,
- shared utility data types.

`tc3-base` centralizes those recurring concerns into a single reusable core so project code can focus on machine- or process-specific behavior.

## Goals

- **Consistency**: standard naming and behavior across TwinCAT 3 projects.
- **Reusability**: shared components that can be imported into multiple applications.
- **Maintainability**: cleaner separation between framework and project logic.
- **Scalability**: predictable architecture for growing systems and teams.
- **Onboarding speed**: new engineers can follow familiar patterns quickly.

## What this library is intended to include

> The exact package contents depend on your implementation branch, but the framework is designed to host these categories:

### 1. Base types and interfaces

Core interfaces and abstract building blocks for components such as:

- services,
- devices,
- modules,
- stateful units.

### 2. Utility primitives

Reusable low-level helpers for:

- type conversion,
- safe bounds handling,
- bit/word operations,
- common math or timing patterns.

### 3. Diagnostics and status handling

Patterns for structured diagnostics, including:

- status propagation,
- fault/warning/event signaling,
- reset and acknowledgement workflows.

### 4. Architecture conventions

Reference patterns for:

- initialization and startup sequencing,
- cyclic update execution,
- layering and dependency boundaries.

## Typical usage model

A typical project integrates `tc3-base` as the lowest application layer:

1. **Base layer (`tc3-base`)**
   - generic framework code with no machine-specific dependencies.
2. **Domain layer**
   - application modules tailored to your line/cell/process.
3. **Project integration layer**
   - I/O mapping, safety glue, HMI integration, and commissioning-specific logic.

This layering helps keep project customization separate from reusable framework components.

## Who should use this

`tc3-base` is most useful for teams that:

- maintain multiple TwinCAT 3 projects,
- want shared coding standards,
- need a repeatable architecture for long-lived industrial systems,
- expect multiple developers to collaborate across deployments.

## Suggested repository conventions

As the library grows, consider organizing content using clear folders/modules such as:

- `Core/` for interfaces and fundamental abstractions,
- `Utilities/` for helper function blocks/functions,
- `Diagnostics/` for status/error handling,
- `Examples/` for minimal usage demonstrations.

## Contribution guidance

When adding new framework elements:

1. Keep APIs generic (avoid project-specific naming).
2. Document execution expectations (cyclic, edge-triggered, startup-only, etc.).
3. Include a small usage example when practical.
4. Preserve backward compatibility where possible.
5. Prefer composable interfaces over tightly coupled implementations.

## Future enhancements (recommended)

- Add concrete examples showing inheritance/composition patterns.
- Add unit tests (e.g., TcUnit) for utility and state logic.
- Add CI checks for export consistency and documentation validation.
- Publish versioned release notes for integration stability.

---

If you want, this README can be further expanded with:

- a concrete folder-by-folder API index,
- coding style conventions for ST/OOP,
- migration notes between framework versions.
