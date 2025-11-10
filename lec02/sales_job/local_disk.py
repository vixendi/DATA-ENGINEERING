from __future__ import annotations

import json
import shutil
from pathlib import Path
from typing import Any, Dict, List


def _clear_dir(target: Path) -> None:
    target.mkdir(parents=True, exist_ok=True)
    for child in target.iterdir():
        if child.is_file() or child.is_symlink():
            child.unlink(missing_ok=True)
        else:
            shutil.rmtree(child, ignore_errors=True)


def save_to_disk(records: List[Dict[str, Any]], raw_dir: str, date: str) -> None:
    """Idempotently save the provided sales records as a single JSON file.

    The function clears *all* contents inside ``raw_dir`` and then writes one file
    named ``sales_<date>.json`` containing all records (pretty-printed UTF-8).

    Parameters
    ----------
    records : List[Dict[str, Any]]
        Sales records to persist.
    raw_dir : str
        Directory path where file must be stored. Works on Windows and POSIX.
    date : str
        Date string in YYYY-MM-DD used for validation and filename.
    """
    target = Path(raw_dir)

    # ensure idempotency by clearing dir first
    _clear_dir(target)

    filename = f"sales_{date}.json"
    out_path = target / filename

    # write JSON once
    out_path.write_text(json.dumps(records, ensure_ascii=False, indent=2), encoding="utf-8")
