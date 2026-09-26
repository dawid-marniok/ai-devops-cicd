# Blok 4 — Deploy i rollback

## Rollout zamiast Deployment

```
Przerób manifest Deployment aplikacji quotes-api na Rollout z Argo Rollouts,
ze strategią canary:

- kroki: 10% ruchu, pauza, 50%, pauza, 100%
- podział ruchu przez AWS Load Balancer Controller (trafficRouting alb)
- automatyczne wycofanie, gdy odsetek odpowiedzi 5xx przekroczy 5% w oknie 2 minut

Wyjaśnij, co się stanie z pod-ami starej wersji na każdym kroku i w którym momencie
zostaną usunięte.
```

## Feature-flaga z opisu w naturalnym języku

```
Wygeneruj konfigurację flagd (format JSON, schema flagd.dev/schema/v0/flags.json)
dla takiej reguły:

"Nowy format odpowiedzi endpointu /api/quote ma być widoczny dla 20% ruchu,
a dodatkowo zawsze dla żądań z nagłówkiem X-Beta ustawionym na true."

Kontekst ewaluacji z aplikacji (app/main.py, app/flags.py): atrybut `beta` = wartość
nagłówka X-Beta (tekst), `targetingKey` = nagłówek X-User-Id. Podział 20% ma być
deterministyczny — ten sam użytkownik zawsze w tej samej grupie.

Zapisz do labs/lab08-feature-flag-z-promptu/start/flags.json. Pokaż, jak sprawdzić działanie flagi bez wdrażania nowej
wersji aplikacji.
```

## Rollback

```
Wdrożenie v2 poszło źle. Wykonaj rollback i wyjaśnij, co dokładnie się dzieje:

1. kubectl argo rollouts undo quotes-api -n $UCZESTNIK
2. sprawdź, do której rewizji wróciliśmy i czy ruch faktycznie na nią wrócił
3. sprawdź, czy ConfigMapy i sekrety też się cofnęły — a jeśli nie, wyjaśnij dlaczego

Potem odpowiedz osobno: czym różni się `helm rollback` od `argocd app rollback`
przy włączonym auto-sync, i którego z nich użyć w tej sytuacji.
```

Odpowiedź agenta skonfrontuj z tym, co faktycznie stanie się na klastrze.

## Post-wdrożeniowa weryfikacja

```
Napisz skrypt, który po wdrożeniu sprawdza przez 60 sekund, czy aplikacja jest zdrowa:
odsetek odpowiedzi 5xx, p95 czasu odpowiedzi, liczba restartów pod-ów.
Ma zwrócić kod wyjścia 1, jeśli którakolwiek z tych rzeczy wygląda źle,
żeby dało się go wpiąć jako bramkę w pipeline.
```
