# Uprawnienia w Claude Code — reguły, tryby pracy i `settings.json`

Claude Code przed każdym wywołaniem narzędzia (`Bash`, `Edit`, `Read`, ...)
decyduje: wykonać, zapytać czy zablokować. Na tę decyzję wpływają dwie rzeczy:

- **reguły** zapisane w plikach `settings.json` — statyczne, zwykle w repo,
- **tryb pracy** wybrany w sesji (Shift+Tab) — dynamiczny, per sesja.

Najkrócej: **reguły są sprawdzane pierwsze, tryb rozstrzyga tylko to,
czego żadna reguła nie złapała.**

## 1. Kolejność decyzji

```
hook PreToolUse  →  deny  →  ask  →  allow  →  tryb pracy
```

1. **Hook `PreToolUse`** (jeśli jest) — skrypt może zablokować wywołanie
   (`exit 2`). Blokada z hooka działa zawsze, w każdym trybie.
2. **`deny`** — wygrywa zawsze. Reguła deny z *dowolnego* pliku blokuje
   wywołanie, nawet jeśli gdzie indziej jest `allow`.
3. **`ask`** — wymusza pytanie, nawet gdy pasuje też `allow`.
4. **`allow`** — wykonuje bez pytania.
5. **Tryb pracy** — decyduje o wszystkim, co nie pasuje do żadnej reguły.

Przykład z tego repo (`.claude/settings.json`):

```json
"allow": ["Bash(terraform plan:*)", "Bash(kubectl get:*)", ...],
"ask":   ["Bash(terraform apply:*)", "Bash(kubectl apply:*)", "Bash(aws:*)", ...],
"deny":  ["Read(./**/.env)", "Read(./**/*.tfvars)", "Read(./**/credentials)"]
```

| Wywołanie | Co się stanie | Dlaczego |
|---|---|---|
| `terraform plan` | wykona się bez pytania | `allow` |
| `terraform apply` | zawsze zapyta, także w `acceptEdits` | `ask` |
| `Read(infra/terraform.tfvars)` | zablokowane w każdym trybie | `deny` |
| `ls -la` | zależy od trybu | żadna reguła nie pasuje |

## 2. Skąd biorą się reguły — hierarchia plików

Od najsilniejszego:

| # | Źródło | Do czego służy |
|---|---|---|
| 1 | polityka zarządzana (managed / enterprise) | ustawia admin firmy, nie da się nadpisać |
| 2 | argumenty CLI (`--permission-mode`, `--allowedTools`, ...) | jednorazowo dla tej sesji |
| 3 | `.claude/settings.local.json` | prywatne ustawienia w projekcie, **nie commitujemy** |
| 4 | `.claude/settings.json` | wspólne ustawienia zespołu, **w repo** |
| 5 | `~/.claude/settings.json` | Twoje globalne ustawienia, dla wszystkich projektów |

Ważne:

- listy `allow` / `ask` / `deny` z różnych plików **sumują się**, a nie
  zastępują — dlatego `deny` z repo działa u każdego, niezależnie od jego
  prywatnych ustawień;
- pojedyncze wartości (np. `defaultMode`) bierze plik wyżej w tabeli;
- `/permissions` w sesji pokazuje aktualny komplet reguł i skąd każda pochodzi.

## 3. Tryby pracy

Przełączasz Shift+Tab, ustawiasz flagą `--permission-mode` albo domyślnie
przez `"defaultMode"` w `settings.json`.

| Tryb | Co robi z wywołaniami bez pasującej reguły |
|---|---|
| `default` | pyta przy edycjach i większości komend |
| `acceptEdits` | sam zatwierdza edycje plików i proste operacje na plikach w katalogu projektu; inne komendy dalej pyta |
| `plan` | tylko czyta i planuje, niczego nie zmienia |
| `auto` | klasyfikator ocenia każde wywołanie: rutynowe przepuszcza, ryzykowne blokuje |
| `bypassPermissions` | nie pyta o nic — tylko w izolowanym środowisku (kontener, jednorazowa VM) |

Żaden tryb nie wyłącza `deny` ani blokady z hooka. `acceptEdits` nie
oznacza „rób co chcesz” — `terraform apply` z listy `ask` dalej zapyta.

### Tryb `auto` w praktyce

Klasyfikator patrzy na **skutek** akcji i na to, czy wynika ona z polecenia
użytkownika. Przykłady zablokowanych akcji z przygotowania tego szkolenia:

- zmiana hasła użytkownika IAM, o którą nikt wprost nie prosił — *Secret-Store Writes*,
- poluzowanie polityki `Deny iam:*` — *Security Weaken*.

Ta sama zmiana wykonana po wyraźnym poleceniu („zrób to przez Terraform”)
przeszła. Po blokadzie agent ma przerwać i wyjaśnić, czego potrzebuje —
nie szukać obejścia inną komendą.

Bardzo szerokie reguły `allow` w stylu `Bash(*)` mogą być w trybie `auto`
pomijane, żeby nie omijały klasyfikatora.

## 4. Czy Claude Code może sam zmienić `settings.json`?

| Kto | Kiedy | Efekt |
|---|---|---|
| **harness** (sam program) | klikasz „Yes, and don't ask again” przy pytaniu o zgodę | dopisuje regułę `allow` (zwykle do `settings.local.json`) |
| **model** (Edit / Write) | tylko na Twoją prośbę | pliki konfiguracji Claude Code są chronione — zmiana wymaga Twojej zgody, a w `auto` klasyfikator blokuje samodzielne rozszerzanie uprawnień |
| **model, po cichu** | nie | to jest dokładnie scenariusz, przed którym chronią mechanizmy powyżej |

Przykład z tego repo — `.claude/settings.local.json` powstał z kliknięcia
„don't ask again”:

```json
{ "permissions": { "allow": ["Bash(export AWS_PROFILE=szkolenie AWS_REGION=eu-central-1)"] } }
```

Zmiany w plikach ustawień zwykle działają bez restartu sesji.

## 5. Dobre praktyki

- **`deny` na sekrety w repo** (`.env`, `*.tfvars`, `credentials`) — działa
  u każdego, w każdym trybie. Uzupełnij hookiem, który łapie wzorce
  (`AKIA...`, `id_rsa`) — patrz [claude-code.md](claude-code.md#3-hooki-claudehooks-konfiguracja-w-claudesettingsjson).
- **`ask` na wszystko, co zmienia świat**: `apply`, `destroy`, `kubectl apply/delete`,
  `helm`, `aws`, `git push`.
- **`allow` na komendy tylko do odczytu i walidacji**: `plan`, `validate`,
  `fmt`, linters, `kubectl get/describe/logs`.
- **Przeglądaj `settings.local.json` i `~/.claude/settings.json`** — „don't ask
  again” klikane w pośpiechu zostawia dziesiątki jednorazowych reguł
  z pełnymi ścieżkami. Raz na jakiś czas je posprzątaj.
- **Nie traktuj trybu `auto` jako zabezpieczenia** — to wygoda. Twarde
  granice stawiają `deny`, hooki i uprawnienia IAM/RBAC po stronie chmury.

Szczegóły mogą się zmieniać między wersjami Claude Code — w razie wątpliwości
sprawdź `/permissions` i dokumentację: <https://docs.claude.com/en/docs/claude-code/iam>.
