# AI DevOps z Claude, Cline i Terraform

Materiały uczestnika do dwudniowych warsztatów z wykorzystania AI w IaC, CI/CD,
code review, wdrożeniach Kubernetes i analizie incydentów.

## Przygotowanie

```bash
gh auth login                                       # logowanie do GitHuba
gh repo fork dawid-marniok/ai-devops-cicd --clone   # własna kopia repo
cd ai-devops-cicd
./setup/check-prereqs.sh                            # czego brakuje na laptopie
python3 -m venv .venv && source .venv/bin/activate
pip install -r app/requirements-dev.txt             # zależności aplikacji
cd app && pytest -q && cd ..                        # 6 testów ma przejść
```

Pełna instrukcja: [`setup/README.md`](setup/README.md).

**Pracujesz we własnej kopii repozytorium** — w niej uruchamiasz GitHub Actions i ustawiasz
zmienne (lab02, lab03, lab06). Jak ją założyć, opisuje `setup/README.md`, punkt 1.

## Ćwiczenia

| Blok | Ćwiczenia |
|---|---|
| IaC i walidacja | [`lab01`](labs/lab01-walidacja-i-fix/) |
| GitHub Actions i koszty | [`lab02`](labs/lab02-workflow-z-ai/) · [`lab03`](labs/lab03-cost-caps/) |
| Code review z AI | [`lab04`](labs/lab04-cline-jako-recenzent/) · [`lab05`](labs/lab05-spot-the-ai-mistake/) |
| Sekrety i governance | [`lab06`](labs/lab06-vault-w-pipeline/) |
| Deploy, rollback i feature flags | [`lab07`](labs/lab07-canary-i-rollback/) · [`lab08`](labs/lab08-feature-flag-z-promptu/) |
| Guardrails i monitoring | [`lab09`](labs/lab09-llm-firewall/) · [`lab10`](labs/lab10-hpa-budzet-dashboard/) |
| Capstone | [`lab11`](labs/lab11-capstone/) |

Każdy lab zawiera własny `README.md` i katalog `start/`. Rozwiązania omawia prowadzący
po zakończeniu ćwiczenia; nie są częścią repozytorium uczestników.

## Najważniejsze katalogi

```text
app/        aplikacja quotes-api i manifesty Kubernetes
infra/      moduły Terraform używane w ćwiczeniach
labs/       zadania i pliki startowe
prompts/    gotowe prompty do kolejnych bloków
scripts/    walidacja, obciążenie i one-button deploy
docs/       ściągawka, TCO i opis pracy z Claude Code
setup/      przygotowanie laptopa uczestnika
.claude/    reguły, komendy, agenci i hook bezpieczeństwa
.clinerules/ kontekst repozytorium dla Cline
```

## Zasada pracy

AI proponuje zmianę. Człowiek ją rozumie, a deterministyczne narzędzia ją weryfikują:

```text
prompt → diff → fmt/validate/test/scan → plan → decyzja człowieka
```

Ściągawka z komendami: [`docs/sciagawka.md`](docs/sciagawka.md).

