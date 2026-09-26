# Lab 03 — obetnij rachunek

**Blok 2 · 20 minut**

## Sytuacja

`start/kosztowny.yml` to prawdziwy workflow z prawdziwego repozytorium. Działa poprawnie,
przechodzi na zielono i na zegarku trwa około 2,5 minuty. W repo prywatnym jeden przebieg
kosztuje jednak **około 43 minut w przeliczeniu na Linuksa** (0,26 USD).

Skąd różnica:

- GitHub zaokrągla czas **każdego joba** w górę do pełnej minuty. Workflow ma 13 jobów,
  więc nawet 10-sekundowy lint liczy się jako minuta.
- Minuta kosztuje różnie zależnie od systemu: Linux 0,006 USD, Windows 0,010 USD,
  macOS 0,062 USD, czyli ponad 10 razy drożej niż Linux
  ([cennik GitHub](https://docs.github.com/en/billing/reference/actions-runner-pricing), sprawdzony 2026-09-26).

Pomiar z 2026-09-26: 7 jobów na Linuksie (7 min), 3 na Windows (3 min), 3 na macOS (3 min).
Same trzy joby lintu na macOS kosztują więcej niż cała reszta pipeline'u.

W repo publicznym, takim jak Twój fork, GitHub nie pobiera opłat za standardowe runnery.
Zaokrąglanie i proporcje działają jednak tak samo jak w firmowym repo prywatnym, więc liczymy
koszt, jaki byłby tam.

## Zadanie

Zejdź **poniżej 8 minut w przeliczeniu na Linuksa** (ok. 0,05 USD), nie usuwając żadnego kroku. Lint, testy, build,
skan i artefakty mają dalej się wykonywać.

```bash
cd "$(git rev-parse --show-toplevel)"
claude    # poproś o zmiany w labs/lab03-cost-caps/start/kosztowny.yml
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

Z głównego katalogu repozytorium:

```bash
actionlint labs/lab03-cost-caps/start/kosztowny.yml; echo "kod wyjścia: $?"
```

Brak komunikatów i `kod wyjścia: 0` oznaczają, że workflow jest poprawny. actionlint wypisuje
tylko błędy, np. literówkę w `needs:` albo odwołanie do nieistniejącego joba:

```text
labs/lab03-cost-caps/start/kosztowny.yml:48:3: job "scan" needs job "biuld" which does not exist in this workflow [job-needs]
   |
48 |   scan:
   |   ^~~~~
```

actionlint nie mierzy kosztów. Sprawdza tylko, czy po Twoich zmianach workflow nadal
się uruchomi — przy przestawianiu `needs:` i łączeniu jobów łatwo o taki błąd.

Pomiar na GitHubie (opcjonalnie, w swoim forku). Workflow uruchamia się tylko ręcznie.
Uruchom go dwa razy: wersję startową i wersję po zmianach. W publicznym forku przebiegi
są darmowe, ale w repo prywatnym każdy przebieg wersji startowej zużyłby ok. 43 minuty limitu.

```bash
cp labs/lab03-cost-caps/start/kosztowny.yml .github/workflows/kosztowny.yml
git add .github/workflows/kosztowny.yml && git commit -m "lab03: pomiar" && git push
gh workflow run kosztowny.yml
gh run list --workflow kosztowny.yml --limit 2
./labs/lab03-cost-caps/koszt-przebiegu.sh <id>          # koszt przebiegu jak w repo prywatnym
```

Przykładowy wynik dla wersji startowej:

```text
linux: 7 jobów, 7 min × 0.006 USD = 0.042 USD
macos: 3 jobów, 3 min × 0.062 USD = 0.186 USD
windows: 3 jobów, 3 min × 0.01 USD = 0.03 USD
RAZEM: 0.258 USD, czyli 43 min w przeliczeniu na Linuksa
```

Skrypt liczy z czasów jobów, bo w repo publicznym `gh api …/runs/<id>/timing` zwraca
`total_ms: 0` dla każdego systemu. `{owner}/{repo}` to domyślne repo `gh`, dlatego
fork musi być ustawiony przez `gh repo set-default` (setup, punkt 1).

Porównaj wynik z wersją pokazaną przez prowadzącego. Twoje liczby nie muszą się
zgadzać co do minuty; ważne, czy znalazłeś te same cztery dźwignie.

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
