from pathlib import Path
import json
import tempfile

from local_disk import save_to_disk


def test_save_to_disk_idempotent(tmp_path: Path):
    # create junk files to ensure clearing works
    (tmp_path / "old.txt").write_text("old", encoding="utf-8")
    (tmp_path / "sub").mkdir(parents=True, exist_ok=True)
    (tmp_path / "sub" / "file.txt").write_text("x", encoding="utf-8")

    records = [
        {"client": "A", "purchase_date": "2022-08-09", "product": "X", "price": 1},
        {"client": "B", "purchase_date": "2022-08-09", "product": "Y", "price": 2},
    ]

    save_to_disk(records, raw_dir=str(tmp_path), date="2022-08-09")

    # directory should contain exactly one file
    files = list(tmp_path.iterdir())
    assert len(files) == 1
    out = files[0]
    assert out.name == "sales_2022-08-09.json"
    data = json.loads(out.read_text(encoding="utf-8"))
    assert len(data) == 2
