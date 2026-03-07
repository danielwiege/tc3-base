# tc3-base Quickstart

This repository now includes a practical scaffold that converts the high-level framework vision into a working project baseline.

## What is included

- Required top-level layer directories for the TwinCAT architecture.
- Starter interface definitions and base abstractions in `9_Base Layer`.
- A PackML state-machine skeleton and manager skeleton in `0_Management Layer`.
- A reference ISA-88 unit module in `2_Unit Layer`.
- Python tooling to validate repository structure and lifecycle contracts.

## Recommended first workflow

1. Validate the scaffold:
   ```bash
   python3 tools/validate_structure.py
   ```
2. Copy/adapt the skeleton function blocks into your TwinCAT project.
3. Implement domain-specific process logic in unit/equipment/control layers.
4. Keep state handling centralized around `FB_PackMLStateMachine`.

## Notes

- The ST snippets are intentionally lightweight and framework-oriented.
- They are intended as starting points, not a complete production runtime.
