"""quotes-api — aplikacja demo do warsztatów AI DevOps.

Celowo mała. Każdy endpoint ma konkretne zadanie w konkretnym bloku szkolenia,
patrz tabela w README repozytorium.
"""

import os
import random
import time

from fastapi import FastAPI, Header, HTTPException, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

from flags import flag_enabled

VERSION = os.getenv("APP_VERSION", "v1")
# Kolor banera zmienia się razem z wersją — dzięki temu canary widać w przeglądarce,
# bez wchodzenia w kubectl.
COLOR = {"v1": "#1f6feb", "v2": "#2da44e"}.get(VERSION, "#6e7781")
# Wersja z sufiksem `-broken` (np. obraz `v2-broken` do lab07) zwraca 5xx na części żądań
# API. /healthz zostaje zdrowe — pod jest Ready i dostaje ruch, więc błąd widać w metrykach,
# a nie w restartach. Odsetek można nadpisać zmienną BROKEN_RATE (0.0–1.0).
BROKEN_RATE = float(os.getenv("BROKEN_RATE", "0.3" if VERSION.endswith("-broken") else "0"))

app = FastAPI(title="quotes-api", version=VERSION)

REQUESTS = Counter("quotes_requests_total", "Liczba żądań", ["endpoint", "version", "status"])
LATENCY = Histogram("quotes_request_seconds", "Czas odpowiedzi", ["endpoint", "version"])

QUOTES = [
    "Infrastructure as Code to nie skrypt, który raz zadziałał.",
    "Każdy pipeline jest zielony, dopóki nie wdroży się na produkcję.",
    "Drift nie znika dlatego, że go nie sprawdzasz.",
    "AI napisze Ci Terraform. Odpowiedzialność za apply zostaje po Twojej stronie.",
]


@app.get("/")
def index():
    """Baner z wersją — to na nim widać podział ruchu podczas canary (Blok 4)."""
    REQUESTS.labels("/", VERSION, "200").inc()
    return Response(
        content=(
            f'<html><body style="background:{COLOR};color:#fff;font-family:sans-serif;'
            f'display:flex;align-items:center;justify-content:center;height:100vh">'
            f"<h1>quotes-api {VERSION}</h1></body></html>"
        ),
        media_type="text/html",
    )


@app.get("/healthz")
def healthz():
    """Probe dla Kubernetes. W Bloku 6 to ten endpoint zaczyna zwracać 503."""
    if os.getenv("BREAK_HEALTH") == "1":
        REQUESTS.labels("/healthz", VERSION, "503").inc()
        return Response(content='{"status":"unhealthy"}', status_code=503, media_type="application/json")
    REQUESTS.labels("/healthz", VERSION, "200").inc()
    return {"status": "ok", "version": VERSION}


@app.get("/metrics")
def metrics():
    """Scrape'owane przez OTel Collector, dalej do Prometheusa i Grafany (Blok 5)."""
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)


def _moze_zepsuj(endpoint: str) -> None:
    """Symulowany błąd wersji `-broken` — liczony w metrykach jak prawdziwy 500."""
    if BROKEN_RATE and random.random() < BROKEN_RATE:
        REQUESTS.labels(endpoint, VERSION, "500").inc()
        raise HTTPException(status_code=500, detail="symulowany błąd wersji " + VERSION)


@app.get("/api/quote")
def quote(x_beta: str | None = Header(default=None), x_user_id: str | None = Header(default=None)):
    """Za feature-flagą `nowy-format-cytatu` (Blok 4, lab08).

    Flaga steruje formatem odpowiedzi — stary zwraca sam tekst, nowy dokłada metadane.
    Nagłówek `X-User-Id` jest kluczem podziału ruchu (targetingKey w flagd).
    """
    _moze_zepsuj("/api/quote")
    with LATENCY.labels("/api/quote", VERSION).time():
        text = random.choice(QUOTES)
        nowy_format = flag_enabled(
            "nowy-format-cytatu", context={"beta": x_beta}, targeting_key=x_user_id or "anonim"
        )
        REQUESTS.labels("/api/quote", VERSION, "200").inc()
        if nowy_format:
            return {"quote": text, "version": VERSION, "format": "v2", "length": len(text)}
        return {"quote": text}


@app.get("/api/slow")
def slow(ms: int = 250):
    """Kontrolowane obciążenie — do HPA (Blok 5) i do symulacji incydentu (Blok 6).

    Limit 5 s jest po to, żeby przypadkowe `?ms=100000` nie zablokowało workera.
    """
    _moze_zepsuj("/api/slow")
    delay = min(max(ms, 0), 5000) / 1000
    with LATENCY.labels("/api/slow", VERSION).time():
        # Zajęcie CPU, nie sleep — HPA reaguje na CPU, nie na czekanie.
        end = time.time() + delay
        while time.time() < end:
            _ = sum(i * i for i in range(1000))
    REQUESTS.labels("/api/slow", VERSION, "200").inc()
    return {"slept_ms": int(delay * 1000), "version": VERSION}
