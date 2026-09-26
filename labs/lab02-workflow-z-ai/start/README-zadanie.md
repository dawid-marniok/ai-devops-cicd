# Dane Twojego środowiska

Uzupełnij przed rozpoczęciem — wartości dostaniesz od prowadzącego.

| Co | Gdzie to jest | Wartość |
|---|---|---|
| Rola OIDC do AWS | zmienna repozytorium `AWS_DEPLOY_ROLE_ARN` | `arn:aws:iam::<KONTO>:role/github-actions-deploy` |
| Repozytorium ECR | zmienna repozytorium `ECR_REPO` | |
| Region | — | `eu-central-1` |
| Twój namespace | zmienna repozytorium `K8S_NAMESPACE` | |

Rola `github-actions-deploy` przyjmuje tokeny tylko z repozytoriów zgłoszonych prowadzącemu
(`setup/README.md`, punkt 1). Błąd `Not authorized to perform sts:AssumeRoleWithWebIdentity`
oznacza, że Twojego repo jeszcze nie ma na liście — zgłoś to, nie zmieniaj workflow.

Ustawienie zmiennej repozytorium:

```bash
gh variable set AWS_DEPLOY_ROLE_ARN --body "arn:aws:iam::123456789012:role/github-actions-deploy"
```

## Gdzie utworzyć workflow

Nie twórz `.github/workflows/` wewnątrz tego katalogu `start/`. GitHub rozpoznaje workflow
wyłącznie w `.github/workflows/` znajdującym się w głównym katalogu repozytorium — tam, gdzie
znajduje się katalog `.git`.

Przejdź do głównego katalogu i utwórz plik:

```bash
cd "$(git rev-parse --show-toplevel)"
mkdir -p .github/workflows
$EDITOR .github/workflows/deploy.yml
```

Oczekiwana struktura:

```text
ai-devops-cicd/
├── .git/
├── .github/
│   └── workflows/
│       └── deploy.yml      # wynik tego laboratorium
├── app/
└── labs/
    └── lab02-workflow-z-ai/
        └── start/
            └── README-zadanie.md
```

Każdy uczestnik tworzy ten plik w głównym katalogu **swojego** repozytorium lub forka.
