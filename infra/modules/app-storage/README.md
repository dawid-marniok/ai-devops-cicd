# Moduł `app-storage` — wersja referencyjna

Infrastruktura pod aplikację `quotes-api`: bucket na artefakty, sieć i security group.

To jest **wzorzec**, do którego porównujemy wyniki generowania z AI (Blok 1) i rozwiązania
z labu 01. Nie ma tu żadnych celowych błędów — te są w `../app-storage-bledny/`.

## Użycie

```hcl
module "app_storage" {
  source     = "../../modules/app-storage"
  uczestnik  = "anna-k"
  blok       = "b1"
}
```

## Wejście

| Zmienna | Typ | Domyślna | Opis |
|---|---|---|---|
| `uczestnik` | string | — | Identyfikator uczestnika, wchodzi w nazwy zasobów |
| `blok` | string | `"b1"` | Numer bloku szkolenia, do tagów |
| `region` | string | `"eu-central-1"` | Region AWS |
| `cidr_vpc` | string | `"10.20.0.0/16"` | Zakres adresów VPC |

## Wyjście

| Wyjście | Opis |
|---|---|
| `bucket_name` | Nazwa bucketu na artefakty |
| `vpc_id` | ID utworzonej VPC |
| `security_group_id` | ID security group aplikacji |

## Co ten moduł robi dobrze — i dlaczego

- **Bucket ma szyfrowanie i blokadę dostępu publicznego.** Domyślne ustawienia AWS nie
  wystarczają; `aws_s3_bucket_public_access_block` musi być zasobem jawnym.
- **Security group wpuszcza tylko 443.** Port 22 z internetu nie jest potrzebny do niczego,
  co robimy na szkoleniu.
- **Reguły egress są zawężone.** Domyślny `0.0.0.0/0` na wyjściu przechodzi przez skanery,
  ale ułatwia wyprowadzenie danych.
- **Wszystkie zasoby mają komplet tagów.** `Usuwac = tak` pozwala prowadzącemu znaleźć
  zapomniane zasoby podczas sprzątania konta szkoleniowego.

## Cztery zgłoszenia, które tu zostają — i dlaczego

Ten moduł **nie przechodzi skanerów na zero**. To nie jest niedopatrzenie, tylko materiał
do Bloku 1: zielony wynik skanera nie jest celem, celem jest świadoma decyzja przy każdym
zgłoszeniu.

| Zgłoszenie | Decyzja |
|---|---|
| `AVD-AWS-0104` — nieograniczony ruch wychodzący | **Zostaje.** Aplikacja musi sięgać do ECR i API AWS. Zawęziliśmy port do 443; zawężenie adresów wymagałoby VPC Endpoints, co na koncie szkoleniowym kosztuje więcej, niż daje. W projekcie produkcyjnym: endpointy zamiast IGW. |
| `AVD-AWS-0132` — brak klucza zarządzanego przez klienta | **Zostaje.** SSE-S3 wystarcza dla artefaktów buildów, które i tak wygasają po 30 dniach. CMK ma sens tam, gdzie potrzebujesz własnej rotacji i audytu użycia klucza. |
| `AVD-AWS-0178` — brak VPC Flow Logs | **Zostaje.** Flow logs wymagają grupy CloudWatch i roli IAM, a płaci się za każdy zapisany gigabajt. Na środowisku żyjącym dwa dni to koszt bez zwrotu. Na produkcji — włącz. |
| `AVD-AWS-0090` (w wariancie bez wersjonowania) | **Naprawione.** Wersjonowanie jest włączone — to jedyna rzecz, która ratuje po przypadkowym nadpisaniu artefaktu. |

Różnica między tą tabelą a dopisaniem `#checkov:skip` w czterech miejscach jest taka,
że tutaj decyzja jest zapisana razem z uzasadnieniem i da się ją zakwestionować przy
następnym przeglądzie. Wyciszenie w kodzie znika z pola widzenia po tygodniu.

## Zarejestrowany drift — SSH otwarty ręcznie na `security_group.aplikacja`

**2026-09-24**, uczestnik `prowadzacy`: `terraform plan -refresh-only` wykrył regułę
ingress TCP/22 z `0.0.0.0/0` na security group aplikacji (`sgr-055f50b14701f2d60`),
której nie ma w tym module. CloudTrail potwierdza `AuthorizeSecurityGroupIngress`
wykonane ręcznie przez AWS CLI (nie przez Terraform) o 09:10:27 CEST.

**Decyzja: zmiana przypadkowa/niebezpieczna, kod zostaje bez zmian.** Ten moduł
świadomie nie wystawia SSH z internetu (patrz tabela wyżej) — reguła narusza tę
zasadę i konwencję z `.claude/CLAUDE.md` (żaden port poza 443 nie może mieć
`0.0.0.0/0`). Nie adaptujemy jej do kodu.

**Dlaczego zwykły `terraform plan` tego nie pokaże:** ten moduł zarządza regułami
security group przez osobne zasoby (`aws_vpc_security_group_ingress_rule`), zgodnie
z zaleceniami providera `hashicorp/aws` — `aws_security_group.aplikacja` nie ma
inline `ingress`/`egress`. To poprawny wzorzec, ale ma efekt uboczny: reguła dodana
poza Terraformem nie jest pod jego zarządzaniem, więc zwykły plan zwraca "No
changes", nawet gdy w chmurze wisi otwarty port. Widać ją wyłącznie przez
`-refresh-only`, w computed atrybutach `aws_security_group`.

**Cofnięcie zmiany** — Terraform nie może tego zrobić za nas (nigdy nie zarządzał tą
regułą), więc wymaga ręcznej akcji poza Terraformem:

```
aws ec2 revoke-security-group-ingress \
  --group-id sg-0701410caf0b895d5 \
  --security-group-rule-ids sgr-055f50b14701f2d60
```

**Jak zapobiec powtórce:** dostęp do modyfikacji security groups na koncie
szkoleniowym powinien iść wyłącznie przez pipeline (OIDC), nie przez interaktywne
AWS CLI uczestników/prowadzącego. Dodatkowo `terraform plan -refresh-only`
powinno wejść do cyklicznego joba w CI (np. raz dziennie), bo to jedyny sposób,
w jaki ten moduł w ogóle wykrywa tę klasę driftu.
