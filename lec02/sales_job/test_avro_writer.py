from pathlib import Path
import json

from fastavro import reader

from avro_writer import write_avro_from_raw


def test_write_avro_from_raw(tmp_path: Path):
    raw_dir = tmp_path / "raw" / "sales" / "2022-08-09"
    stg_dir = tmp_path / "stg" / "sales" / "2022-08-09"
    raw_dir.mkdir(parents=True, exist_ok=True)
    stg_dir.mkdir(parents=True, exist_ok=True)

    (raw_dir / "sales_2022-08-09.json").write_text(
        json.dumps([
            {"client": "A", "purchase_date": "2022-08-09", "product": "P", "price": 1},
            {"client": "B", "purchase_date": "2022-08-09", "product": "Q", "price": 2},
        ], ensure_ascii=False),
        encoding="utf-8"
    )

    out = write_avro_from_raw(str(raw_dir), str(stg_dir))
    assert out.endswith("sales_2022-08-09.avro")
    avro_path = Path(out)
    assert avro_path.exists()

    with avro_path.open("rb") as fo:
        recs = list(reader(fo))
    assert len(recs) == 2
    assert recs[0]["client"] == "A"
    assert recs[1]["price"] == 2
