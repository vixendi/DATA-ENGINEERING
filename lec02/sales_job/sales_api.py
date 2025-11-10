from __future__ import annotations

import os
from typing import Any, Dict, List, Optional
import requests

API_URL: str = "https://fake-api-vycpfa6oca-uc.a.run.app"


def _auth_header(token: str) -> Dict[str, str]:
    return {"Authorization": token} if token else {}


def get_sales(date: str, session: Optional[requests.Session] = None) -> List[Dict[str, Any]]:
    """Fetch *all* sales for the given date from the API (handles pagination).

    The API token must be provided via the environment variable ``AUTH_TOKEN``.
    The function will iterate pages starting from 1 until an empty page ([]) is returned
    or a non-200/204 status is encountered.

    Parameters
    ----------
    date : str
        Date in format YYYY-MM-DD to retrieve sales for.
    session : Optional[requests.Session]
        Optional requests session for testability.

    Returns
    -------
    List[Dict[str, Any]]
        A flat list of sales records (dicts).

    Raises
    ------
    RuntimeError
        If AUTH_TOKEN is not set in the environment.
    requests.HTTPError
        On non-200 responses other than 204/404 (treated as no more data).
    """
    token = os.environ.get("AUTH_TOKEN")
    if not token:
        raise RuntimeError("AUTH_TOKEN environment variable must be set")

    sess = session or requests.Session()
    base_url = API_URL.rstrip("/")
    endpoint = f"{base_url}/sales"
    page = 1
    all_records: List[Dict[str, Any]] = []

    while True:
        resp = sess.get(
            endpoint,
            params={"date": date, "page": page},
            headers=_auth_header(token),
            timeout=30,
        )

        if resp.status_code == 200:
            try:
                data = resp.json()
            except ValueError as exc:
                raise requests.HTTPError("Invalid JSON in response") from exc

            if not data:
                break
            if isinstance(data, dict) and "data" in data:
                items = data.get("data") or []
            else:
                items = data
            if not items:
                break
            if not isinstance(items, list):
                raise requests.HTTPError("Unexpected payload format: expected list")
            all_records.extend(items)
            page += 1
            continue

        if resp.status_code in (204, 404):
            break

        # raise for other errors
        resp.raise_for_status()

    return all_records
