# PR #47 — ranking najpopularniejszych cytatów

**Autor:** wygenerowane przez asystenta AI, zaakceptowane przez autora PR
**Recenzenci:** Ty

## Co robi

Dodaje endpoint `GET /api/quotes/top`, który zwraca listę najczęściej wyświetlanych cytatów
wraz z licznikami. Liczniki trzymamy w DynamoDB — tabela `quotes-stats`, klucz `quote_id`.

Do tego polityka IAM pozwalająca aplikacji czytać i zapisywać liczniki.

## Jak testowałem

```
curl localhost:8000/api/quotes/top
```

Zwraca poprawną listę. Testy przechodzą.

## Pliki

- `app/ranking.py` — logika rankingu
- `app/main.py` — rejestracja endpointu (jedna linijka, pominięta w tym ćwiczeniu)
- `infra/iam-ranking.tf` — polityka IAM dla aplikacji
