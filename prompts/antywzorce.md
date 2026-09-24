# Prompty, które wyglądają dobrze, a dają zły kod

Materiał do Bloku 1 (slajd o prompt engineeringu) i do dyskusji w Bloku 3.
Każdy przykład jest realny — nie wymyślony na potrzeby slajdu.

---

## 1. Przymiotnik zamiast wymagania

**Źle:**
```
Napisz bezpieczny moduł Terraform dla bucketu S3.
```

„Bezpieczny" nie jest wymaganiem, tylko oceną. Model uzupełni to własną interpretacją,
która bywa poprawna — i nie dowiesz się, kiedy nie była.

**Lepiej:**
```
Napisz moduł Terraform dla bucketu S3: szyfrowanie SSE-KMS własnym kluczem,
blokada całego dostępu publicznego, wersjonowanie włączone, polityka cyklu życia
przenosząca obiekty starsze niż 30 dni do klasy IA.
```

---

## 2. Prośba o „poprawienie" bez wskazania problemu

**Źle:**
```
Popraw ten pipeline.
```

Agent poprawi to, co sam uzna za problem — najczęściej formatowanie i nazwy jobów,
czyli rzeczy najmniej istotne.

**Lepiej:**
```
Ten pipeline zużywa 40 minut runnera na push. Obetnij poniżej 8 minut.
Nie usuwaj żadnego kroku. Przy każdej zmianie napisz, ile minut oszczędza.
```

---

## 3. Uciszenie skanera zamiast naprawy

**Źle:**
```
Checkov zgłasza 12 błędów w tym module. Spraw, żeby przechodził.
```

To prośba o zielony wynik, nie o bezpieczny kod. Najszybszą drogą do spełnienia jej
jest dopisanie `#checkov:skip` w dwunastu miejscach — i agent to zrobi.

**Lepiej:**
```
Checkov zgłasza 12 błędów w tym module. Dla każdego napisz, czym grozi konkretnie,
a potem napraw przyczynę w kodzie. Jeśli uważasz, że któreś zgłoszenie jest fałszywie
pozytywne, uzasadnij to osobno — sam nie dodawaj wyciszeń.
```

---

## 4. Zgoda na apply schowana w treści promptu

**Źle:**
```
Postaw mi to środowisko i daj znać, jak będzie gotowe.
```

Wersja „zrób wszystko" zdejmuje z Ciebie moment decyzji — ten sam moment, w którym
zobaczyłbyś, że plan usuwa bazę danych.

**Lepiej:**
```
Przygotuj to środowisko. Zatrzymaj się po terraform plan i pokaż mi go.
Apply wykonasz dopiero, gdy potwierdzę.
```

---

## 5. Pytanie, na które jedyną dopuszczalną odpowiedzią jest „tak"

**Źle:**
```
Czy ten kod jest już gotowy do wdrożenia na produkcję?
```

Model dopasowuje się do oczekiwania zawartego w pytaniu.

**Lepiej:**
```
Wymień wszystko, co musi być spełnione, żeby ten kod mógł trafić na produkcję.
Przy każdym punkcie oznacz, czy jest spełniony, czy nie, i na jakiej podstawie to wiesz.
```

---

## 6. Sekret w kontekście „bo inaczej nie zadziała"

**Źle:**
```
Oto mój connection string do bazy produkcyjnej, napraw zapytanie:
postgresql://admin:P@ssw0rd@prod-db.wewnetrzny:5432/klienci
```

Wartość nie była potrzebna do naprawienia zapytania. Trafiła do kontekstu,
bo wkleiło się cały wiersz z konfiguracji.

**Lepiej:**
```
Napraw to zapytanie. Connection string pobieram z Vaulta w czasie działania,
w kodzie jest jako zmienna DATABASE_URL.
```

---

## 7. Kontekst, którego nie ma

**Źle:**
```
Dodaj obsługę nowego providera zgodnie z naszymi standardami.
```

„Nasze standardy" istnieją w głowie autora promptu, nie w kontekście agenta.

**Lepiej:** zapisz standardy raz, w `CLAUDE.md` albo `.clinerules`, i odwołuj się do nich.
To jest cały mechanizm — reszta to konsekwencja.
