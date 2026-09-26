#!/usr/bin/env bash
# Sprawdza, czy masz wszystko, czego potrzebujesz na warsztatach.
# Odpal PRZED szkoleniem — na sali nie ma czasu na instalacje.
#
#   ./setup/check-prereqs.sh
#
# Zielone = OK. Żółte = zadziała, ale coś stracisz. Czerwone = napraw przed dniem 1.

set -uo pipefail

G='\033[0;32m'; Y='\033[0;33m'; R='\033[0;31m'; B='\033[1m'; N='\033[0m'
blad=0; ostrzezenie=0

naglowek() { printf "\n${B}%s${N}\n" "$1"; }
ok()   { printf "  ${G}OK${N}       %s\n" "$1"; }
warn() { printf "  ${Y}UWAGA${N}    %s\n" "$1"; ostrzezenie=$((ostrzezenie+1)); }
fail() { printf "  ${R}BRAK${N}     %s\n" "$1"; blad=$((blad+1)); }

# sprawdz <komenda> <min-wersja> <opis> [wymagane] [argumenty-wersji]
# Domyślnie pyta o wersję przez `--version`; kubectl i helm mają własną składnię.
sprawdz() {
  local cmd="$1" min="$2" opis="$3" wymagane="${4:-tak}" argw="${5:---version}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    [[ "$wymagane" == "tak" ]] && fail "$opis — brak w PATH" || warn "$opis — brak (opcjonalne)"
    return
  fi
  local v
  v=$("$cmd" $argw 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
  if [[ -z "$v" ]]; then ok "$opis (wersja nierozpoznana)"; return; fi
  if [[ "$(printf '%s\n%s' "$min" "$v" | sort -V | head -1)" == "$min" ]]; then
    ok "$opis $v"
  else
    warn "$opis $v — zalecane min. $min"
  fi
}

printf "${B}Warsztaty: AI DevOps z Claude, Cline i Terraform${N}\n"
printf "Sprawdzam środowisko na: %s\n" "$(uname -s) $(uname -m)"

naglowek "1. System i sprzęt"
case "$(uname -s)" in
  Darwin) ok "macOS $(sw_vers -productVersion 2>/dev/null)" ;;
  Linux)  ok "Linux $(uname -r)" ;;
  *)      warn "System $(uname -s) — Claude Code wspiera macOS 13+, Windows 10 1809+, Ubuntu 20.04+/Debian 10+" ;;
esac

ram_gb=0
if [[ "$(uname -s)" == "Darwin" ]]; then
  ram_gb=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
elif [[ -r /proc/meminfo ]]; then
  ram_gb=$(( $(awk '/MemTotal/{print $2}' /proc/meminfo) / 1024 / 1024 ))
fi
if   (( ram_gb >= 16 )); then ok "RAM ${ram_gb} GB"
elif (( ram_gb >= 8 ));  then warn "RAM ${ram_gb} GB — Docker + IDE + klaster naraz może być ciasno, zalecane 16 GB"
elif (( ram_gb > 0 ));   then fail "RAM ${ram_gb} GB — za mało, minimum to 8 GB"
else warn "Nie udało się odczytać ilości RAM"; fi

naglowek "2. Narzędzia wymagane"
sprawdz git       2.30  "Git"
sprawdz terraform 1.10  "Terraform CLI"
sprawdz aws       2.15  "AWS CLI"
sprawdz kubectl   1.29  "kubectl" tak "version --client"
sprawdz helm      3.14  "Helm"    tak "version --short"
sprawdz python3   3.11  "Python"
sprawdz tflint    0.50  "TFLint"
sprawdz checkov   3.2   "Checkov"

# Plugin 1.x nie zna flagi --client; samo `version` nie łączy się z klastrem.
if kubectl argo rollouts version >/dev/null 2>&1; then
  ok "Plugin kubectl-argo-rollouts"
else
  fail "Plugin kubectl-argo-rollouts — instalacja: brew install argoproj/tap/kubectl-argo-rollouts"
fi

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then ok "Docker — działa"
  else fail "Docker zainstalowany, ale daemon nie odpowiada (uruchom Docker Desktop)"; fi
else
  fail "Docker — brak w PATH"
fi

naglowek "3. Narzędzia AI"
if command -v claude >/dev/null 2>&1; then
  ok "Claude Code $(claude --version 2>&1 | head -1)"
else
  fail "Claude Code — instalacja: curl -fsSL https://claude.ai/install.sh | bash"
fi

if command -v code >/dev/null 2>&1; then
  ok "VS Code"
  if code --list-extensions 2>/dev/null | grep -qi 'saoudrizwan.claude-dev'; then
    ok "Rozszerzenie Cline"
  else
    fail "Rozszerzenie Cline — VS Code → Ctrl/Cmd+Shift+X → szukaj \"Cline\""
  fi
else
  warn "VS Code — brak komendy 'code' w PATH (Cmd+Shift+P → \"Shell Command: Install 'code' command\")"
fi

naglowek "4. Narzędzia opcjonalne (przydadzą się, ale da się bez nich)"
sprawdz gh        2.40  "GitHub CLI"                nie
sprawdz actionlint 1.7  "actionlint (lab02, lab03)" nie
sprawdz trivy     0.50  "Trivy"                     nie
sprawdz conftest  0.56  "Conftest"                  nie
sprawdz vault     1.15  "Vault CLI"                 nie

naglowek "5. Sieć"
# Najczęstszy problem u klienta korporacyjnego: firewall blokuje API modelu.
for host in github.com api.anthropic.com ec2.eu-central-1.amazonaws.com; do
  if curl -sS --max-time 6 -o /dev/null "https://$host" 2>/dev/null; then
    ok "https://$host osiągalny"
  else
    fail "https://$host NIEOSIĄGALNY — zgłoś to przed szkoleniem, nie w dniu szkolenia"
  fi
done

naglowek "6. Konta"
if aws sts get-caller-identity >/dev/null 2>&1; then
  ok "AWS — zalogowany jako $(aws sts get-caller-identity --query Arn --output text)"
else
  warn "AWS — brak skonfigurowanych danych (dostaniesz je od prowadzącego, patrz setup/README.md)"
fi
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  ok "GitHub — zalogowany"
else
  warn "GitHub — 'gh auth login' albo logowanie przez przeglądarkę"
fi

printf "\n${B}Podsumowanie${N}\n"
if (( blad > 0 )); then
  printf "  ${R}%d rzeczy do naprawienia${N} przed szkoleniem.\n" "$blad"
  (( ostrzezenie > 0 )) && printf "  ${Y}%d ostrzeżeń${N} — nie blokują.\n" "$ostrzezenie"
  exit 1
fi
if (( ostrzezenie > 0 )); then
  printf "  ${Y}%d ostrzeżeń${N}, nic blokującego. Do zobaczenia na warsztatach.\n" "$ostrzezenie"
  exit 0
fi
printf "  ${G}Wszystko gotowe.${N} Do zobaczenia na warsztatach.\n"
