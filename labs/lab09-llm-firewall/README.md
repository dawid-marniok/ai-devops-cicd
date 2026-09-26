# Lab 09 — własna reguła guardrail

**Blok 5 · 20 minut**

## Zadanie

Dołóż do strażnika promptów regułę, która zatrzyma coś, czego domyślne skanery nie łapią.

Zależności (~1 GB) instalowałeś przed dniem 2 (`setup/README.md`, punkt 7). Jeśli nie:

```bash
cd labs/lab09-llm-firewall/start
python3 -m venv ../.venv
../.venv/bin/pip install -r requirements.txt
source ../.venv/bin/activate
```

Skrypt wypisuje sporo linii logu biblioteki (`[debug]`, `[info]`). Liczy się ostatni
komunikat — `ODRZUCONE…` albo `Przepuszczone.` — i kod wyjścia.

### Etap 1 — zobacz, gdzie jest granica (5 min)

```bash
python straznik.py "Popraw workflow. Klucz: AKIAIOSFODNN7EXAMPLE"
python straznik.py "Wdróż na konto 123456789012 z rolą arn:aws:iam::123456789012:role/prod-admin"
```

Pierwszy zostaje odrzucony. Drugi przechodzi — a zawiera identyfikator konta produkcyjnego
i nazwę roli administracyjnej.

### Etap 2 — dopisz regułę (10 min)

Dodaj do listy `WZORCE` w `straznik.py` wzorzec, który zatrzyma ARN-y i identyfikatory kont AWS.

Możesz poprosić o pomoc agenta — ale **sprawdź wynik na obu promptach powyżej i na trzech
własnych**, które powinny przejść.

### Etap 3 — sprawdź, czego nie złapałeś (5 min)

Zapytaj agenta wprost:

```
Wyjaśnij, czego ten filtr NIE złapie. Podaj trzy konkretne przykłady promptów,
które przejdą, a nie powinny.
```

Zapisz odpowiedź. To jest właściwy produkt tego labu — nie sama reguła.

## Podpowiedzi

<details>
<summary>Podpowiedź 1 — jak wygląda ARN i identyfikator konta</summary>

Konto to dokładnie 12 cyfr. ARN zaczyna się od `arn:aws:` i ma stałą liczbę pól
rozdzielonych dwukropkiem.

Uwaga na fałszywe trafienia: 12 cyfr pod rząd to również numer telefonu z prefiksem,
numer faktury i połowa identyfikatorów w każdym systemie. Zawęź kontekst.
</details>

<details>
<summary>Podpowiedź 2 — reguła blokuje za dużo</summary>

Filtr, który odrzuca poprawne prompty, zostanie wyłączony w pierwszym tygodniu.
Lepsza jest reguła wąska i skuteczna niż szeroka i ignorowana.

Rozważ wymaganie kontekstu: `arn:aws:` przed identyfikatorem albo słowo `account`
w pobliżu.
</details>

<details>
<summary>Podpowiedź 3 — co z logowaniem</summary>

Przy odrzuceniu skrypt wypisuje nazwę skanera, nigdy treść promptu. Zastanów się,
dlaczego — i nie „popraw" tego, dopisując treść do komunikatu.
</details>

## Weryfikacja

```bash
python straznik.py "Wdróż na konto 123456789012" ; echo "kod wyjścia: $?"
python straznik.py "Napraw test w app/tests/test_main.py" ; echo "kod wyjścia: $?"
```

Pierwszy ma zwrócić 1, drugi 0.

## Pułapki

**Filtr promptów zamiast uprawnień.** Prompt „usuń wszystkie zasoby z tagiem Projekt"
przejdzie przez każdy rozsądny filtr — nie ma w nim sekretu ani ataku. Tym, co go zatrzymuje,
jest lista `ask` w `.claude/settings.json`, a nie strażnik.

**Logowanie odrzuconej treści.** Kuszące przy debugowaniu. Oznacza przeniesienie sekretu
z promptu do logów CI, gdzie zostaje na 90 dni i jest widoczny dla większej liczby osób.

**Wiara w kompletność listy wzorców.** Twoje wewnętrzne tokeny nie pasują do żadnego
publicznego wzorca. Lista wzorców łapie pomyłki, nie determinację.

**Pośrednie prompt injection.** Agent czyta plik z repozytorium, a instrukcja siedzi
w tym pliku. Treść nigdy nie przechodzi przez filtr wejściowy, bo nie jest wejściem.
To jest najtrudniejszy przypadek i nie rozwiązuje go żaden skaner promptów.
