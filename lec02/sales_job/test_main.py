import os
from main import app

def setup_module(module):
    os.environ["AUTH_TOKEN"] = "dummy"


def test_post_missing_date():
    client = app.test_client()
    resp = client.post("/", json={"raw_dir": "/tmp/x"})
    assert resp.status_code == 400
    assert resp.get_json()["message"] == "date parameter missed"


def test_post_missing_raw_dir():
    client = app.test_client()
    resp = client.post("/", json={"date": "2022-08-09"})
    assert resp.status_code == 400
    assert resp.get_json()["message"] == "raw_dir parameter missed"


def test_success(monkeypatch, tmp_path):
    from main import save_to_disk as real_save

    # mock get_sales to return consistent data
    def fake_get_sales(date: str):
        return [{"client": "A", "purchase_date": date, "product": "P", "price": 1}]

    monkeypatch.setenv("AUTH_TOKEN", "ok")
    monkeypatch.setattr("main.get_sales", fake_get_sales)

    raw_dir = str(tmp_path)
    client = app.test_client()
    resp = client.post("/", json={"date": "2022-08-09", "raw_dir": raw_dir})
    assert resp.status_code == 201
    assert resp.get_json()["message"] == "Data retrieved successfully from API"

    # verify file was created
    files = list(tmp_path.iterdir())
    assert any(f.name == "sales_2022-08-09.json" for f in files)
