from main_avro import app
from pathlib import Path
import json

def test_main_avro_success(tmp_path):
    raw_dir = tmp_path / "raw" / "sales" / "2022-08-09"
    stg_dir = tmp_path / "stg" / "sales" / "2022-08-09"
    raw_dir.mkdir(parents=True, exist_ok=True)
    stg_dir.mkdir(parents=True, exist_ok=True)

    (raw_dir / "sales_2022-08-09.json").write_text(
        json.dumps([
            {"client": "A", "purchase_date": "2022-08-09", "product": "P", "price": 1},
            {"client": "B", "purchase_date": "2022-08-09", "product": "Q", "price": 2},
        ]),
        encoding="utf-8"
    )

    client = app.test_client()
    resp = client.post("/", json={"raw_dir": str(raw_dir), "stg_dir": str(stg_dir)})
    assert resp.status_code == 201
    js = resp.get_json()
    assert js["message"] == "Data converted to Avro successfully"
