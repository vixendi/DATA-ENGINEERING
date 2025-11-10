import os
from typing import Any, Dict, List
from unittest import mock

import requests

import sales_api


class DummyResponse:
    def __init__(self, status_code: int, json_data: Any = None):
        self.status_code = status_code
        self._json = json_data

    def json(self):
        if self._json is None:
            raise ValueError("No JSON")
        return self._json

    def raise_for_status(self):
        raise requests.HTTPError(f"HTTP {self.status_code}")


def test_get_sales_pagination(monkeypatch):
    os.environ["AUTH_TOKEN"] = "testtoken"

    pages = [
        DummyResponse(200, [{"client": "A", "purchase_date": "2022-08-09"}]),
        DummyResponse(200, [{"client": "B", "purchase_date": "2022-08-09"}]),
        DummyResponse(200, []),  # stop
    ]
    calls = {"i": 0}

    class FakeSession:
        def get(self, url, params=None, headers=None, timeout=None):
            i = calls["i"]
            calls["i"] = i + 1
            return pages[i]

    session = FakeSession()
    result = sales_api.get_sales("2022-08-09", session=session)  # type: ignore[arg-type]
    assert [r["client"] for r in result] == ["A", "B"]


def test_get_sales_requires_token(monkeypatch):
    os.environ.pop("AUTH_TOKEN", None)

    class FakeSession:
        def get(self, *a, **k):
            raise AssertionError("Should not be called when token missing")

    try:
        sales_api.get_sales("2022-08-09", session=FakeSession())  # type: ignore[arg-type]
        assert False, "Expected RuntimeError"
    except RuntimeError:
        pass
