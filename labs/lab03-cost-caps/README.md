# Lab 03 — obetnij rachunek

**Blok 2 · 20 minut**

## Sytuacja

`start/kosztowny.yml` to prawdziwy workflow z prawdziwego repozytorium. Działa poprawnie,
przechodzi na zielono i **zużywa około 40 minut rozliczeniowych runnera na każdy push**,
choć na zegarku trwa kilka minut.

Skąd różnica: GitHub zaokrągla czas **każdego joba** w górę do pełnej minuty i mnoży minuty
zależnie od systemu (w repo prywatnym Linux ×1, Windows ×2, macOS ×10). Dziewięć krótkich jobów
lintu na trzech systemach kosztuje więcej niż cała reszta pipeline'u.

## Zadanie

Zejdź **poniżej 8 minut rozliczeniowych**, nie usuwając żadnego kroku. Lint, testy, build,
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
actionlint labs/lab03-cost-caps/start/kosztowny.yml
```

Pomiar na GitHubie (opcjonalnie, we własnym repo). Workflow uruchamia się tylko ręcznie,
żeby nie palił minut przy każdym pushu. **Uruchom go najwyżej dwa razy** — przed zmianą
i po zmianie; w repo prywatnym jeden przebieg wersji startowej zużywa ok. 40 minut z limitu.

```bash
cp labs/lab03-cost-caps/start/kosztowny.yml .github/workflows/kosztowny.yml
git add .github/workflows/kosztowny.yml && git commit -m "lab03: pomiar" && git push
gh workflow run kosztowny.yml
gh run list --workflow kosztowny.yml --limit 2
gh api repos/{owner}/{repo}/actions/runs/<id>/timing   # czas każdego joba
```

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
