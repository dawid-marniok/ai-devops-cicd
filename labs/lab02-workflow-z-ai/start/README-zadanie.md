# Dane Twojego środowiska

Uzupełnij przed rozpoczęciem — wartości dostaniesz od prowadzącego.

| Co | Gdzie to jest | Wartość |
|---|---|---|
| Rola OIDC do AWS | zmienna repozytorium `AWS_DEPLOY_ROLE_ARN` | `arn:aws:iam::<KONTO>:role/github-actions-deploy` |
| Repozytorium ECR | zmienna repozytorium `ECR_REPO` | |
| Region | — | `eu-central-1` |
| Twój namespace | zmienna repozytorium `K8S_NAMESPACE` | |

Ustawienie zmiennej repozytorium:

```bash
gh variable set AWS_DEPLOY_ROLE_ARN --body "arn:aws:iam::123456789012:role/github-actions-deploy"
```

Katalog `.github/workflows/` jest pusty — to tu ma powstać Twój workflow.
