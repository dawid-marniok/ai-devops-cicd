# Biblioteka promptów

Nie przepisuj promptów ze slajdów — skopiuj je stąd. Każdy plik odpowiada jednemu blokowi.

| Plik | Blok |
|---|---|
| [`blok1-iac.md`](blok1-iac.md) | Generowanie i walidacja Terraform, drift |
| [`blok2-pipeline.md`](blok2-pipeline.md) | GitHub Actions, koszty, promocja buildów |
| [`blok3-review.md`](blok3-review.md) | Code review z Cline i Claude |
| [`blokx-sekrety.md`](blokx-sekrety.md) | Vault, policy-as-code |
| [`blok4-deploy.md`](blok4-deploy.md) | Canary, rollback, feature-flagi |
| [`blok5-guardrails.md`](blok5-guardrails.md) | LLM-firewall, HPA, observability |
| [`blok6-capstone.md`](blok6-capstone.md) | Ćwiczenie końcowe |
| [`antywzorce.md`](antywzorce.md) | Prompty, które wyglądają dobrze, a dają zły kod |

## Trzy zasady, które przewijają się przez wszystkie bloki

**1. Kontekst zamiast przymiotników.** „Napisz bezpieczny moduł Terraform" nie znaczy nic.
„Napisz moduł zgodny z konwencjami z `.claude/CLAUDE.md`, provider AWS, region eu-central-1,
bucket z szyfrowaniem i blokadą dostępu publicznego" — znaczy.

**2. Iteracja zamiast jednego idealnego promptu.** Pierwsza odpowiedź to szkic. Drugi prompt
(„uruchom na tym tflint i popraw to, co zgłosi") daje więcej niż dwa akapity wymagań na starcie.

**3. Review przed apply.** Zawsze. Agent nie odpowiada za Twoją produkcję.
