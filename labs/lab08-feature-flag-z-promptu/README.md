# Lab 08 — flaga z jednego zdania

**Blok 4 · 20 minut**

## Zadanie

Wygeneruj promptem konfigurację feature-flagi i włącz nową funkcję dla części ruchu —
bez wdrażania czegokolwiek.

Lab korzysta z aplikacji i flagd wdrożonych w lab07 w Twoim namespace. Polecenia uruchamiaj
z głównego katalogu repozytorium.

### Etap 1 — stan wyjściowy (3 min)

```bash
cd "$(git rev-parse --show-toplevel)"
set -a; source .env; set +a
export NS=$UCZESTNIK
export ADRES=http://$(kubectl -n $NS get ingress quotes-api -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -s $ADRES/api/quote
```

Odpowiedź ma jedno pole. Kod nowego formatu **jest już wdrożony** — flaga jest wyłączona.

Aplikacja przekazuje do flagd dwie informacje o żądaniu: nagłówek `X-Beta` jako atrybut `beta`
oraz nagłówek `X-User-Id` jako `targetingKey` — identyfikator odbiorcy, po którym dzieli się ruch.

### Etap 2 — prompt (10 min)

Poproś agenta o konfigurację flagd dla takiej reguły:

> Nowy format odpowiedzi endpointu `/api/quote` ma być widoczny dla 20% ruchu,
> a dodatkowo zawsze dla żądań z nagłówkiem `X-Beta: true`.

Gotowy prompt: `prompts/blok4-deploy.md`, sekcja „Feature-flaga z opisu w naturalnym języku".
Wynik zapisz w `labs/lab08-feature-flag-z-promptu/start/flags.json`.

### Etap 3 — wdrożenie flagi (7 min)

flagd działa w Twoim namespace — podmieniasz tylko jego ConfigMap, aplikacji nie ruszasz:

```bash
kubectl -n $NS create configmap flagd-config \
  --from-file=flags.json=labs/lab08-feature-flag-z-promptu/start/flags.json \
  --dry-run=client -o yaml | kubectl apply -n $NS -f -
```

Kubernetes dostarcza nowy plik do poda flagd z opóźnieniem — **odczekaj około minuty**.
Jeśli po dwóch minutach nic się nie zmienia: `kubectl -n $NS rollout restart deploy/flagd`.

Sprawdź — 20 różnych użytkowników, potem jeden użytkownik kilka razy, potem beta:

```bash
for i in $(seq 1 20); do curl -s -H "X-User-Id: user-$i" $ADRES/api/quote; echo; done
for i in 1 2 3 4 5; do curl -s -H "X-User-Id: user-7" $ADRES/api/quote; echo; done
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
rozdzielać po stałej wartości — identyfikatorze użytkownika (`targetingKey`), najlepiej
połączonym z kluczem flagi — żeby ten sam odbiorca zawsze trafiał do tej samej grupy.

Odwrotny objaw — **wszyscy** dostają to samo — oznacza, że dzielisz po wartości stałej
dla wszystkich żądań (np. samym kluczu flagi) albo nie wysyłasz `X-User-Id`.

Poproś agenta wprost: „podział ma być deterministyczny, ten sam użytkownik zawsze
w tej samej grupie".
</details>

## Weryfikacja

Na dwudziestu różnych użytkownikach nowy format powinien pojawić się kilka razy (przy 20%
spodziewaj się 2–6), ten sam użytkownik ma zawsze ten sam wynik, a z nagłówkiem
`X-Beta: true` nowy format pojawia się zawsze. Prowadzący pokaże wersję referencyjną po ćwiczeniu.

## Pułapki

**Podział losowy zamiast deterministycznego.** Funkcja włączająca się i wyłączająca
przy każdym odświeżeniu to gorsze doświadczenie niż jej brak.

**Flaga bez daty usunięcia.** Flaga wisząca rok na 100% to martwy kod plus rozgałęzienie
w każdym teście. Zapisz datę usunięcia razem z datą dodania — to jedyny moment,
w którym ktokolwiek o tym pamięta.

**Flaga zamiast uprawnień.** Flaga decyduje, *czy* funkcja jest widoczna, a nie
*kto ma prawo* jej użyć. Sterowanie dostępem do danych flagą to luka, nie funkcja.
