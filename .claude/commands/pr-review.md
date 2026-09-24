---
description: Recenzja pull requesta jako drugi recenzent
---

PR do recenzji: $ARGUMENTS (numer PR albo bieżący branch).

Pobierz diff (`gh pr diff` albo `git diff main...HEAD`) i zrecenzuj w trzech przebiegach,
w tej kolejności — nie mieszaj ich ze sobą:

**Przebieg 1 — poprawność.** Czy kod robi to, co obiecuje opis PR? Szukaj przypadków
brzegowych, które autor pominął: puste wejście, brak uprawnień, timeout, równoległe wywołania.

**Przebieg 2 — bezpieczeństwo.** Sekrety w kodzie, uprawnienia szersze niż potrzeba,
dane użytkownika w logach, zapytania składane przez konkatenację stringów.

**Przebieg 3 — złożoność i wydajność.** Zapytania w pętli, operacje O(n²) na danych,
które będą rosnąć, funkcje, które robią więcej niż jedną rzecz.

Dla każdego znaleziska podaj: plik i linię, na czym polega problem, oraz **konkretny scenariusz**,
w którym to wybucha. Znalezisko bez scenariusza pomiń — to znaczy, że nie jesteś go pewien.

Na końcu: `APROBATA` albo `DO POPRAWY` z listą rzeczy blokujących.
