---
description: Recenzja zmian w Terraform okiem cloud security engineera
---

Zrecenzuj zmiany w Terraform z bieżącego brancha (`git diff main...HEAD -- '*.tf'`).

Sprawdź kolejno i dla każdego punktu napisz, czy jest OK, czy nie — bez pomijania:

1. **Ekspozycja sieciowa** — czy pojawia się `0.0.0.0/0` na porcie innym niż 443, czy zasób dostaje publiczny IP
2. **Szyfrowanie i dostęp** — bucket S3 bez `server_side_encryption`, bez `public_access_block`, bez wersjonowania
3. **IAM** — `Action: "*"` albo `Resource: "*"`, role szersze niż wynika z użycia
4. **Konwencje repo** — nazewnictwo i tagi z `.claude/CLAUDE.md`, `description` i `type` przy zmiennych
5. **Trwałość stanu** — zmiany wymuszające `destroy`/`create` na zasobie z danymi

Format odpowiedzi: dla każdego znaleziska jedna linia `plik:linia — problem — co zrobić`.
Na końcu jedno zdanie werdyktu: czy to nadaje się do apply.

Nie proponuj `#checkov:skip` ani innych wyciszeń skanera.
