# Kontekst projektu dla agenta AI

Repozytorium szkoleniowe: aplikacja `quotes-api` plus infrastruktura AWS, która ją hostuje.
Ten plik jest jednocześnie materiałem dydaktycznym — w Bloku 1 pokazujemy, jak zmienia
się jakość generowanego kodu, kiedy agent ma taki kontekst, a kiedy go nie ma.

## Stack

- Aplikacja: Python 3.12, FastAPI, testy w pytest, lint `ruff`
- Infrastruktura: Terraform, provider `hashicorp/aws`, region `eu-central-1`
- Kubernetes: EKS, wdrożenia przez Argo Rollouts (obiekt `Rollout`, nie `Deployment`)
- CI/CD: GitHub Actions, uwierzytelnianie do AWS przez OIDC
- Feature-flagi: OpenFeature + flagd (flagi jako plik JSON)
- Sekrety: HashiCorp Vault, dynamic secrets — nigdy wartości w repo

## Konwencje, których trzymaj się bez pytania

- Nazwy zasobów: `szkolenie-<blok>-<zasob>-<uczestnik>`, np. `szkolenie-b1-artifacts-dawid`
- Każdy zasób AWS ma tagi: `Projekt = ai-devops-cicd`, `Uczestnik`, `Blok`, `Usuwac = tak`
- Zmienne Terraform zawsze z `description` i jawnym `type`
- Bucket S3: szyfrowanie włączone, publiczny dostęp zablokowany, wersjonowanie włączone
- Security group: żadnego `0.0.0.0/0` na porcie innym niż 443
- Workflow GitHub Actions: zawsze `permissions:` na poziomie joba i `timeout-minutes`
- Komentarze i teksty dla użytkownika po polsku, nazwy techniczne po angielsku

## Czego nie rób

- Nie uruchamiaj `terraform apply` ani `kubectl delete` bez wyraźnej prośby — proponuj `plan` i czekaj
- Nie dopisuj `#checkov:skip` ani `#tfsec:ignore`, żeby uciszyć skaner. Napraw przyczynę
- Nie wciągaj do kontekstu plików `.env`, `*.tfvars`, `credentials` — są celowo poza repo
- Nie podnoś wersji providerów i actions „przy okazji" innej zmiany

## Katalogi

- `app/` — aplikacja, jedyne miejsce z kodem produktu
- `infra/modules/` — moduły do ćwiczeń; `app-storage-bledny` ma celowe błędy, nie „naprawiaj" go z własnej inicjatywy
- `labs/*/start/` — pliki startowe ćwiczeń; rozwiązania omawia prowadzący
