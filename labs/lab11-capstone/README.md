# Lab 11 — capstone

**Blok 6 · 2,5 godziny**

Wszystko z obu dni w jednym przebiegu. Pracujesz samodzielnie, prowadzący asystuje.

---

## Etap 1 — one-button deploy (60 min)

### Zadanie

Doprowadź aplikację `quotes-api` w wersji `v2` do swojego namespace'u, przez pełną ścieżkę:
infrastruktura → obraz → skan → wdrożenie canary → obserwacja.

```bash
cd "$(git rev-parse --show-toplevel)"
set -a; source .env; set +a
export NS=$UCZESTNIK
./scripts/deploy.sh $NS v2
```

Obraz trafia do wspólnego ECR z tagiem `<uczestnik>-v2`, np. `anna-k-v2` — tak nikt
nie nadpisze cudzej wersji. Jeśli w lab07 nie wdrażałeś aplikacji, skrypt utworzy ją od zera.

### Zanim klikniesz

Przeczytaj `scripts/deploy.sh`. Znajdź dwa miejsca, w których skrypt
**pyta zamiast działać**, i odpowiedz sobie, dlaczego akurat tam.

### Co ma być na koniec

- [ ] `terraform apply` wykonany świadomie, po obejrzeniu planu
- [ ] obraz `v2` w ECR, przeskanowany
- [ ] rollout w stanie canary, ruch podzielony
- [ ] dashboard w Grafanie pokazuje obie wersje osobno
- [ ] **canary NIE wypromowane do 100%** — decyzja należy do Ciebie i podejmujesz ją
      po spojrzeniu na wykresy, nie przed

---

## Etap 2 — incydent (60 min)

W pewnym momencie aplikacja przestanie działać. **Nie wiesz, co się stało** — i o to chodzi.

### Zadanie

Zdiagnozuj i przywróć działanie.

### Zasady

1. **Zbierz fakty, zanim postawisz hipotezę.** Events, `describe`, logi poprzedniej
   instancji, stan rollouta, metryki
2. **Każdą hipotezę potwierdź konkretnym poleceniem.** Zapisz, którym
3. Dopiero potem naprawiaj

Prompt do diagnozy: `prompts/blok6-capstone.md`, etap 2.

### Pułapka, w którą wpada większość

Poproszony o diagnozę **bez podanych logów**, agent wymyśli prawdopodobną przyczynę
i będzie brzmiał przekonująco. Sprawdź to na sobie: zapytaj najpierw „dlaczego aplikacja
nie działa?", a potem to samo z załączonymi danymi. Porównaj odpowiedzi.

### Co ma być na koniec

- [ ] przyczyna źródłowa ustalona i **potwierdzona** konkretnym wyjściem komendy
- [ ] aplikacja działa
- [ ] zapisana ścieżka diagnostyczna: co sprawdziłeś, w jakiej kolejności, co to wykluczyło

---

## Etap 3 — post-mortem (30 min)

### Zadanie

```bash
claude
/postmortem $NS
```

### Potem — i to jest właściwe ćwiczenie

Przeczytaj wygenerowany raport i **znajdź w nim co najmniej jedno zdanie, którego agent
nie mógł wiedzieć z zebranych danych.**

Szukaj sformułowań w rodzaju „zmiana została wprowadzona podczas planowego wdrożenia",
„problem dotknął około 15% użytkowników", „zespół został powiadomiony o 14:32".
Brzmią wiarygodnie. Sprawdź, czy którakolwiek z tych liczb ma pokrycie w logach.

Jeśli nie znajdziesz nic — tym lepiej. Ale sprawdź świadomie, nie na wiarę.

### Co ma być na koniec

- [ ] post-mortem z osią czasu opartą na rzeczywistych znacznikach z logów
- [ ] lista zdań bez pokrycia w danych (albo notatka, że takich nie ma)
- [ ] dwa–trzy działania naprawcze, konkretne, z właścicielem

---

## Etap 4 — TCO (30 min)

### Zadanie

```bash
/tco
```

Policz, ile kosztuje to, co zbudowałeś przez dwa dni — infrastruktura plus tokeny AI.
Szablon i założenia: `docs/tco.md`.

### Pytanie, na które odpowiadasz na koniec

**Przy jakiej liczbie pull requestów dziennie koszt recenzji AI przekracza koszt klastra?**

Policz to dla swojego zespołu, z prawdziwą liczbą PR.

### Co ma być na koniec

- [ ] koszt infrastruktury za 8 godzin, z cenami jednostkowymi
- [ ] koszt miesięczny pipeline'u z AI, z jawnymi założeniami
- [ ] próg, powyżej którego tokeny kosztują więcej niż infrastruktura

---

## Czego się spodziewać

Etapy 1 i 2 zajmują tyle czasu, ile mają — nie da się ich przyspieszyć, bo klaster
i chmura reagują we własnym tempie. Etapy 3 i 4 idą szybko, ale są tym, co zostaje
w głowie po szkoleniu.

Jeśli utkniesz na etapie 1 i zabraknie czasu, przejdź do etapu 2 na środowisku prowadzącego.
Diagnostyka i post-mortem są ważniejsze niż dokończenie wdrożenia.
