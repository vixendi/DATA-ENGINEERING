from __future__ import annotations

import json
import shutil
from pathlib import Path
from typing import Any, Dict, List, Tuple

from fastavro import writer, parse_schema


SCHEMA: Dict[str, Any] = {
    "type": "record",
    "name": "Sale",
    "namespace": "sales.etl",
    "fields": [
        {"name": "client", "type": "string"},
        {"name": "purchase_date", "type": "string"},
        {"name": "product", "type": "string"},
        {"name": "price", "type": "int"},
    ],
}
PARSED_SCHEMA = parse_schema(SCHEMA)


def _clear_dir(target: Path) -> None:
    target.mkdir(parents=True, exist_ok=True)
    for child in target.iterdir():
        if child.is_file() or child.is_symlink():
            child.unlink(missing_ok=True)
        else:
            shutil.rmtree(child, ignore_errors=True)


def _infer_date_from_path(path: Path) -> str:
    return path.name


def _load_json_files(raw_dir: Path) -> Tuple[str, List[Dict[str, Any]]]:
    files = sorted(raw_dir.glob("*.json"))
    records: List[Dict[str, Any]] = []
    if not files:
        date = _infer_date_from_path(raw_dir)
        return date, records

    first = files[0].name
    date = _infer_date_from_path(raw_dir)
    if first.startswith("sales_") and first.endswith(".json"):
        date = first[len("sales_"):-len(".json")]

    for f in files:
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise ValueError(f"Invalid JSON in {f.name}") from exc
        if isinstance(data, list):
            records.extend(data)
        else:
            raise ValueError(f"Expected list payload in {f.name}")
    return date, records


def write_avro_from_raw(raw_dir: str, stg_dir: str) -> str:
    raw_path = Path(raw_dir)
    stg_path = Path(stg_dir)

    date, records = _load_json_files(raw_path)

    bad_dates = {r.get("purchase_date") for r in records if r.get("purchase_date") != date}
    if bad_dates:
        raise ValueError("Records contain mismatched purchase_date values")

    _clear_dir(stg_path)

    out_path = stg_path / f"sales_{date}.avro"
    with out_path.open("wb") as fo:
        writer(fo, PARSED_SCHEMA, records)

    return str(out_path)
