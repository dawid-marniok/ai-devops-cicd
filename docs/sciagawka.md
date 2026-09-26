# Ściągawka — jedna strona

## Zmienne, które warto mieć w środowisku

```bash
set -a; source .env; set +a         # UCZESTNIK, ECR_REPO… — set -a eksportuje zmienne
export NS=$UCZESTNIK                # twój namespace
export ADRES=$(kubectl -n $NS get ingress quotes-api -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

## Terraform

```bash
terraform init -backend=false            # bez stanu zdalnego, do walidacji
terraform fmt -recursive                 # formatowanie
terraform validate                       # składnia i typy
terraform plan -detailed-exitcode        # kod 2 = są zmiany (drift!)
terraform plan -refresh-only             # co zmieniło się w chmurze
terraform apply plan.tfplan              # apply dokładnie tego, co widziałeś
terraform show -json tfplan > plan.json  # plan dla Conftest
```

## Skanery

```bash
tflint --recursive
checkov -d . --compact
trivy config .
trivy image ${ECR_REPO}:$NS-v2
actionlint
```

## GitHub Actions

```bash
gh run list --limit 5
gh run watch
gh run view --log-failed          # pierwszy prawdziwy błąd jest na GÓRZE
gh pr create --fill
gh pr diff
gh variable set NAZWA --body "wartość"
```

## Kubernetes

```bash
kubectl get pods,svc,ingress -n $NS
kubectl describe pod <pod> -n $NS          # sekcja "Last State" przy restartach
kubectl logs <pod> -n $NS --previous       # log poprzedniej, zabitej instancji
kubectl get events -n $NS --sort-by=.lastTimestamp
kubectl top pods -n $NS                   # wymaga metrics-server w klastrze
kubectl describe quota -n $NS              # gdy pody stoją w Pending
```

## Argo Rollouts

```bash
kubectl argo rollouts get rollout quotes-api -n $NS --watch
kubectl argo rollouts set image quotes-api quotes-api=${ECR_REPO}:$NS-v2 -n $NS
kubectl argo rollouts promote quotes-api -n $NS      # kolejny krok wag
kubectl argo rollouts promote quotes-api -n $NS --full
kubectl argo rollouts undo quotes-api -n $NS         # wycofanie
kubectl get analysisrun -n $NS                       # stan bramki jakości
```

## Vault

```bash
export VAULT_ADDR=http://127.0.0.1:8200 VAULT_TOKEN=root
vault read database/creds/quotes-api      # odpal dwa razy — inny użytkownik za każdym razem
vault list database/roles
vault policy read quotes-api
```

## Claude Code — komendy tego repo

```
/tf-review          recenzja zmian w Terraform
/drift-fix [kat] [uczestnik]  wykryj drift i przygotuj PR z poprawką
/pr-review [nr]     recenzja PR w trzech przebiegach
/postmortem <ns>    post-mortem z logów i metryk
/tco                koszt infrastruktury plus tokenów
```

## Aplikacja i skrypty repo

```bash
set -a; source .env; set +a; export NS=$UCZESTNIK   # w każdym nowym terminalu
source .venv/bin/activate

cd app && uvicorn main:app --reload --port 8000     # aplikacja lokalnie na :8000
cd app && pytest -q && ruff check .                 # testy i lint
./scripts/waliduj.sh                                # cztery warstwy walidacji Terraform
./scripts/deploy.sh $NS v2                          # obraz → skan → canary
./scripts/obciaz.sh $NS                             # obciążenie do HPA i canary
```

## Kody, które warto rozpoznawać od ręki

| Kod | Znaczenie |
|---|---|
| `terraform plan` kończy się `2` | wykryto zmiany — w CI to sygnał driftu |
| kontener kończy się `137` | SIGKILL, najczęściej OOMKilled — nie znajdziesz wyjątku w logach |
| kontener kończy się `143` | SIGTERM, czyli zamknięcie w normalnym trybie |
| pod w `Pending` | brak zasobów na węzłach albo `ResourceQuota` |
| `CrashLoopBackOff` | restartuje się w kółko — patrz `logs --previous` |
