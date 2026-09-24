#!/usr/bin/env bash
# Cztery warstwy walidacji na jednym module. Każda łapie co innego.
#
#   ./scripts/waliduj.sh [katalog-modulu]
#
# Domyślnie sprawdza moduł z celowymi błędami — czerwony wynik jest tu oczekiwany.

set -uo pipefail
KATALOG="${1:-infra/modules/app-storage-bledny}"
B='\033[1m'; N='\033[0m'

warstwa() { printf "\n${B}── %s ─────────────────────────────${N}\n" "$1"; }

printf "${B}Walidacja: %s${N}\n" "$KATALOG"

warstwa "1/4  terraform validate — składnia i typy"
(cd "$KATALOG" && terraform init -backend=false -no-color >/dev/null 2>&1 && terraform validate -no-color)

warstwa "2/4  tflint — dobre praktyki i błędy specyficzne dla providera"
if command -v tflint >/dev/null 2>&1; then
  tflint --chdir="$KATALOG" --no-color || true
else
  echo "  tflint nie zainstalowany — pomijam (instalacja: brew install tflint)"
fi

warstwa "3/4  Checkov — polityki bezpieczeństwa"
if command -v checkov >/dev/null 2>&1; then
  checkov -d "$KATALOG" --compact --quiet --framework terraform || true
else
  echo "  Checkov nie zainstalowany — pomijam (instalacja: pip install checkov)"
fi

warstwa "4/4  Trivy — konfiguracja i znane podatności"
if command -v trivy >/dev/null 2>&1; then
  trivy config --quiet "$KATALOG" || true
else
  echo "  Trivy nie zainstalowany — pomijam (instalacja: brew install trivy)"
fi

printf "\n${B}Gotowe.${N} Wynik z celowo zepsutego modułu MA być czerwony.\n"
