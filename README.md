# tc3-base

The **tc3-base framework** is a reusable foundation for TwinCAT 3 applications, focused on OOP, standardized machine states, and robust runtime architecture.

## Target Vision

A consistent PLC framework that:
- increases object-oriented reusability,
- enables ISA-88-compliant module and recipe structures,
- provides PackML-compliant state handling,
- clearly separates real-time logic (`FastCall`) from orchestration logic (`MainCall`),
- scales across multiple machine modules through a manager concept.

---

## 1) Architectural Principles (OOP Design)

### Core Principles
- **Single Responsibility**: each class has one clearly defined purpose.
- **Composition over inheritance**: modules are assembled from services/components.
- **Interface-first design**: dependencies use `INTERFACE` contracts instead of concrete classes.
- **Lightweight dependency injection**: instances are built centrally (e.g., in `AppManager`) and passed into modules.

### Proposed Base Building Blocks
- `I_Initializable`, `I_Executable`, `I_Resettable`, `I_Diagnosable`
- `FB_BaseComponent` (lifecycle, status, diagnostics)
- `FB_BaseModule` (machine module with command/state handling)
- `FB_Service` (e.g., time, logging, alarming)

### Naming and Structure Concept
- `Domain/` (process logic, modules, units)
- `Application/` (orchestration, use cases, sequences)
- `Infrastructure/` (hardware abstraction, logger, persistence)
- `Framework/` (base classes, interfaces, managers)

---

## 2) ISA-88 Integration

### Modular Modeling
- Map ISA-88 levels to software structure:
  - **Enterprise / Site / Area** as configuration context
  - **Process Cell / Unit / Equipment Module / Control Module** as OOP class hierarchy
- Each unit encapsulates equipment modules and exposes standardized commands.

### Recipe Model
- Clear separation between:
  - **Equipment Procedure** (what the machine can do),
  - **Control Recipe** (how an order is executed).
- Recipe parameters should be versioned data sets (e.g., structure + CRC/version).

### Phase Model
- Phases as reusable function blocks:
  - `Start`, `Hold`, `Restart`, `Abort`, `Stop`, `Complete`.
- Phase status is synchronized with PackML state.

---

## 3) PackML State Machine

### State Model
Implement PackML base states including transition rules, e.g.:
- `Aborted`, `Clearing`, `Stopped`, `Starting`, `Idle`, `Suspended`, `Execute`, `Stopping`, `Completing`, `Complete`, `Holding`, `Held`, `Unholding`, `Suspending`, `Unsuspending`, `Resetting`.

### Implementation Recommendation
- `FB_PackMLStateMachine` as a central, testable state engine.
- State transitions triggered by commands (`CmdStart`, `CmdStop`, `CmdHold`, ...).
- Standardized signals:
  - `StateCurrent`, `StateRequested`, `Mode`, `CommandAccepted`, `CommandDeniedReason`.

### Benefits
- Consistent behavior across all modules,
- easier HMI/MES integration,
- reduced commissioning time.

---

## 4) Dual-Thread Model (`FastCall` + `MainCall`)

### Goal
Deterministic high-speed signal processing in `FastCall` and robust process/business logic in `MainCall`.

### Responsibility Split
- **FastCall (short task cycle, high priority)**
  - read/write I/O,
  - safety-adjacent interlocks,
  - fast control/trigger logic,
  - preprocessing and timestamping.

- **MainCall (longer task cycle)**
  - PackML and sequence logic,
  - ISA-88 phase/recipe execution,
  - alarms, logging, diagnostics,
  - order and interface logic.

### Thread Communication
- Use double-buffer/mailbox pattern:
  - `FastToMain` (measurements, events),
  - `MainToFast` (setpoints, enables).
- Exchange data only via defined DTO structures and handshake flags.
- Avoid direct side effects across thread boundaries.

### Important Extension
- Monitor cycle-time violations per thread (watchdog + statistics).

---

## 5) Manager Concept

### Central Manager Roles
- `AppManager` – composition root, bootstrapping, lifecycle.
- `ModuleManager` – manages all units/modules and cyclic execution.
- `StateManager` – system-wide PackML/mode coordination.
- `RecipeManager` – load, validate, activate recipes.
- `AlarmManager` – alarm classes, acknowledgment, history.
- `SafetyManager` (optional) – central safety-relevant enable handling.

### Manager Rules
- Managers coordinate but do not contain deep process logic.
- Modules remain independently testable.
- Unified lifecycle methods:
  - `Init()`
  - `Link()`
  - `ExecuteFast()`
  - `ExecuteMain()`
  - `Shutdown()`

### Important Extension
- Define a RACI-style responsibility matrix between managers and modules to avoid overlaps.

---

## 6) Required Folder Structure

The project now ships with this exact top-level structure:

- `0_Management Layer`
- `1_Line Layer`
- `2_Unit Layer`
- `3_EquipmentModule Layer`
- `4_ControlModule Layer`
- `5_FunktionModule Layer`
- `6_HardwareModule Layer`
- `9_Base Layer`

### Mapping Recommendation

- `0_Management Layer`: app bootstrap, orchestration, managers, lifecycle control.
- `1_Line Layer`: line-level coordination, line state and aggregated KPIs.
- `2_Unit Layer`: ISA-88 unit logic and unit-level PackML coordination.
- `3_EquipmentModule Layer`: reusable machine capabilities grouped per equipment module.
- `4_ControlModule Layer`: actuator/sensor-level control abstractions.
- `5_FunktionModule Layer`: shared functional modules (e.g., calculations, sequencing utilities).
- `6_HardwareModule Layer`: hardware adapters and fieldbus/device interfaces.
- `9_Base Layer`: cross-cutting base types, interfaces, common enums, diagnostics primitives.

---

## 7) Non-Functional Requirements (Recommended)

- **Diagnosability**: each component provides health/state information.
- **Testability**: logic can run without hardware using simulation adapters.
- **Versioning**: keep recipe/interface/state-model versions explicitly visible.
- **Extensibility**: add new modules through registration instead of global rewrites.
- **Standardized error codes**: framework-wide error numbers + plain text.

---

## 8) Implementation Roadmap

1. Define base classes and interfaces.
2. Implement the PackML state engine.
3. Introduce the dual-thread communication model (DTO + handshake).
4. Create manager skeletons.
5. Implement one ISA-88 unit with recipe and phase as reference.
6. Build HMI/MES interface around PackML + alarm model.
7. Add testing and diagnostics package.

---

## 9) Included Scaffold (New)

This repository now includes practical starter artifacts:

- `9_Base Layer/Interfaces/I_Lifecycle.TcDUT`
- `9_Base Layer/Interfaces/I_Diagnosable.TcDUT`
- `9_Base Layer/Enums/E_PackMLState.TcDUT`
- `9_Base Layer/DTO/ST_ThreadExchange.TcDUT`
- `0_Management Layer/State/FB_PackMLStateMachine.TcPOU`
- `0_Management Layer/Managers/FB_AppManager.TcPOU`
- `2_Unit Layer/ReferenceUnit/FB_ReferenceUnit.TcPOU`
- `tools/validate_structure.py`
- `docs/quickstart.md`

Run the project consistency check:

```bash
python3 tools/validate_structure.py
```

---

## Result

With this concept, you get a robust **TwinCAT3 base framework** that fully addresses the required topics (**OOP design, ISA-88, PackML, FastCall/MainCall, manager concept**) and adds key practical aspects such as diagnostics, testability, and scalability.
