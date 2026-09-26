#!/usr/bin/env bash
# One-button deploy — spina bloki 1–5 w jedną komendę.
#
#   ./scripts/deploy.sh <namespace> [wersja]
#   ./scripts/deploy.sh anna-k v2
#
# Skrypt zatrzymuje się przed każdą operacją nieodwracalną i pyta. To nie jest
# utrudnienie — to jest ten sam wzorzec, który konfigurowaliśmy w .claude/settings.json.

set -euo pipefail

NS="${1:?Podaj namespace (swój identyfikator uczestnika)}"
WERSJA="${2:-v2}"
REGION="${AWS_REGION:-eu-central-1}"
KLASTER="${EKS_CLUSTER:-szkolenie-ai-devops}"
KATALOG_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

B='\033[1m'; G='\033[0;32m'; Y='\033[0;33m'; N='\033[0m'
krok()   { printf "\n${B}[%s/6] %s${N}\n" "$1" "$2"; }
ok()     { printf "${G}  ✓ %s${N}\n" "$1"; }
pytaj()  {
  printf "${Y}  ? %s [t/N] ${N}" "$1"
  read -r odp
  [[ "$odp" =~ ^[TtYy]$ ]]
}

printf "${B}Wdrożenie quotes-api %s do namespace %s${N}\n" "$WERSJA" "$NS"

# ── 1. Infrastruktura ────────────────────────────────────────────────
krok 1 "Infrastruktura (Blok 1)"
cd "$KATALOG_REPO/infra/modules/app-storage"
terraform init -input=false >/dev/null
terraform plan -input=false -var="uczestnik=$NS" -out=/tmp/tfplan-"$NS"
echo
if pytaj "Wykonać apply na powyższym planie?"; then
  terraform apply -input=false /tmp/tfplan-"$NS"
  ok "Infrastruktura gotowa"
else
  echo "  Pomijam apply — idę dalej z istniejącą infrastrukturą."
fi

# ── 2. Obraz ─────────────────────────────────────────────────────────
krok 2 "Budowa obrazu (Blok 2)"
cd "$KATALOG_REPO"
: "${ECR_REPO:?Ustaw ECR_REPO — wartość przekazuje prowadzący w pliku .env}"

aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "${ECR_REPO%%/*}" >/dev/null

# Rejestr jest wspólny dla grupy — tag z prefiksem uczestnika, żeby nikt nie nadpisał
# cudzego `v2`. Budujemy pod linux/amd64, bo na tej architekturze działają węzły EKS
# (bez tego obraz z Maca na Apple Silicon nie wystartuje: `exec format error`).
OBRAZ="$ECR_REPO:$NS-$WERSJA"
docker build --platform linux/amd64 --build-arg "APP_VERSION=$WERSJA" -t "$OBRAZ" app/
docker push "$OBRAZ"
ok "Obraz $OBRAZ w rejestrze"

# ── 3. Skan ──────────────────────────────────────────────────────────
krok 3 "Skan obrazu (Blok 1)"
if command -v trivy >/dev/null 2>&1; then
  trivy image --severity HIGH,CRITICAL --exit-code 0 "$OBRAZ" || true
  ok "Skan wykonany"
else
  echo "  Trivy niezainstalowany — pomijam."
fi

# ── 4. Dostęp do klastra ─────────────────────────────────────────────
krok 4 "Dostęp do klastra"
aws eks update-kubeconfig --name "$KLASTER" --region "$REGION" >/dev/null
kubectl get ns "$NS" >/dev/null
ok "Namespace $NS dostępny"

# ── 5. Canary ────────────────────────────────────────────────────────
krok 5 "Wdrożenie canary (Blok 4)"
if ! kubectl -n "$NS" get rollout quotes-api >/dev/null 2>&1; then
  kubectl -n "$NS" apply -f app/k8s/flagd.yaml -f app/k8s/service.yaml \
    -f app/k8s/ingress.yaml -f app/k8s/analysis.yaml -f app/k8s/hpa.yaml
  sed "s|PODMIEN_NA_ECR/quotes-api:v1|$OBRAZ|" app/k8s/rollout.yaml \
    | kubectl -n "$NS" apply -f -
  ok "Rollout utworzony"
else
  kubectl argo rollouts set image quotes-api "quotes-api=$OBRAZ" -n "$NS"
  ok "Nowa wersja wystartowała jako canary"
fi

# ── 6. Obserwacja ────────────────────────────────────────────────────
krok 6 "Obserwacja (Blok 5)"
echo "  Podział ruchu i stan analizy:"
echo
kubectl argo rollouts get rollout quotes-api -n "$NS"

ADRES=$(kubectl -n "$NS" get ingress quotes-api \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)

echo
printf "${B}Co dalej${N}\n"
[[ -n "$ADRES" ]] && echo "  Aplikacja:  http://$ADRES"
cat <<EOF
  Podgląd:    kubectl argo rollouts get rollout quotes-api -n $NS --watch
  Promocja:   kubectl argo rollouts promote quotes-api -n $NS
  Wycofanie:  kubectl argo rollouts undo quotes-api -n $NS

Canary NIE zostało wypromowane do 100%. Spójrz najpierw na wykresy w Grafanie.
EOF
