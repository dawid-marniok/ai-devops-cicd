#!/usr/bin/env bash
# Hook do bloku dodatkowego: "czego nie wklejać do promptu".
#
# Czyta zdarzenie PreToolUse ze stdin i odrzuca próbę wciągnięcia do kontekstu
# pliku, który z definicji zawiera sekret. Exit 2 = Claude Code blokuje wywołanie
# i pokazuje komunikat ze stderr.
#
# To nie jest zabezpieczenie kryptograficzne, tylko siatka na najczęstszy błąd.
set -uo pipefail

zdarzenie=$(cat)
WZORCE='(^|/)\.env($|\.)|\.tfvars$|(^|/)credentials$|\.pem$|id_rsa|AKIA[0-9A-Z]{16}'

if grep -Eq "$WZORCE" <<<"$zdarzenie"; then
  echo "ZABLOKOWANE: próba wciągnięcia sekretu do kontekstu AI." >&2
  echo "Pliki .env, *.tfvars, credentials i klucze prywatne zostają poza promptem." >&2
  echo "Potrzebujesz wartości? Pobierz ją z Vaulta w czasie działania pipeline'u (demo d1-bx-01)." >&2
  exit 2
fi
exit 0
