---
description: Post-mortem incydentu na podstawie logów i metryk
---

Namespace: $ARGUMENTS

Zbierz materiał — nie zgaduj, czytaj:

```
kubectl get events -n $ARGUMENTS --sort-by=.lastTimestamp
kubectl describe pod -n $ARGUMENTS -l app=quotes-api
kubectl logs -n $ARGUMENTS -l app=quotes-api --previous --tail=200
kubectl argo rollouts get rollout quotes-api -n $ARGUMENTS
```

Napisz post-mortem w tej strukturze:

1. **Co się stało** — 2–3 zdania, bez żargonu, tak żeby zrozumiał to menedżer
2. **Oś czasu** — konkretne znaczniki czasu z eventów i logów, od pierwszego sygnału do przywrócenia
3. **Wpływ** — ile żądań, przez ile minut, które endpointy
4. **Przyczyna źródłowa** — pięć razy „dlaczego", każdy krok oparty na konkretnej linii logu
5. **Co zadziałało / co nie zadziałało** — czy alert przyszedł na czas, czy rollback pomógł
6. **Działania naprawcze** — konkretne, z właścicielem i terminem, nie „poprawić monitoring"

**Zasada twarda:** każdy fakt w osi czasu musi mieć pokrycie w zebranym wyjściu.
Jeśli czegoś nie ma w logach, napisz „brak danych", nie domyślaj się.
