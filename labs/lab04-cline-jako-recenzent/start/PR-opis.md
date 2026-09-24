# PR #52 — automatyczne wdrożenie z komentarza w issue

**Autor:** zespół platformowy

## Co robi

Dodaje możliwość wdrożenia gałęzi przez komentarz w issue. Wpisujesz `/deploy nazwa-galezi`,
bot buduje i wdraża.

Do tego poprawka Dockerfile — obraz schudł z 180 MB do 95 MB.

## Pliki

- `.github/workflows/deploy-from-comment.yml` — nowy workflow
- `Dockerfile` — zmiany optymalizacyjne
