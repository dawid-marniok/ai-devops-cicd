# Lab 06 — wywal sekret z repozytorium

**Blok dodatkowy · 20 minut**

## Sytuacja

`start/migracje.yml` to workflow uruchamiający migracje bazy. Connection string jest w nim
wpisany na sztywno — razem z hasłem produkcyjnym.

Plik jest w repozytorium. Jest też w historii gita, w każdym forku i na każdym laptopie,
na którym ktoś kiedyś zrobił `git clone`.

## Zadanie

Zamień hardkodowaną wartość na dynamic secret pobierany z Vaulta. Pipeline ma dalej działać.

```bash
cd labs/lab06-vault-w-pipeline/start
```

Vault stawia prowadzący — **adres i token podaje on**. Adres musi być osiągalny zarówno
z Twojego laptopa, jak i z runnera GitHub Actions (`127.0.0.1` działa tylko u prowadzącego).
Sprawdź, że widzisz poświadczenia:

```bash
export VAULT_ADDR=<adres-od-prowadzącego>
export VAULT_TOKEN=<token-od-prowadzącego>
vault read database/creds/quotes-api
```

W swoim repo ustaw ten sam adres jako zmienną, której użyje workflow:

```bash
gh variable set VAULT_ADDR --body "$VAULT_ADDR"
```

Uruchom to dwa razy i zwróć uwagę, co się zmienia.

Prompt: `prompts/blokx-sekrety.md`, sekcja „Zamiana hardkodowanego sekretu na dynamic secret".

## Wymagania

- [ ] zero wartości poświadczeń w pliku workflow
- [ ] uwierzytelnianie w Vaulcie metodą JWT przez OIDC GitHuba, nie tokenem w sekretach
- [ ] `id-token: write` **tylko** w jobie, który tego potrzebuje
- [ ] wartość przekazana do kroku przez blok `env:`, nie przez interpolację w `run:`
- [ ] `permissions` zawężone zamiast `write-all`

## Podpowiedzi

<details>
<summary>Podpowiedź 1 — od czego zacząć</summary>

Akcja nazywa się `hashicorp/vault-action`. Potrzebuje trzech rzeczy: adresu Vaulta,
metody uwierzytelniania (`jwt`) i nazwy roli (`quotes-api`).

Ścieżka: `database/creds/quotes-api`, pola `username` i `password`.
</details>

<details>
<summary>Podpowiedź 2 — „Vault odmawia dostępu"</summary>

Rola Vaulta dopuszcza tylko token z gałęzi `main` konkretnego repozytorium. GitHub zapisuje
je w claimie `sub` razem z niezmiennymi identyfikatorami, np.
`repo:anna-k@12345/ai-devops-cicd@67890:ref:refs/heads/main`. Job z innej gałęzi albo
z repo, którego prowadzący nie dodał do roli, dostanie odmowę — i tak ma być.

Do ćwiczenia poproś prowadzącego o rozszerzenie roli albo pracuj na `main`.
</details>

<details>
<summary>Podpowiedź 3 — dlaczego `env:` a nie `run:`</summary>

```yaml
run: psql "${{ env.DB_PASSWORD }}"     # źle
```

Interpolacja `${{ }}` wstawia wartość **wprost do tekstu skryptu**, zanim shell go zobaczy.
Wartość ląduje w liście procesów, a przy `set -x` również w logu.

```yaml
- id: vault
  uses: hashicorp/vault-action@v4
  # ... secrets: database/creds/quotes-api password | DB_PASSWORD
- env:
    DB_PASSWORD: ${{ steps.vault.outputs.DB_PASSWORD }}
  run: psql "$DB_PASSWORD"             # dobrze
```
</details>

## Weryfikacja

```bash
grep -inE "postgresql://|Prod!" migracje.yml
```

Nie powinno być żadnego trafienia — tylko odwołania do Vaulta.

Potem porównaj wynik z rozwiązaniem omówionym przez prowadzącego.

## Pułapki

**Maskowanie w logach nie jest zabezpieczeniem.** GitHub zamieni wartość na gwiazdki,
ale robi to przez dokładne dopasowanie tekstu. Sprawdź sam:

```yaml
- run: echo "$DB_PASSWORD"                # → ***
- run: echo "$DB_PASSWORD" | base64       # → przechodzi
```

Prawdziwą ochroną jest tu to, że to poświadczenie za godzinę przestanie działać.

**Zapisanie wartości do `GITHUB_ENV`.** Kuszące, żeby pobrać raz i używać w kolejnych krokach.
Od tego momentu jest dostępna dla **każdego** kroku w jobie, w tym dla akcji z marketplace'u,
której kodu nikt nie czytał.

**„Usunąłem to z pliku, więc już tego nie ma."** Jest — w historii gita. Usuwanie zaczyna się
od uznania wartości za skompromitowaną i unieważnienia jej po stronie bazy. Czyszczenie
historii jest dopiero drugim krokiem i samo w sobie niczego nie ratuje.

**Vault jako pojedynczy punkt awarii.** Jeśli Vault nie odpowiada, żaden pipeline nie ruszy.
To realny koszt tego rozwiązania — warto o nim wiedzieć przed wdrożeniem, a nie w trakcie
pierwszej awarii.
