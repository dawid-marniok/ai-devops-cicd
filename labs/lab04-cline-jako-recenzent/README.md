# Lab 04 — Cline jako recenzent

**Blok 3 · 25 minut**

## Zadanie

Skonfiguruj Cline jako recenzenta PR w tym repo i przepuść przez niego prawdziwy zestaw zmian.

### Krok 1 — kontekst dla recenzenta (5 min)

Otwórz `.clinerules/10-recenzja-pr.md` i przeczytaj. To jest instrukcja, którą Cline dostaje
za każdym razem, gdy prosisz o recenzję w tym repo.

Dopisz do niej **jedną własną regułę** — coś, co w Twoim zespole regularnie przechodzi
przez review i nie powinno. Przykłady: brak obsługi timeoutu przy wywołaniach HTTP,
logowanie całego obiektu żądania, migracje bazy niekompatybilne wstecz.

### Krok 2 — recenzja (15 min)

```bash
cd labs/lab04-cline-jako-recenzent/start
```

Katalog zawiera PR #52 — nowy workflow pozwalający wdrażać komentarzem w issue
oraz „optymalizację" Dockerfile. W VS Code otwórz Cline i poproś o recenzję
zgodnie z formatem z `.clinerules`.

Zrób to **dwa razy**: raz z `.clinerules` w kontekście, raz bez (tymczasowo zmień nazwę
katalogu). Porównaj wyniki — to jest właściwy przedmiot tego labu.

Prompt startowy: `prompts/blok3-review.md`, sekcja „Cline jako recenzent".

### Krok 3 — checklista jako artefakt (5 min)

Poproś Cline o wygenerowanie checklisty recenzenta dla tego repo — takiej, którą da się
zapisać jako `CHECKLIST.md` i której zespół używa bez AI.

Zapisz wynik. To jest produkt uboczny, który zostaje z Wami po szkoleniu.

## Podpowiedzi

<details>
<summary>Podpowiedź 1 — Cline recenzuje zbyt ogólnikowo</summary>

Najczęstsza przyczyna: nie wie, czego szukać. Format z `.clinerules` wymaga podania
**scenariusza** dla każdego znaleziska — jeśli Cline go pomija, przypomnij mu wprost:
„dla każdego znaleziska podaj scenariusz, w którym to wybucha. Bez scenariusza pomiń".
</details>

<details>
<summary>Podpowiedź 2 — Cline zgłasza dwadzieścia drobiazgów</summary>

Poproś o uszeregowanie i ograniczenie: „pokaż tylko BLOKUJĄCE i WAŻNE, maksymalnie pięć".
Recenzja, której nikt nie przeczyta do końca, jest warta tyle co jej brak.
</details>

<details>
<summary>Podpowiedź 3 — porównanie z Claude Code</summary>

Ten sam zestaw zmian przepuść przez `/pr-review` w Claude Code i zestaw wyniki.
Różnice zwykle biorą się z kontekstu (`.clinerules` vs `.claude/commands/pr-review.md`),
a nie z modelu — oba mogą działać na tym samym.
</details>

## Weryfikacja

Masz dwie rzeczy: recenzję w formacie z `.clinerules` i `CHECKLIST.md`, którego da się użyć
bez AI. Porównaj checklistę z tym, co faktycznie sprawdzacie dziś w zespole.

## Pułapki

**Recenzent bez kontekstu.** Bez `.clinerules` dostaniesz uwagi o formatowaniu.
Z regułami — uwagi o tym, co w tym konkretnym repo faktycznie boli.

**Auto-approve przy recenzji.** Cline domyślnie czeka na akceptację każdego kroku i na czas
recenzji tak ma zostać. Recenzent, który sam sobie zatwierdza zmiany, nie jest recenzentem.

**Checklista wygenerowana i nieprzeczytana.** Wygenerowanie checklisty zajmuje 30 sekund.
Wartość powstaje dopiero wtedy, gdy przejdziesz ją punkt po punkcie i wykreślisz to,
co u Was nie ma sensu.
