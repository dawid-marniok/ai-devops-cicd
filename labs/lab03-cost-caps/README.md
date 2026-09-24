# Lab 03 — obetnij rachunek

**Blok 2 · 20 minut**

## Sytuacja

`start/kosztowny.yml` to prawdziwy workflow z prawdziwego repozytorium. Działa poprawnie,
przechodzi na zielono i **zużywa około 40 minut runnera na każdy push**.

Przy 30 pushach dziennie to jakieś 190 USD miesięcznie za jedno repozytorium.

## Zadanie

Zejdź **poniżej 8 minut**, nie usuwając żadnego kroku. Lint, testy, build, skan i artefakty
mają dalej się wykonywać.

```bash
cd labs/lab03-cost-caps/start
claude
```

Prompt: `prompts/blok2-pipeline.md`, sekcja „Kontrola kosztów".

Przy każdej zmianie zapisz, ile minut oszczędza — na koniec porównamy szacunki.

## Podpowiedzi

<details>
<summary>Podpowiedź 1 — gdzie szukać</summary>

Zadaj sobie cztery pytania:

1. Czy każdy job musi czekać na poprzedni?
2. Czy każda kombinacja w macierzy sprawdza coś, czego nie sprawdzają pozostałe?
3. Czy coś jest robione dwa razy?
4. Czy cokolwiek się cache'uje?
</details>

<details>
<summary>Podpowiedź 2 — największa pozycja</summary>

Job `lint` ma macierz 3 systemy × 3 wersje Pythona, czyli dziewięć przebiegów.
Sprawdź w cenniku, ile kosztuje minuta na `macos-latest` w porównaniu z `ubuntu-latest`.

Potem zadaj sobie pytanie: aplikacja działa w kontenerze na Linuksie, na Pythonie 3.12.
Co dokładnie sprawdza lint na macOS z Pythonem 3.10?
</details>

<details>
<summary>Podpowiedź 3 — ta sama praca dwa razy</summary>

Porównaj kroki w jobach `build` i `scan`. Obraz Dockera nie przechodzi automatycznie
między jobami — każdy job dostaje czysty runner.
</details>

## Weryfikacja

```bash
actionlint start/kosztowny.yml
```

Potem porównaj wynik z wersją pokazaną przez prowadzącego. Twoje liczby nie muszą się
zgadzać co do minuty;
ważne, czy znalazłeś te same cztery dźwignie.

## Pułapki

**`cache-from` bez `cache-to`.** To najczęstszy błąd w cache'owaniu Dockera i jednocześnie
najbardziej mylący, bo workflow wygląda na poprawnie skonfigurowany. Bez `cache-to`
cache nigdy nie powstaje, więc `cache-from` w każdym przebiegu trafia w pustkę.

**Pomiar po pierwszym przebiegu.** Pierwszy przebieg z cache'em jest wolniejszy —
cache się wtedy zapisuje. Oszczędność mierz od drugiego.

**Agresywne `cancel-in-progress` na `main`.** Na gałęzi roboczej to oszczędność.
Na `main`, gdzie każdy commit ma się wdrożyć, to sposób na pominięcie wdrożenia.

**Zaufanie szacunkom AI.** Agent chętnie napisze „oszczędza 3 minuty". Zapytaj, skąd
to wie. Prawdziwą odpowiedź da dopiero porównanie czasów dwóch przebiegów w `gh run list`.
