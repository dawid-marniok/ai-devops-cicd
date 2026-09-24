# Blok 6 — Ćwiczenie końcowe

## Etap 1 — one-button deploy

```
Przeprowadź pełne wdrożenie aplikacji quotes-api w moim namespace ($UCZESTNIK):

1. terraform plan w infra/modules/app-storage — pokaż mi plan, poczekaj na moją zgodę
2. po zgodzie: apply
3. zbuduj obraz z app/Dockerfile z APP_VERSION=v2 i wypchnij do ECR
4. wdróż jako canary przez Argo Rollouts
5. po każdym kroku canary pokaż mi podział ruchu i odsetek błędów
6. jeśli błędy przekroczą 5% — wycofaj i powiedz mi dlaczego

Nie promuj canary do 100% bez mojego potwierdzenia.
```

## Etap 2 — diagnostyka incydentu

Po tym, jak prowadzący odpali awarię:

```
Aplikacja w namespace $UCZESTNIK przestała odpowiadać. Zdiagnozuj to.

Zacznij od zebrania faktów — events, describe pod, logi z poprzedniej instancji,
stan rollouta. Dopiero potem formułuj hipotezy.

Dla każdej hipotezy napisz, którym poleceniem ją potwierdzisz lub obalisz,
i wykonaj je. Nie zgaduj przyczyny na podstawie samej nazwy błędu.
```

## Etap 3 — post-mortem

```
/postmortem $UCZESTNIK
```

albo pełną wersją:

```
Napisz post-mortem incydentu na podstawie zebranych logów i metryk.

Struktura: co się stało (2–3 zdania dla menedżera), oś czasu ze znacznikami czasu,
wpływ (ile żądań, przez ile minut), przyczyna źródłowa metodą pięciu „dlaczego",
co zadziałało i co nie, działania naprawcze z właścicielem i terminem.

Każdy fakt w osi czasu musi mieć pokrycie w konkretnej linii logu. Czego nie ma
w danych, oznacz jako „brak danych" — nie uzupełniaj tego domysłami.
```

Po wygenerowaniu raportu **przeczytaj go i znajdź co najmniej jedno zdanie, którego
agent nie mógł wiedzieć z zebranych danych.** Jeśli nie znajdziesz — tym lepiej,
ale sprawdź świadomie, a nie na wiarę.

## Etap 4 — TCO

```
/tco
```

albo:

```
Policz koszt tego, co dziś zbudowaliśmy, w dwóch częściach:

1. Infrastruktura — wypisz z infra/ zasoby, które naliczają opłaty, podaj cenę
   jednostkową w eu-central-1 i koszt za 8 godzin. Ceny, których nie jesteś pewien,
   oznacz jako [do sprawdzenia].

2. Tokeny AI — przy założeniu 20 pull requestów dziennie, średnio 400 linii diffa,
   dwie recenzje AI na PR, policz koszt miesięczny.

Na koniec jedno zdanie: przy jakiej liczbie PR dziennie koszt recenzji AI przekracza
koszt klastra.
```
