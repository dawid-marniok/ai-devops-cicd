# TCO — ile to naprawdę kosztuje

Szablon do Bloku 6. Uzupełnij własnymi liczbami; te poniżej są punktem wyjścia,
nie wynikiem.

## Część 1 — infrastruktura szkoleniowa

Region `eu-central-1`, 8 godzin działania.

| Zasób | Cena jednostkowa | 8 godzin | Uwaga |
|---|---|---|---|
| EKS control plane | 0,10 USD/h | 0,80 USD | naliczane od utworzenia, także gdy nic nie działa |
| 2 × `t3.large` (on-demand) | 0,0928 USD/h | 1,48 USD | przy skalowaniu do 6 węzłów rośnie proporcjonalnie |
| NAT Gateway | 0,052 USD/h + 0,052 USD/GB | 0,42 USD + transfer | **jeden z najczęściej zapominanych kosztów** |
| ALB | 0,027 USD/h + LCU | 0,22 USD + LCU | jeden na uczestnika, jeśli każdy ma własny Ingress |
| S3, ECR | groszowe przy tej skali | <0,10 USD | liczy się dopiero przy setkach obrazów |

**Razem: rząd 3–5 USD za dzień szkolenia** przy dwóch węzłach.

> Ceny sprawdź przed szkoleniem — zmieniają się. Wartości powyżej są z 2026-09
> i mają status `[do weryfikacji]`.

### Co kosztuje, mimo że nic nie robi

- **EKS control plane** — 0,10 USD/h, czyli 72 USD miesięcznie za sam fakt istnienia klastra
- **NAT Gateway** — 0,052 USD/h plus opłata za każdy przetworzony gigabajt.
  Klaster zostawiony na weekend to około 2,5 USD za sam NAT
- **ALB bez ruchu** — nadal naliczany godzinowo

Dlatego sprzątanie środowiska przez prowadzącego jest częścią szkolenia, a nie dodatkiem.

## Część 2 — tokeny AI w pipeline

### Założenia do policzenia

| Parametr | Wartość wyjściowa | Twoja wartość |
|---|---|---|
| Pull requesty dziennie | 20 | |
| Średni rozmiar diffu | 400 linii ≈ 6 tys. tokenów | |
| Recenzje AI na jeden PR | 2 (otwarcie + poprawki) | |
| Tokeny wyjściowe na recenzję | ~1,5 tys. | |
| Dni robocze w miesiącu | 21 | |

### Wzór

```
tokeny wejściowe  = PR/dzień × recenzje/PR × tokeny diffu × dni
tokeny wyjściowe  = PR/dzień × recenzje/PR × tokeny odpowiedzi × dni

koszt = (tokeny wejściowe × cena wejścia + tokeny wyjściowe × cena wyjścia) / 1 000 000
```

Aktualne ceny za milion tokenów sprawdź w cenniku Anthropic — różnią się między modelami
i zmieniają w czasie. **Nie przepisuj tu liczby z pamięci.**

### Trzy rzeczy, które ludzie pomijają w tej kalkulacji

**Recenzja odpala się przy każdym pushu, nie przy każdym PR.** Jeśli workflow ma
`types: [opened, synchronize]`, a autor pushuje pięć razy, płacisz pięć razy.
Stąd bramka na rozmiar diffu i `concurrency` w workflow recenzującym PR.

**Duże diffy to duże rachunki.** Jedna zmiana formatująca całe repozytorium potrafi
kosztować tyle, co miesiąc normalnych recenzji. Dlatego filtrujemy pliki wygenerowane
i pomijamy diffy powyżej 200 kB.

**Prompt caching zmienia rachunek.** Jeśli recenzje dzielą ten sam kontekst
(instrukcja, konwencje repo), koszt wejścia potrafi spaść wielokrotnie.
Sprawdź, czy Twoja integracja z niego korzysta.

## Część 3 — pytanie zamykające

> **Przy jakiej liczbie PR dziennie koszt recenzji AI przekracza koszt klastra?**

Policz to dla swojego zespołu. Dla wielu zespołów odpowiedź okazuje się niższa,
niż się spodziewali — i to jest właściwy powód, żeby tę kalkulację zrobić **przed**
wdrożeniem automatycznej recenzji, a nie po pierwszej fakturze.

## Czego ta kalkulacja nie obejmuje

Czasu ludzi. Jeśli recenzja AI oszczędza recenzentowi 10 minut na PR, przy 20 PR dziennie
to ponad 3 godziny dziennie — i ta pozycja zwykle przeważa nad wszystkim powyżej.

Ale działa też w drugą stronę: recenzja, która generuje dwadzieścia uwag stylistycznych,
kosztuje czas zamiast go oszczędzać. To jest argument za wąskim, dobrze skonfigurowanym
recenzentem, a nie za rezygnacją z niego.
