# Lab 08 — flaga z jednego zdania

**Blok 4 · 20 minut**

## Zadanie

Wygeneruj promptem konfigurację feature-flagi i włącz nową funkcję dla części ruchu —
bez wdrażania czegokolwiek.

### Etap 1 — stan wyjściowy (3 min)

```bash
curl -s $ADRES/api/quote
```

Odpowiedź ma jedno pole. Kod nowego formatu **jest już wdrożony** — flaga jest wyłączona.

### Etap 2 — prompt (10 min)

Poproś agenta o konfigurację flagd dla takiej reguły:

> Nowy format odpowiedzi endpointu `/api/quote` ma być widoczny dla 20% ruchu,
> a dodatkowo zawsze dla żądań z nagłówkiem `X-Beta: true`.

Gotowy prompt: `prompts/blok4-deploy.md`, sekcja „Feature-flaga z opisu w naturalnym języku".

### Etap 3 — wdrożenie flagi (7 min)

```bash
kubectl -n flagd create configmap flagd-config \
  --from-file=flags.json=./flags.json \
  --dry-run=client -o yaml | kubectl apply -f -
```

Sprawdź:

```bash
for i in $(seq 1 20); do curl -s $ADRES/api/quote | head -c 50; echo; done
curl -s -H "X-Beta: true" $ADRES/api/quote
```

## Podpowiedzi

<details>
<summary>Podpowiedź 1 — agent generuje składnię innego dostawcy</summary>

Podaj schemat wprost: „format flagd, schema `flagd.dev/schema/v0/flags.json`,
z blokiem `targeting` używającym JsonLogic".
</details>

<details>
<summary>Podpowiedź 2 — proporcja nie wychodzi 20/80</summary>

Operator `fractional` przyjmuje wagi jako pary `["wariant", liczba]`.
Sprawdź, czy wagi sumują się do 100 i czy pierwszy argument to klucz,
po którym rozdzielasz ruch.
</details>

<details>
<summary>Podpowiedź 3 — funkcja miga przy odświeżaniu</summary>

To znaczy, że podział jest losowy zamiast deterministycznego. `fractional` powinien
rozdzielać po stałej wartości (np. kluczu flagi albo identyfikatorze użytkownika),
żeby ten sam odbiorca zawsze trafiał do tej samej grupy.

Poproś agenta wprost: „podział ma być deterministyczny, ten sam użytkownik zawsze
w tej samej grupie".
</details>

## Weryfikacja

Na dwudziestu żądaniach nowy format powinien pojawić się kilka razy, a z nagłówkiem
`X-Beta: true` — zawsze. Prowadzący pokaże wersję referencyjną po ćwiczeniu.

## Pułapki

**Podział losowy zamiast deterministycznego.** Funkcja włączająca się i wyłączająca
przy każdym odświeżeniu to gorsze doświadczenie niż jej brak.

**Flaga bez daty usunięcia.** Flaga wisząca rok na 100% to martwy kod plus rozgałęzienie
w każdym teście. Zapisz datę usunięcia razem z datą dodania — to jedyny moment,
w którym ktokolwiek o tym pamięta.

**Flaga zamiast uprawnień.** Flaga decyduje, *czy* funkcja jest widoczna, a nie
*kto ma prawo* jej użyć. Sterowanie dostępem do danych flagą to luka, nie funkcja.
