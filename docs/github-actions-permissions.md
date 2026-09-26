# Uprawnienia w GitHub Actions — blok `permissions:`

Co faktycznie ustawiamy w bloku `permissions:` w workflow i dlaczego w naszych pipeline'ach zaczynamy od `permissions: {}`.

**W jednym zdaniu:** `permissions:` ustala zakres tokena `GITHUB_TOKEN`, który GitHub automatycznie tworzy dla każdego joba. Wpływa tylko na to, co job może zrobić w API GitHuba. Nie daje dostępu do AWS, Vaulta ani sekretów. Wyjątkiem jest `id-token`, opisany w części 5.

## 1. Skąd bierze się `GITHUB_TOKEN`

- GitHub tworzy nowy token na starcie **każdego joba**. Token wygasa, gdy job się skończy, maksymalnie po 24 godzinach.
- Jest dostępny jako `${{ secrets.GITHUB_TOKEN }}` albo `${{ github.token }}`. Wiele akcji, np. `actions/checkout`, bierze go automatycznie, bez żadnej konfiguracji.
- Działa tylko w repozytorium, w którym uruchomiono workflow.

## 2. Domyślne uprawnienia, gdy nie ma bloku `permissions:`

Zależą od ustawienia repozytorium lub organizacji: *Settings → Actions → General → Workflow permissions*.

| Tryb | Co dostaje token |
|---|---|
| **Restricted**: domyślny dla repozytoriów i organizacji tworzonych od 2023 roku | `contents: read`, `packages: read`, `metadata: read` |
| **Permissive**: spotykany w starszych repozytoriach | `write` do prawie wszystkiego |

Ten sam plik YAML może więc działać inaczej w dwóch repozytoriach. Dlatego zawsze deklarujemy uprawnienia jawnie.

## 3. Najważniejsza zasada: czego nie wymienisz, to dostaje `none`

Gdy tylko dodasz blok `permissions:`, wartości domyślne z punktu 2 przestają obowiązywać. Każdy zakres, którego nie wymienisz, dostaje `none`. Wyjątkiem jest `metadata: read`, które token ma zawsze.

```yaml
permissions:
  id-token: write
# contents dostało none, więc actions/checkout w prywatnym repozytorium się nie powiedzie
```

To bardzo częsty błąd: ktoś dopisuje `id-token: write` pod OIDC i nagle przestaje działać checkout. Poprawnie:

```yaml
permissions:
  contents: read
  id-token: write
```

Możliwe wartości:

- dla pojedynczego zakresu: `read`, `write` (zawiera też `read`) albo `none`;
- skróty dla całego bloku: `read-all`, `write-all`, `{}` (wszystko `none`).

## 4. Poziom workflow a poziom joba: nadpisanie, nie łączenie

Blok `permissions:` w jobie **w całości zastępuje** blok z poziomu workflow. Uprawnienia się nie sumują.

Przykład z naszego pipeline'u, `solutions/repo/.github/workflows/deploy.yml`:

```yaml
permissions: {}          # domyślnie żaden job nic nie może

jobs:
  test:
    permissions:
      contents: read     # ten job może tylko czytać kod
  build-push:
    permissions:
      contents: read
      id-token: write    # tylko ten job może poprosić o token OIDC do AWS
```

To wzorzec „deny by default”: `{}` na górze, a każdy job dostaje tylko to, czego potrzebuje. Jeśli ktoś doda nowy job i zapomni o `permissions:`, job nic nie zrobi. To lepsze niż job, który dostaje za dużo.

## 5. `id-token: write`: zakres, który działa inaczej niż pozostałe

To uprawnienie **nie daje zapisu do niczego w repozytorium**. Pozwala jobowi poprosić GitHuba o token JWT w standardzie OIDC. Następnie `aws-actions/configure-aws-credentials` albo `hashicorp/vault-action` wymienia ten token na krótkotrwałe poświadczenia.

Samo `id-token: write` nie daje dostępu do AWS. Decyzję podejmuje druga strona:

- w AWS: trust policy roli IAM,
- w Vaulcie: konfiguracja roli JWT.

Obie sprawdzają informacje zapisane w tokenie (tzw. claimy), np.:

```
sub: repo:organizacja/repo:ref:refs/heads/main
sub: repo:organizacja/repo:environment:prod
```

Dlatego w `solutions/lab06-vault-w-pipeline/solution/migracje.yml` job ma `id-token: write`, a o tym, do jakich sekretów ma dostęp, decyduje polityka w Vaulcie.

## 6. Najczęściej potrzebne uprawnienia

| Czynność | Uprawnienie |
|---|---|
| `actions/checkout` | `contents: read` |
| push commita lub taga, utworzenie release | `contents: write` |
| komentarz lub review na PR, etykiety na PR | `pull-requests: write` |
| komentarze i etykiety na issue | `issues: write` |
| push obrazu do GHCR | `packages: write` |
| OIDC do AWS, GCP, Azure lub Vaulta | `id-token: write` |
| upload wyników skanu SARIF (CodeQL, Trivy) | `security-events: write` |
| Check Runs, adnotacje w kodzie | `checks: write` |
| deploy na GitHub Pages | `pages: write` + `id-token: write` |
| uruchamianie lub anulowanie innych workflow przez API | `actions: write` |

Pełna lista zakresów jest w dokumentacji GitHuba w haśle „Permissions for the GITHUB_TOKEN”.

## 7. Twarde limity, których nie obejdziesz blokiem `permissions:`

1. **PR z forka** (wyzwalacz `pull_request`): token jest zawsze tylko do odczytu, a sekrety nie są przekazywane, nawet jeśli w YAML jest `write`.
2. **`pull_request_target`**: daje uprawnienia do zapisu i sekrety także dla PR z forków, bo workflow uruchamia się w kontekście gałęzi bazowej. Jest bezpieczny tylko wtedy, gdy **nie** checkoutuje i nie uruchamia kodu z PR. W przeciwnym razie obcy kod dostaje Twoje sekrety.
3. **Dependabot**: domyślnie token tylko do odczytu i osobny zestaw sekretów (*Settings → Secrets → Dependabot*).
4. **Reusable workflow** (`workflow_call`): wywoływany workflow może mieć najwyżej takie uprawnienia jak wywołujący, nie większe.
5. **Brak rekurencji**: push wykonany przez `GITHUB_TOKEN` nie uruchamia nowych workflow, z wyjątkiem `workflow_dispatch` i `repository_dispatch`. Jeśli push ma uruchamiać kolejne workflow, potrzebny jest PAT albo token GitHub App.

Uwaga: tryb Restricted z punktu 2 to tylko **wartość domyślna**, a nie górny limit. Workflow może jawnie poprosić o `contents: write` i je dostanie. Wyjątkiem jest osobne ustawienie organizacji, które w ogóle blokuje zapis.

## 8. Czego `permissions:` nie kontroluje

- **Dostępu do `secrets.*`.** Każdy job w repozytorium może odczytać jego sekrety. Do ograniczania służą *environments* z regułami ochrony, np. wymagana akceptacja albo tylko gałąź `main`.
- **PAT-ów i tokenów GitHub App** przekazywanych jako sekrety. Mają własne zakresy, ustawiane przy ich tworzeniu.
- **Uprawnień w chmurze.** O nich decydują trust policy i rola IAM (punkt 5).

## 9. Przykład z demo: bot komentujący PR

`demos/d1-b3-03-pr-comment-bot/ai-review.yml`:

```yaml
on:
  pull_request:
    types: [opened, synchronize]

permissions: {}

jobs:
  review:
    permissions:
      contents: read        # checkout i git diff
      pull-requests: write  # dodanie komentarza z recenzją
```

Co się tu dzieje:

- Job ma dokładnie dwa uprawnienia, a nie `write-all`. Jeśli skrypt lub akcja w tym jobie zostanie przejęta, nie wypchnie kodu, nie opublikuje release i nie zmieni ustawień repozytorium.
- Wyzwalacz to `pull_request`, a nie `pull_request_target`. Dla PR z forka bot więc **nie zadziała w pełni**: token będzie tylko do odczytu (komentarz się nie doda), a klucz API modelu nie zostanie przekazany. To świadomy wybór, bo bezpieczeństwo jest tu ważniejsze niż wygoda.

## 10. Diagnostyka

**Błąd `403 Resource not accessible by integration`** prawie zawsze oznacza, że tokenowi brakuje jakiegoś zakresu.

Jak sprawdzić, co job faktycznie dostał:

1. Otwórz log joba.
2. Rozwiń krok **Set up job**.
3. Znajdź sekcję **GITHUB_TOKEN Permissions**. Jest tam lista uprawnień obliczona dla tego uruchomienia.

Jeśli brakuje zakresu, dopisz go **w konkretnym jobie**, a nie na poziomie całego workflow.

## Ściągawka

- Na górze workflow: `permissions: {}`.
- W każdym jobie: tylko potrzebne zakresy; prawie zawsze `contents: read`.
- `id-token: write` tylko w jobach, które logują się do chmury lub Vaulta.
- Uprawnienia joba zastępują uprawnienia z workflow, nie sumują się.
- Czego nie wymienisz, to dostaje `none`.
- PR z forka zawsze dostaje token tylko do odczytu i nie dostaje sekretów. Nie próbuj tego obchodzić przez `pull_request_target` z checkoutem kodu z PR.
