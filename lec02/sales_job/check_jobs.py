#!/usr/bin/env python3
from __future__ import annotations

import os
from pathlib import Path
from typing import Any, Dict

import requests

FIRST_JOB_URL = "http://localhost:8081/"
SECOND_JOB_URL = "http://localhost:8082/"


def post_json(url: str, payload: Dict[str, Any]) -> requests.Response:
    resp = requests.post(url, json=payload, timeout=60)
    resp.raise_for_status()
    return resp


def main() -> int:
    if "AUTH_TOKEN" not in os.environ:
        print("AUTH_TOKEN must be set in the environment for the first job.")
        return 2

    date = "2022-08-09"
    raw_dir = "/mnt/c/my_homework/lec02/raw/sales/2022-08-09"
    stg_dir = "/mnt/c/my_homework/lec02/stg/sales/2022-08-09"

    print(f"[1/3] Calling first job to fetch JSON into {raw_dir} ...")
    r1 = post_json(FIRST_JOB_URL, {"date": date, "raw_dir": raw_dir})
    print(" ->", r1.status_code, r1.json())

    print(f"[2/3] Calling second job to convert to Avro into {stg_dir} ...")
    r2 = post_json(SECOND_JOB_URL, {"raw_dir": raw_dir, "stg_dir": stg_dir})
    print(" ->", r2.status_code, r2.json())
    out_path = r2.json().get("output")

    print("[3/3] Verifying Avro file exists ...")
    avro_path = Path(out_path or (Path(stg_dir) / f"sales_{date}.avro"))
    if avro_path.exists():
        print("OK:", avro_path)
        return 0

    print("FAIL: Avro file not found:", avro_path)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
