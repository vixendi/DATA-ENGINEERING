from __future__ import annotations

from typing import Any, Dict

from flask import Flask, request

from avro_writer import write_avro_from_raw

app = Flask(__name__)


@app.post("/")
def handle() -> tuple[Dict[str, Any], int]:
    payload = request.get_json(silent=True) or {}
    raw_dir = payload.get("raw_dir")
    stg_dir = payload.get("stg_dir")

    if not raw_dir:
        return {"message": "raw_dir parameter missed"}, 400
    if not stg_dir:
        return {"message": "stg_dir parameter missed"}, 400

    try:
        out_path = write_avro_from_raw(raw_dir=raw_dir, stg_dir=stg_dir)
    except Exception as exc:  # noqa: BLE001
        return {"message": f"Failed to write Avro: {type(exc).__name__}"}, 500

    return {"message": "Data converted to Avro successfully", "output": out_path}, 201


if __name__ == "__main__":
    app.run(debug=True, host="localhost", port=8082)
