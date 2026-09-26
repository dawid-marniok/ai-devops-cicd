# Lab 05 — spot the AI mistake

**Blok 3 · 25 minut**

## Sytuacja

Kolega z zespołu wygenerował nową funkcję asystentem AI, przejrzał ją pobieżnie i wystawił
jako PR #47. Kod działa, testy przechodzą, opis PR jest sensowny.

Jesteś recenzentem.

## Zadanie

W `start/` jest opis PR (`PR-opis.md`) i dwa zmienione pliki: `iam-ranking.tf` i `ranking.py`.
Rejestrację endpointu w `app/main.py` pomijamy — to jedna linijka bez znaczenia dla zadania.
Kod to fragment większego modułu, więc `terraform validate` na nim nie zadziała — czytasz go
jak diff w PR. Pliki zawierają **trzy celowo wprowadzone błędy**: jeden bezpieczeństwa, jeden wydajnościowy, jeden stylistyczny.

Zadanie ma dwie części — zrób je w tej kolejności, nie na odwrót.

### Część A — recenzja przez AI (10 min)

Poproś Cline albo Claude o recenzję tego PR. Zacznij od **ogólnego** promptu:

```
Zrecenzuj ten pull request.
```

Zapisz, co znalazł. Nie podpowiadaj mu na tym etapie.

### Część B — recenzja własna (10 min)

Teraz przeczytaj kod sam. Znajdź to, czego agent nie zgłosił.

Na koniec porównajcie w grupie: **ile osób znalazło błąd, którego nie znalazł ich agent?**

## Podpowiedzi

<details>
<summary>Podpowiedź 1 — gdzie w ogóle patrzeć</summary>

Dwa pliki, trzy różne rodzaje problemu:

- `iam-ranking.tf` — jaki dokładnie dostęp dostaje aplikacja i do czego
- `ranking.py` — co się stanie, gdy lista cytatów urośnie do tysiąca pozycji
- `ranking.py` — coś, co po prostu odstaje od reszty kodu
</details>

<details>
<summary>Podpowiedź 2 — polityka IAM</summary>

Polityka ma dwa bloki `Statement`. Pierwszy jest wzorowy.

Drugi ma `Resource = "*"` — i to **samo w sobie nie jest błędem**, bo `dynamodb:ListTables`
faktycznie działa na poziomie konta i inaczej się go nie zapisze.

Przeczytaj listę akcji w tym drugim bloku pozycja po pozycji. Czy każda z nich naprawdę
dotyczy metadanych?
</details>

<details>
<summary>Podpowiedź 3 — wydajność</summary>

Prześledź, ile razy `zbuduj_ranking` odpytuje DynamoDB przy czterech cytatach.
Potem przy tysiącu.

Dodatkowo: gdzie tworzony jest obiekt `dynamo.Table(...)`?
</details>

## Weryfikacja

Klucz odpowiedzi oraz dwa prompty porównawcze pokaże prowadzący po zakończeniu obu części.
Różnica w wynikach jest tym, co warto zabrać z tego ćwiczenia.

## Pułapki

**Zaufanie do pustej listy.** „Agent nie zgłosił niczego poważnego" znaczy tylko tyle,
że nie zgłosił. W tym PR jest luka pozwalająca aplikacji do wyświetlania cytatów
czytać dane z całego konta.

**Zatrzymanie się na pierwszym znalezisku.** Agent chętnie raportuje błąd stylistyczny
i przechodzi dalej. Poproś wprost o **wszystkie trzy kategorie**, osobno.

**Recenzja fragmentu zamiast całości.** Błąd wydajnościowy widać dopiero, gdy połączysz
pętlę w `zbuduj_ranking` z tym, co robi `pobierz_licznik`. Każda z tych funkcji osobno
wygląda poprawnie — bo osobno jest poprawna.
