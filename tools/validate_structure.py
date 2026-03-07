#!/usr/bin/env python3
"""Validate tc3-base scaffold structure and key artifacts."""
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_DIRS = [
    "0_Management Layer",
    "1_Line Layer",
    "2_Unit Layer",
    "3_EquipmentModule Layer",
    "4_ControlModule Layer",
    "5_FunktionModule Layer",
    "6_HardwareModule Layer",
    "9_Base Layer",
]

REQUIRED_FILES = [
    "0_Management Layer/State/FB_PackMLStateMachine.TcPOU",
    "0_Management Layer/Managers/FB_AppManager.TcPOU",
    "2_Unit Layer/ReferenceUnit/FB_ReferenceUnit.TcPOU",
    "9_Base Layer/Interfaces/I_Lifecycle.TcDUT",
    "9_Base Layer/Interfaces/I_Diagnosable.TcDUT",
    "9_Base Layer/Enums/E_PackMLState.TcDUT",
    "9_Base Layer/DTO/ST_ThreadExchange.TcDUT",
]


def check_paths(paths: list[str], predicate, kind: str) -> list[str]:
    missing: list[str] = []
    for relative in paths:
        full = ROOT / relative
        if not predicate(full):
            missing.append(f"Missing {kind}: {relative}")
    return missing


def main() -> int:
    errors: list[str] = []
    errors.extend(check_paths(REQUIRED_DIRS, Path.is_dir, "directory"))
    errors.extend(check_paths(REQUIRED_FILES, Path.is_file, "file"))

    if errors:
        for error in errors:
            print(error)
        return 1

    print("Structure validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
