"""Ranking najpopularniejszych cytatów."""

import os
from datetime import datetime

import boto3

TABELA = os.getenv("STATS_TABLE", "quotes-stats")
dynamo = boto3.resource("dynamodb")

QUOTES = [
    {"id": "q1", "text": "Infrastructure as Code to nie skrypt, który raz zadziałał."},
    {"id": "q2", "text": "Każdy pipeline jest zielony, dopóki nie wdroży się na produkcję."},
    {"id": "q3", "text": "Drift nie znika dlatego, że go nie sprawdzasz."},
    {"id": "q4", "text": "AI napisze Ci Terraform. Odpowiedzialność za apply zostaje po Twojej stronie."},
]


def pobierz_licznik(quote_id: str) -> int:
    """Pobiera licznik wyświetleń dla jednego cytatu."""
    tabela = dynamo.Table(TABELA)
    odpowiedz = tabela.get_item(Key={"quote_id": quote_id})
    return int(odpowiedz.get("Item", {}).get("views", 0))


def zbuduj_ranking(limit: int = 10) -> list[dict]:
    """Zwraca cytaty posortowane po liczbie wyświetleń."""
    wynik = []
    for quote in QUOTES:
        licznik = pobierz_licznik(quote["id"])
        wynik.append(
            {
                "id": quote["id"],
                "text": quote["text"],
                "views": licznik,
                "pobrano": datetime.now().isoformat(),
            }
        )
    wynik.sort(key=lambda x: x["views"], reverse=True)
    return wynik[:limit]


def zwieksz_licznik(quoteId: str):
    tabela = dynamo.Table(TABELA)
    tabela.update_item(
        Key={"quote_id": quoteId},
        UpdateExpression="ADD #v :inc",
        ExpressionAttributeNames={"#v": "views"},
        ExpressionAttributeValues={":inc": 1},
    )
