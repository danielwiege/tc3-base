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

## Automatic build on GitHub push

The workflow in `.github/workflows/twincat-build.yml` runs on every push and can
also be started manually from GitHub Actions. Compilation runs on the Windows
buildserver using `tc3-build` and **Visual Studio 2019** (`--host vs2019`).
It builds and installs the current `Tc3_Base` library first, then compiles
`tc3-test` against it. The generated library and build logs are uploaded as a
GitHub Actions artifact. Compiling `tc3-test` does not execute PLC runtime tests.

One-time buildserver setup:

**Detailed step-by-step setup guide:**
[Set up the buildserver](docs/Buildserver-Setup.md) — covering download, extraction,
.NET Runtime installation, GitHub variables, runner registration, and troubleshooting.

1. Install Visual Studio 2019 with the matching TwinCAT XAE integration and
   project dependencies, plus a working distribution of `tc3-build` (0.4.0 or
   compatible), including its runtime and dependency files.
2. In this GitHub repository, open **Settings → Actions → Runners → New
   self-hosted runner**, choose Windows x64, and follow the displayed setup
   commands **on the buildserver**. Add the custom label `twincat-vs2019`.
3. Run the runner in the logged-in build user's interactive session. The runner
   and Visual Studio must use the same user and elevation level for COM/DTE
   automation. Reserve this runner for TwinCAT builds; other repositories must
   not install libraries concurrently on it.
4. Under **Settings → Secrets and variables → Actions → Variables**, add
   `TC3_BUILD_EXE` with the full buildserver path to `Tc3Build.exe` (or make the
   executable available on the runner's `PATH`).
5. Push the workflow, then check **Actions → TwinCAT build** for the result.
   A queued job requires an online runner with all four workflow labels.

Build commands are maintained in `scripts/Build-TwinCat.ps1`. The pipeline does
not activate a TwinCAT configuration or start/restart a PLC runtime.
