"""
Generate Orbita launcher icon assets.

This wrapper keeps the historical Python entry point while delegating the
actual vector drawing to tools/generate_icon.ps1 on Windows.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    script = root / "tools" / "generate_icon.ps1"
    shell = shutil.which("pwsh") or shutil.which("powershell")
    if shell is None:
        print("PowerShell is required to generate the icon assets.", file=sys.stderr)
        return 1
    command = [
        shell,
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        str(script),
    ]
    return subprocess.call(command, cwd=root)


if __name__ == "__main__":
    raise SystemExit(main())
