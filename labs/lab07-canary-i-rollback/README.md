# Lab 07 — canary i wycofanie

**Blok 4 · 30 minut**

## Zadanie

Wdróż nową wersję jako canary, zauważ, że coś jest z nią nie tak, i wycofaj ją —
zanim zobaczy ją cały ruch.

```bash
cd labs/lab07-canary-i-rollback/start
export NS=$UCZESTNIK
kubectl apply -f . -n $NS
```

W `start/` jest komplet manifestów — lab działa niezależnie od tego, co robiłeś wcześniej.

### Etap 1 — stan wyjściowy (5 min)

```bash
kubectl argo rollouts get rollout quotes-api -n $NS
```

Otwórz adres z `kubectl get ingress -n $NS`. Baner ma być niebieski (v1).
Zostaw w drugim terminalu `make load NS=$NS` — bez ruchu nie będzie czego mierzyć.

### Etap 2 — canary (10 min)

```bash
kubectl argo rollouts set image quotes-api quotes-api=$ECR_REPO:v2-broken -n $NS
kubectl argo rollouts get rollout quotes-api -n $NS --watch
```

Obserwuj podział ruchu i odświeżaj przeglądarkę.

### Etap 3 — diagnoza (10 min)

Otwórz dashboard `quotes-api` w Grafanie. Odpowiedz sobie na trzy pytania:

1. Jaki odsetek odpowiedzi 5xx ma canary, a jaki stable?
2. Kiedy dokładnie zaczął rosnąć?
3. Czy `AnalysisRun` już zareagował, czy jeszcze zbiera dane?

```bash
kubectl get analysisrun -n $NS
kubectl describe analysisrun -n $NS | tail -30
```

### Etap 4 — wycofanie (5 min)

Jeśli automat zdążył pierwszy — świetnie, opisz, co się stało i na jakiej podstawie.
Jeśli nie, wycofaj ręcznie:

```bash
kubectl argo rollouts undo quotes-api -n $NS
```

Potwierdź, że ruch wrócił w całości na v1.

## Podpowiedzi

<details>
<summary>Podpowiedź 1 — rollout stoi i nic się nie dzieje</summary>

Krok `pause: {}` bez `duration` czeka na człowieka:

```bash
kubectl argo rollouts promote quotes-api -n $NS
```

Sprawdź, na którym kroku stoisz: `kubectl argo rollouts get rollout quotes-api -n $NS`.
</details>

<details>
<summary>Podpowiedź 2 — AnalysisRun w stanie Inconclusive</summary>

Zapytanie liczy odsetek błędów, więc przy zerowym ruchu dzieli przez zero.
Upewnij się, że `make load` naprawdę działa i że trafia na właściwy adres.
</details>

<details>
<summary>Podpowiedź 3 — wykres pokazuje jedną linię zamiast dwóch</summary>

Panel dzieli dane po etykiecie `wersja`. Jeśli jej nie ma, sprawdź adnotacje
`prometheus.io/scrape` na podach canary — nowe pody muszą je mieć tak samo jak stare.
</details>

## Weryfikacja

```bash
kubectl argo rollouts get rollout quotes-api -n $NS
```

Rollout w stanie `Healthy`, obraz na `v1`, 100% ruchu na stable.

## Pułapki

**`argocd app rollback` przy włączonym auto-sync.** Jeśli aplikacją zarządza Argo CD
z auto-sync, rollback zostanie cofnięty w ciągu kilkudziesięciu sekund — Argo zobaczy
różnicę wobec repozytorium i zsynchronizuje z powrotem. W GitOps wycofanie to `git revert`,
nie komenda na klastrze.

**Rollback cofa obraz, nie skutki.** Wiersze, które zła wersja zdążyła zapisać do bazy,
zostają. Wiadomości, które wysłała — też. Rollback jest tani tylko w warstwie, w której działa.

**Zaufanie do automatycznej bramki.** `AnalysisTemplate` patrzy na odsetek 5xx.
Aplikacja, która zwraca 200 z błędem w treści odpowiedzi, przejdzie tę bramkę bez zająknięcia.
Bramka jest tak dobra, jak metryka, na której stoi.
