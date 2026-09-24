# Blok 3 — Code review z AI

## Cline jako recenzent (checklista + anty-patterny)

```
Zrecenzuj zmiany na tym branchu względem main. Trzymaj się formatu z .clinerules.

Najpierw przeczytaj cały diff, dopiero potem zacznij komentować.

Dla każdego znaleziska podaj wagę (BLOKUJĄCE / WAŻNE / DROBIAZG), plik i linię,
problem w jednym zdaniu, scenariusz, w którym to wybucha, i konkretną poprawkę.

Nie zgłaszaj znaleziska, do którego nie umiesz napisać scenariusza.
```

## Claude jako drugi recenzent

Uruchamiamy po Cline, na tym samym PR — pointa polega na porównaniu, co każdy złapał.

```
/pr-review
```

albo bez skrótu:

```
Jesteś drugim recenzentem tego PR — pierwszy już przeszedł i czegoś nie zauważył.
Zrecenzuj w trzech osobnych przebiegach, nie mieszaj ich:

1. poprawność — czy kod robi to, co obiecuje opis PR, jakie przypadki brzegowe pominięto
2. bezpieczeństwo — sekrety, uprawnienia, dane w logach, składanie zapytań ze stringów
3. złożoność i wydajność — zapytania w pętli, operacje kwadratowe na rosnących danych

Na końcu: APROBATA albo DO POPRAWY z listą rzeczy blokujących.
```

## Prompt do specjalistycznego przeglądu

Kiedy chcesz konkretnej perspektywy, a nie „ogólnej recenzji":

```
Przejrzyj ten PR wyłącznie jako cloud security engineer. Ignoruj styl, nazewnictwo
i architekturę. Interesuje mnie jedno: czy po zmergowaniu tego zwiększa się
powierzchnia ataku, a jeśli tak, to gdzie konkretnie.
```

## Komentarz w PR z pipeline'u

Prompt używany przez job recenzujący pull request:

```
Zrecenzuj załączony diff. Odpowiedz w Markdownie gotowym do wklejenia jako komentarz
w pull requeście:

- nagłówek z jednozdaniowym werdyktem
- maksymalnie 5 najpoważniejszych znalezisk, każde jako lista: plik:linia, problem, poprawka
- jeśli nie ma nic poważnego, napisz krótko, że nie ma — nie wypełniaj miejsca uwagami stylistycznymi

Nie komentuj plików wygenerowanych, blokad zależności ani zmian w dokumentacji.
```

## Do labu „spot the AI mistake"

Ten prompt dostają uczestnicy — a potem sprawdzamy, ile z trzech błędów agent faktycznie znalazł:

```
W tym PR są trzy celowo wprowadzone błędy: jeden bezpieczeństwa, jeden wydajnościowy,
jeden stylistyczny. Znajdź je wszystkie i dla każdego napisz, do której kategorii należy.
```
