# Przygotowanie środowiska

Wszystko poniżej zrób **przed** dniem 1. Na sali zaczynamy od razu od pracy.

## 1. Sprawdź, czego Ci brakuje

```bash
./setup/check-prereqs.sh
```

Czerwone pozycje blokują udział w ćwiczeniach. Żółte możesz zignorować.

## 2. Zainstaluj brakujące narzędzia

| Narzędzie | Instalacja |
|---|---|
| Git | menedżer pakietów systemu |
| Claude Code | `curl -fsSL https://claude.ai/install.sh \| bash` (macOS/Linux)<br>`irm https://claude.ai/install.ps1 \| iex` (Windows PowerShell) |
| VS Code + Cline | VS Code → `Ctrl/Cmd+Shift+X` → wpisz „Cline" → Install |
| Terraform | `brew install terraform` / `choco install terraform` / [releases](https://developer.hashicorp.com/terraform/downloads) |
| Docker | Docker Desktop albo Docker Engine + CLI |
| AWS CLI | `brew install awscli` / instalator MSI |
| kubectl, Helm | `brew install kubectl helm` / `choco install kubernetes-cli kubernetes-helm` |
| Plugin Argo Rollouts | `brew install argoproj/tap/kubectl-argo-rollouts` / [releases](https://github.com/argoproj/argo-rollouts/releases) |
| TFLint | `brew install terraform-linters/tap/tflint` / [releases](https://github.com/terraform-linters/tflint/releases) |
| Checkov | `brew install checkov` / `pip3 install checkov` |
| gh *(opcjonalnie)* | `brew install gh` — ułatwia pracę z PR z terminala |

TFLint i Checkov są wymagane. Pozostałe narzędzia (`trivy`, `conftest` i `vault`) są
opcjonalne — prowadzący pokaże je podczas demonstracji.

## 3. Konta

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
aws eks update-kubeconfig --name szkolenie-ai-devops --region eu-central-1
kubectl get pods -n $UCZESTNIK
```

### GitHub

Zwykłe konto osobiste. Darmowy plan wystarcza — potrzebujesz móc założyć repozytorium
i uruchamiać Actions.

## 4. Skonfiguruj repo

```bash
cp setup/env.example .env
# uzupełnij UCZESTNIK i dane z punktu 3
```

`Makefile` automatycznie wczytuje `.env`. Dla poleceń uruchamianych bezpośrednio
w terminalu załaduj i wyeksportuj wartości:

```bash
set -a
source .env
set +a
```

## 5. Sprawdź, że aplikacja startuje

```bash
make app-local
# w drugim terminalu:
curl localhost:8000/healthz
```

Jeśli to działa, jesteś gotowy.

## Jeśli coś nie działa w dniu szkolenia

Zgłoś prowadzącemu wynik `./setup/check-prereqs.sh` oraz dokładny komunikat błędu.
