#!/usr/bin/env bash
# Generuje obciążenie aplikacji — do HPA (Blok 5) i do analizy canary (Blok 4).
#
#   ./scripts/obciaz.sh <namespace> [sekundy] [rownolegle]

set -euo pipefail
NS="${1:?Podaj namespace}"
CZAS="${2:-300}"
ROWNOLEGLE="${3:-20}"

ADRES=$(kubectl -n "$NS" get ingress quotes-api \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [[ -z "$ADRES" ]]; then
  echo "Nie widzę adresu ALB. Sprawdź: kubectl -n $NS get ingress" >&2
  exit 1
fi

echo "Obciążam http://$ADRES/api/slow przez ${CZAS}s, $ROWNOLEGLE równoległych żądań."
echo "W drugim terminalu: kubectl get hpa,pods -n $NS -w"
echo

if command -v hey >/dev/null 2>&1; then
  hey -z "${CZAS}s" -c "$ROWNOLEGLE" "http://$ADRES/api/slow?ms=400"
else
  # Wariant bez dodatkowych narzędzi — wystarczy do rozgrzania HPA.
  echo "(hey niezainstalowany, używam pętli z curl)"
  KONIEC=$((SECONDS + CZAS))
  for _ in $(seq 1 "$ROWNOLEGLE"); do
    (while ((SECONDS < KONIEC)); do
      curl -s -o /dev/null "http://$ADRES/api/slow?ms=400"
    done) &
  done
  wait
fi
