# Przygotowanie środowiska

Wszystko poniżej zrób **przed** dniem 1. Na sali zaczynamy od razu od pracy.

## 1. GitHub i własna kopia repozytorium

Potrzebujesz zwykłego konta osobistego na GitHubie. Darmowy plan wystarcza — musisz móc
założyć repozytorium i uruchamiać Actions.

GitHub CLI (`gh`) jest już zainstalowany na maszynie szkoleniowej. Zaloguj się:

```bash
gh auth login                # GitHub.com → HTTPS → Login with a web browser
gh auth status               # powinno pokazać Twój login
```

Jeśli na maszynie nie otworzy się przeglądarka, `gh` wypisze jednorazowy kod i adres
`https://github.com/login/device`. Otwórz go na swoim laptopie i wklej kod.

**Okno „Authentication required … no longer matches that of your login keyring”.**
To nie jest błąd GitHuba, tylko systemowy magazyn haseł (GNOME Keyring). `gh` i Chrome
próbują w nim zapisać dane, a keyring ma inne hasło niż Twoje obecne konto na maszynie.
Linie `DEPRECATED_ENDPOINT` i `ConnectionHandler failed` w terminalu to logi Chrome —
możesz je zignorować.

Najprościej: kliknij **Anuluj**, przerwij `gh` (`Ctrl+C`) i zaloguj się bez keyringa —
token trafi do pliku `~/.config/gh/hosts.yml`:

```bash
gh auth login --insecure-storage
gh auth status
```

Jeśli okno ma przestać wyskakiwać, usuń keyring i przy następnym pytaniu ustaw mu
**aktualne hasło logowania do maszyny**:

```bash
rm -f ~/.local/share/keyrings/login.keyring
```

Kod z `gh auth login` jest jednorazowy i wygasa po kilku minutach — przy ponownej
próbie dostaniesz nowy.

Workflow GitHub Actions i zmienne repozytorium (lab02, lab03, lab06) działają tylko
w repozytorium, które należy do Ciebie. Dlatego robisz **fork**, czyli własną kopię repo
na swoim koncie GitHub, i klonujesz ją na maszynę:

```bash
cd ~
gh repo fork dawid-marniok/ai-devops-cicd --clone
cd ai-devops-cicd
```

Przykład dla użytkownika `anna-k`:

```text
$ gh repo fork dawid-marniok/ai-devops-cicd --clone
✓ Created fork anna-k/ai-devops-cicd
Cloning into 'ai-devops-cicd'...
✓ Cloned fork
```

Sprawdź, czy zdalne repozytoria są ustawione poprawnie:

```text
$ git remote -v
origin    https://github.com/anna-k/ai-devops-cicd.git (fetch)          ← Twój fork, tu pushujesz
origin    https://github.com/anna-k/ai-devops-cicd.git (push)
upstream  https://github.com/dawid-marniok/ai-devops-cicd.git (fetch)   ← repo prowadzącego
upstream  https://github.com/dawid-marniok/ai-devops-cicd.git (push)
```

Ustaw swój fork jako domyślne repo dla `gh`. Po sklonowaniu forka `gh` wypisuje
ostrzeżenie `dawid-marniok/ai-devops-cicd set as the default repository`, czyli domyślnie
celuje w repo prowadzącego. Wtedy `gh variable set` (lab02, lab06), `gh run list`
i `gh pr create` trafiałyby nie tam, gdzie trzeba:

```bash
gh repo set-default <twój-login>/ai-devops-cicd    # np. anna-k/ai-devops-cicd
gh repo set-default --view                         # ma pokazać Twój fork
```

Jeśli w trakcie szkolenia prowadzący poprawi materiały, pobierzesz zmiany poleceniem
`git pull upstream main`.

Bez `gh`: na stronie https://github.com/dawid-marniok/ai-devops-cicd kliknij **Fork**,
a potem `git clone https://github.com/<twój-login>/ai-devops-cicd.git`.

**Wyślij prowadzącemu nazwę swojej kopii** (w przykładzie: `anna-k/ai-devops-cicd`). Bez tego rola AWS
dla GitHub Actions nie przyjmie tokenu z Twojego repo i pipeline w lab02 nie zaloguje się do AWS.

Wszystkie kolejne polecenia uruchamiasz w katalogu `ai-devops-cicd`.

## 2. Sprawdź, czego Ci brakuje

```bash
./setup/check-prereqs.sh
```

Czerwone pozycje blokują udział w ćwiczeniach. Żółte możesz zignorować.

## 3. Zainstaluj brakujące narzędzia

Środowisko szkoleniowe to Linux (Ubuntu). Większość narzędzi jest już zainstalowana
na maszynie. Na starcie doinstalowujesz trzy: TFLint, Checkov i plugin Argo Rollouts.
Po instalacji uruchom ponownie `./setup/check-prereqs.sh` — nie powinno być nic na czerwono.

| Narzędzie | Min. wersja | Na maszynie | Instalacja |
|---|---|---|---|
| **TFLint** | 0.50 | ⬜ instalujesz | `curl -fsSL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh \| bash` |
| **Checkov** | 3.2 | ⬜ instalujesz | `sudo apt install -y pipx && pipx install checkov && pipx ensurepath` (potem otwórz nowy terminal) |
| **Plugin Argo Rollouts** | — | ⬜ instalujesz | `curl -fsSLO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64 && sudo install kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts` |
| actionlint *(opcjonalnie)* | 1.7 | ⬜ opcjonalnie | `bash <(curl -fsSL https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash) && sudo mv actionlint /usr/local/bin/` |
| Git, GitHub CLI | 2.30 / 2.40 | ✅ jest | — |
| Python | 3.11 | ✅ jest | — |
| Terraform | 1.10 | ✅ jest | — |
| AWS CLI | 2.15 | ✅ jest | — |
| kubectl | 1.29 | ✅ jest | — |
| Helm | 3.14 | ✅ jest | — |
| Docker | — | ✅ jest | — |
| Claude Code | — | ✅ jest | — |
| VS Code + Cline | — | ✅ jest | — |

TFLint i Checkov są wymagane. Pozostałe narzędzia (`trivy`, `conftest`, `vault`, `actionlint`)
są opcjonalne — prowadzący pokaże je podczas demonstracji.

## 4. Konta

### Claude Code i Cline — jedna subskrypcja na oba narzędzia

Claude Code wymaga płatnego planu (Pro, Max, Team, Enterprise albo Console/API).
Darmowy plan claude.ai **nie wystarczy**. Dostęp na czas warsztatów zapewnia prowadzący.

Cline może korzystać z tej samej subskrypcji — nie potrzebujesz osobnego klucza API:

1. Zainstaluj i zaloguj Claude Code (`claude`, potem `/login`)
2. VS Code → Cline → Settings → API Configuration → provider **„Claude Code"**
3. W polu ze ścieżką do CLI zwykle wystarczy `claude`, jeśli jest w `PATH`

W tym trybie odpowiedzi nie strumieniują się token po tokenie — pojawiają się naraz po chwili.
Dla ćwiczeń z code review nie ma to znaczenia.

### AWS

Konto szkoleniowe i użytkownika IAM dostajesz od prowadzącego — **nie używaj konta firmowego**.
Logowanie do konsoli: `https://<ID_KONTA>.signin.aws.amazon.com/console`.

Do CLI:

```bash
aws configure          # wklej Access Key ID i Secret Access Key, region eu-central-1
aws sts get-caller-identity   # powinno pokazać Twojego użytkownika
```

Dzień 2, dostęp do klastra:

```bash
set -a; source .env; set +a     # UCZESTNIK i ECR_REPO, patrz „Plik .env” niżej
aws eks update-kubeconfig --name szkolenie-ai-devops --region eu-central-1
kubectl get pods -n $UCZESTNIK  # "No resources found" to poprawny wynik
```

Grafana (dashboardy w lab07, lab10, lab11) działa w klastrze — adres i hasło poda prowadzący.

## 5. Środowisko Python i testy

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r app/requirements-dev.txt
cd app && pytest -q && cd ..    # 6 testów ma przejść
```

`source .venv/bin/activate` powtarzasz w każdym nowym terminalu, w którym używasz
`pytest`, `ruff`, `uvicorn` albo `python` z zależnościami aplikacji.

## 6. Sprawdź, że aplikacja startuje

```bash
cd app && uvicorn main:app --reload --port 8000
# w drugim terminalu:
curl localhost:8000/healthz
```

Jeśli to działa, jesteś gotowy.

## Plik .env — dzień 2

Laby dnia 2 (lab07, lab08, lab10, lab11) potrzebują dwóch wartości, które poda prowadzący:
Twojego identyfikatora i adresu rejestru obrazów. Zapisz je w pliku `.env`
(jest w `.gitignore`, nie trafi do repo):

```bash
cp setup/env.example .env
# uzupełnij UCZESTNIK i ECR_REPO
```

Na początku każdego labu, w każdym terminalu, wczytujesz je poleceniem:

```bash
set -a; source .env; set +a
```

## 7. Przed dniem 2 — strażnik promptów (lab09)

Zależności labu 09 ważą około 1 GB, dlatego zainstaluj je wcześniej, w osobnym venv:

```bash
python3 -m venv labs/lab09-llm-firewall/.venv
labs/lab09-llm-firewall/.venv/bin/pip install -r labs/lab09-llm-firewall/start/requirements.txt
```

## Jeśli coś nie działa w dniu szkolenia

Zgłoś prowadzącemu wynik `./setup/check-prereqs.sh` oraz dokładny komunikat błędu.
