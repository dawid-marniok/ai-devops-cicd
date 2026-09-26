from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_healthz_zwraca_ok():
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"


def test_metrics_wystawia_format_prometheusa():
    r = client.get("/metrics")
    assert r.status_code == 200
    assert "quotes_requests_total" in r.text


def test_quote_domyslnie_stary_format():
    r = client.get("/api/quote")
    assert r.status_code == 200
    # Flaga domyślnie wyłączona — odpowiedź ma tylko tekst.
    assert set(r.json().keys()) == {"quote"}


def test_slow_ma_gorny_limit():
    r = client.get("/api/slow?ms=999999")
    assert r.json()["slept_ms"] == 5000


def test_baner_pokazuje_wersje():
    r = client.get("/")
    assert "quotes-api" in r.text


def test_wersja_broken_zwraca_czesc_bledow(monkeypatch):
    import main

    monkeypatch.setattr(main, "BROKEN_RATE", 1.0)
    r = client.get("/api/quote")
    assert r.status_code == 500
    assert client.get("/healthz").status_code == 200
