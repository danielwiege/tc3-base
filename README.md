# tc3-base
The tc3-base library provides a reusable foundation for TwinCAT 3 applications. It includes common data structures, utility functions, base classes, and architectural building blocks, forming an object-oriented framework to standardize and accelerate PLC development.

## Current foundation
- Object hierarchy with shared interfaces (`I_Object`, `I_Base`, `I_MainCall`, `I_FastCall`)
- Program/data-container composition via child registration and call fan-out
- Manager collection with default init + log managers
- One-time init orchestration through `FB_InitManager`
- Lightweight ring-buffer logging (`FB_LogManager` + `FB_Logger`)

## Notes
- Base registration paths are implemented to support idempotent online-change style re-init.
- Test project (`tc3-test`) now demonstrates super-call chaining and basic logger usage.
