# Lab 02 — pipeline promptem

**Blok 2 · 25 minut**

## Zadanie

Napisz promptem workflow, który dla aplikacji z `app/` wykona: lint, testy, build obrazu
i push do ECR. Ma przejść na zielono.

Pracuj w `start/` — jest tam pusty katalog `.github/workflows/` i plik `README-zadanie.md`
z danymi Twojego środowiska.

```bash
cd labs/lab02-workflow-z-ai/start
claude       # albo Cline w VS Code — wybierz, czym chcesz dziś pracować
```

Prompt startowy jest w `prompts/blok2-pipeline.md`, sekcja „Workflow od zera".
Możesz go użyć wprost albo napisać własny.

## Wymagania, które musi spełnić wynik

- [ ] `permissions` ustawione na poziomie joba, minimalny zakres
- [ ] `timeout-minutes` na każdym jobie
- [ ] uwierzytelnianie do AWS przez OIDC, **zero kluczy w sekretach**
- [ ] akcje przypięte do wersji (`@v4`), nie do `@main`
- [ ] build i push tylko z gałęzi `main`
- [ ] workflow przechodzi na zielono

## Podpowiedzi

<details>
<summary>Podpowiedź 1 — agent pominął uprawnienia</summary>

Dopisz do promptu: „wyjaśnij przy każdym jobie, dlaczego nadałeś mu takie uprawnienia".
Konieczność uzasadnienia sama z siebie zawęża zakres — trudniej napisać uzasadnienie
dla `write-all` niż dla `contents: read`.
</details>

<details>
<summary>Podpowiedź 2 — agent prosi o AWS_SECRET_ACCESS_KEY</summary>

To znaczy, że nie wie o OIDC w tym repo. Powiedz wprost: „użyj
`aws-actions/configure-aws-credentials` z `role-to-assume`, rola jest w zmiennej
repozytorium `AWS_DEPLOY_ROLE_ARN`. Job potrzebuje `id-token: write`."

Zauważ, że `id-token: write` jest potrzebne **tylko** w jobie, który gada z AWS.
</details>

<details>
<summary>Podpowiedź 3 — pipeline pada, nie wiadomo na czym</summary>

```
Pobierz logi ostatniego nieudanego przebiegu (gh run view --log-failed), znajdź PIERWSZY
prawdziwy błąd — nie ostatnią linię — i wyjaśnij, co go wywołało.
```

Koniec logu to prawie zawsze `Process completed with exit code 1`, czyli informacja,
że coś padło, a nie co. Przyczyna jest wyżej.
</details>

## Weryfikacja

```bash
actionlint .github/workflows/*.yml
gh run watch
```

Po zakończeniu prowadzący pokaże wzorcowy workflow i porówna go z Waszymi wersjami.

## Pułapki

**`permissions: write-all`.** Wygodne i przechodzi. Oznacza, że każdy krok w workflow
— łącznie z akcją z marketplace'u, której nie czytałeś — może pisać do repozytorium,
tworzyć release'y i publikować pakiety.

**Akcja przypięta do `@master` albo `@main`.** To cudzy kod, wykonywany na Twoim runnerze,
w wersji, której nikt nie zatwierdził. Autor może zmienić zawartość taga w każdej chwili.

**Deploy odpalający się z pull requesta.** Bez warunku na gałąź każdy PR — także z forka —
próbuje wdrożyć. Agent często o tym zapomina, bo w promptcie mówimy „zbuduj i wdróż",
a nie „wdróż tylko z main".
