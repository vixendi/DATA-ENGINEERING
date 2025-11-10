from __future__ import annotations

import os
from typing import Any, Dict

from flask import Flask, jsonify, request

from sales_api import get_sales
from local_disk import save_to_disk

app = Flask(__name__)


@app.post("/")
def handle() -> tuple[Dict[str, Any], int]:
    payload = request.get_json(silent=True) or {}
    date = payload.get("date")
    raw_dir = payload.get("raw_dir")

    if not date:
        return {"message": "date parameter missed"}, 400
    if not raw_dir:
        return {"message": "raw_dir parameter missed"}, 400

    # Check token (without exposing it)
    if not os.environ.get("AUTH_TOKEN"):
        return {"message": "Server misconfiguration: AUTH_TOKEN is not set"}, 500

    try:
        records = get_sales(date=date)
    except Exception as exc:  
        return {"message": f"Failed to retrieve data: {type(exc).__name__}"}, 502

    # Optional: validate that records align with the requested date (best-effort)
    bad_dates = {r.get("purchase_date") for r in records if r.get("purchase_date") != date}
    if bad_dates:
        return {"message": "Received records with mismatched purchase_date"}, 422

    try:
        save_to_disk(records, raw_dir=raw_dir, date=date)
    except Exception as exc: 
        return {"message": f"Failed to save data: {type(exc).__name__}"}, 500

    return {"message": "Data retrieved successfully from API"}, 201


if __name__ == "__main__":
    app.run(debug=True, host="localhost", port=8081)
