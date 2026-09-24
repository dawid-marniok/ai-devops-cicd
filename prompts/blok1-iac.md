# Blok 1 — Infrastructure as Code

## Demo: ten sam prompt w dwóch narzędziach

Ten prompt wklejamy najpierw do Claude Code, potem do Cline. Celowo identyczny —
porównujemy sposób pracy, nie jakość instrukcji.

```
Napisz moduł Terraform w infra/modules/app-storage, który tworzy infrastrukturę
pod aplikację quotes-api:

- bucket S3 na artefakty buildów
- VPC z jedną podsiecią publiczną i jedną prywatną
- security group dla aplikacji, ruch HTTPS z internetu i nic więcej

Trzymaj się konwencji nazewnictwa i tagowania z CLAUDE.md. Zmienne mają mieć
description i jawny type. Nie uruchamiaj apply — skończ na terraform validate.
```

**Na co patrzeć w trakcie:** Claude Code sam iteruje po błędach walidacji. Cline pokazuje
diff każdego pliku i czeka na akceptację. To ta sama praca w dwóch trybach kontroli.

## Prompt kontrolny — ten sam moduł bez kontekstu

Do pokazania różnicy. Uruchom w katalogu bez `CLAUDE.md`:

```
Napisz moduł Terraform z bucketem S3 i VPC dla aplikacji.
```

Porównaj: nazewnictwo, tagi, szyfrowanie, zakres security group. To jest argument
za pisaniem `CLAUDE.md`, a nie za „lepszym modelem".

## Walidacja i naprawa

```
Uruchom kolejno na infra/modules/app-storage-bledny:
terraform validate, tflint, checkov -d ., trivy config .

Dla każdego zgłoszenia napisz:
- która warstwa je złapała (składnia / best practices / bezpieczeństwo)
- czym grozi konkretnie, jeśli to zostanie wdrożone
- jak to naprawić

Potem napraw. Nie używaj #checkov:skip ani innych wyciszeń — mam zobaczyć poprawki
w kodzie, nie w komentarzach.
```

## Drift

```
Ktoś zmienił konfigurację poza Terraformem.

1. Uruchom terraform plan -var="uczestnik=<Twój login>" -detailed-exitcode -refresh-only i pokaż mi surowy wynik
2. Wyjaśnij po polsku: który zasób, które pole, z czego na co
3. Oceń, czy ta zmiana była potrzebna, czy niebezpieczna — i uzasadnij
4. Przygotuj branch fix/drift-<zasob>, nanieś poprawkę, pokaż czysty plan (ta sama flaga -var)
5. Otwórz PR z opisem: co driftowało, jaka decyzja, jak zapobiec powtórce

Nie rób apply.
```

Skrót: `/drift-fix` (zdefiniowany w `.claude/commands/drift-fix.md`).

## Prompt do zrozumienia cudzego kodu

Przydaje się częściej niż generowanie:

```
Przeczytaj infra/modules/app-storage i wyjaśnij mi w pięciu zdaniach, co ten moduł
tworzy i co się stanie, jeśli zmienię zmienną `environment` z dev na prod.
Wskaż zasoby, które przy tej zmianie zostaną odtworzone od zera.
```
