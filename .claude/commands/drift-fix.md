---
description: Wykryj drift i przygotuj poprawkę jako PR
---

Katalog Terraform: $1 (domyślnie `infra/modules/app-storage`).
Uczestnik: $2 — wartość zmiennej `uczestnik`, taka sama jak przy `terraform apply`,
którym powstała infrastruktura (moduł jej wymaga, nie ma defaultu).

1. Uruchom `terraform plan -var="uczestnik=$2" -detailed-exitcode -refresh-only` i pokaż mi surowy wynik
2. Wyjaśnij po polsku, **co konkretnie** zmieniło się poza Terraformem: który zasób, które pole, z czego na co
3. Rozstrzygnij, która strona ma rację:
   - zmiana w chmurze była potrzebna → zaktualizuj kod, żeby ją odzwierciedlał
   - zmiana była przypadkowa albo niebezpieczna → zostaw kod, przygotuj cofnięcie zmiany
   Napisz wprost, którą opcję wybierasz i dlaczego
4. Przygotuj branch `fix/drift-<zasob>`, nanieś poprawkę, uruchom `terraform plan -var="uczestnik=$2"` i pokaż, że plan jest czysty
5. Otwórz PR przez `gh pr create` z opisem: co driftowało, kiedy, jaka decyzja i jak zapobiec powtórce

Nie rób `apply`. Kończysz na otwartym PR.
