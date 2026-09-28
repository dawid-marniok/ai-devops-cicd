# Moduł `app-storage`

Infrastruktura wspierająca aplikację `quotes-api`:

- bucket S3 na artefakty buildów (szyfrowanie AES256, zablokowany dostęp publiczny, wersjonowanie włączone)
- VPC z jedną podsiecią publiczną i jedną podsiecią prywatną
- security group aplikacji dopuszczający wyłącznie ruch HTTPS (443)

Konwencje nazewnictwa, tagowania i zmiennych opisane są w `.claude/CLAUDE.md`.

## Podsieć prywatna

Podsieć prywatna nie ma trasy do internetu (brak NAT Gateway) — moduł w obecnym
zakresie nie wymaga ruchu wychodzącego z tej podsieci. Dodanie NAT Gateway to
świadoma decyzja kosztowa, do podjęcia osobno, jeśli pojawi się taka potrzeba.

## Użycie

```hcl
module "app_storage" {
  source = "../../modules/app-storage"

  uczestnik = "dawid"
  blok      = "b1"
}
```

## Wymagania

| Nazwa | Wersja |
|---|---|
| terraform | >= 1.9 |
| aws | ~> 5.80 |

## Zmienne wejściowe

| Nazwa | Opis | Typ | Domyślnie |
|---|---|---|---|
| `uczestnik` | Identyfikator uczestnika szkolenia | `string` | — (wymagane) |
| `blok` | Identyfikator bloku szkoleniowego | `string` | `"b1"` |
| `cidr_vpc` | Zakres CIDR dla VPC | `string` | `"10.20.0.0/16"` |
| `cidr_subnet_publiczna` | Zakres CIDR dla podsieci publicznej | `string` | `"10.20.1.0/24"` |
| `cidr_subnet_prywatna` | Zakres CIDR dla podsieci prywatnej | `string` | `"10.20.2.0/24"` |

## Wyjścia

| Nazwa | Opis |
|---|---|
| `bucket_name` | Nazwa bucketu S3 na artefakty buildów |
| `bucket_arn` | ARN bucketu S3 na artefakty buildów |
| `vpc_id` | ID utworzonej VPC |
| `subnet_publiczna_id` | ID podsieci publicznej |
| `subnet_prywatna_id` | ID podsieci prywatnej |
| `security_group_id` | ID security group aplikacji |
