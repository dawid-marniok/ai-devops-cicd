# Claude Code w tym repo — commands, skille, hooki, agenci

Cztery mechanizmy rozszerzania Claude Code, wszystkie skonfigurowane w `.claude/`.
Poniżej co każdy z nich robi, jak jest uruchamiany i przykład z tego repo.

## 1. Slash commands (`.claude/commands/*.md`)

Pojedynczy plik Markdown = jedna komenda. Frontmatter ma tylko `description`,
reszta pliku to treść promptu, który zostaje wklejony do rozmowy w momencie
wywołania. `$ARGUMENTS` podstawia całość tego, co user wpisał po nazwie komendy;
`$1`, `$2`, ... podstawiają poszczególne argumenty osobno, gdy komenda przyjmuje
więcej niż jeden parametr.

Uruchamiane **wyłącznie explicite** — user musi wpisać `/nazwa`. Nic nie
odpala się samo.

Komendy w tym repo:

```
/tf-review          recenzja zmian w Terraform
/drift-fix [kat] [uczestnik]  wykryj drift i przygotuj PR z poprawką
/pr-review [nr]      recenzja PR w trzech przebiegach
/postmortem <ns>     post-mortem z logów i metryk
/tco                 koszt infrastruktury plus tokenów AI
```

Przykład — `.claude/commands/drift-fix.md`:

```markdown
---
description: Wykryj drift i przygotuj poprawkę jako PR
---

Katalog Terraform: $1 (domyślnie `infra/modules/app-storage`).
Uczestnik: $2 — wartość zmiennej `uczestnik`, taka sama jak przy `terraform apply`.

1. Uruchom `terraform plan -var="uczestnik=$2" -detailed-exitcode -refresh-only`...
...
```

Wywołanie `/drift-fix infra/modules/app-storage-bledny anna-k` podstawia
katalog pod `$1` i uczestnika pod `$2`.

## 2. Skille

Katalog (nie pojedynczy plik) z `SKILL.md`, opcjonalnie plus skrypty i pliki
referencyjne. Kluczowa różnica względem command: pole `description` służy
Claude do **automatycznego wykrycia**, że dany skill pasuje do zadania — nie
trzeba pisać `/nazwa`, model sam decyduje na podstawie treści rozmowy. Można
go też wywołać explicite.

Uwaga praktyczna z tego repo: Claude Code wystawia przez narzędzie `Skill`
również pliki z `.claude/commands/`, więc `drift-fix` czy `tf-review`
pojawiają się na liście dostępnych skilli, mimo że fizycznie są zwykłymi
commandami, a nie folderami w `.claude/skills/`. To repo nie ma jeszcze
własnego katalogu `.claude/skills/` — jeśli powstanie dedykowany skill
(np. z dodatkowymi skryptami pomocniczymi), trafi właśnie tam.

## 3. Hooki (`.claude/hooks/`, konfiguracja w `.claude/settings.json`)

Hook to skrypt shellowy podpięty pod zdarzenie cyklu życia narzędzia
(`PreToolUse`, `PostToolUse` itd.). Claude Code przekazuje mu na `stdin` JSON
opisujący próbę wywołania narzędzia. Kod wyjścia decyduje, co dalej:

- `exit 0` — przepuść, nic się nie dzieje
- `exit 2` — zablokuj wywołanie, `stderr` pokazuje się userowi/agentowi jako powód

Konfiguracja w `settings.json`:

```json
"hooks": {
  "PreToolUse": [
    {
      "matcher": "Read|Bash",
      "hooks": [
        { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/blokuj-sekrety.sh" }
      ]
    }
  ]
}
```

`matcher` filtruje, dla jakich narzędzi hook w ogóle się odpala (tu: każde
`Read` i każdy `Bash`). Ten konkretny hook (`blokuj-sekrety.sh`) czyta
zdarzenie, sprawdza je regexem pod kątem `.env`, `*.tfvars`, `credentials`,
kluczy `.pem`/`id_rsa`/`AKIA...` i jeśli trafi — blokuje wywołanie zamiast
pozwolić wciągnąć sekret do kontekstu modelu. To pokrywa się z zasadą z
`CLAUDE.md`: „nie wciągaj do kontekstu plików `.env`, `*.tfvars`,
`credentials`” — hook to egzekwuje mechanicznie, niezależnie od tego, czy
model o tym pamięta.

Hooki nie zastępują `permissions.deny` w `settings.json` (to osobna warstwa —
blokada na poziomie samego narzędzia, zanim hook w ogóle się odpali), ale
łapią przypadki, których statyczna lista `deny` nie pokryje (np. dowolna
ścieżka pasująca do wzorca, a nie tylko wymienione pliki).

## 4. Definicje agentów (`.claude/agents/*.md`)

Subagent = osobny kontekst rozmowy z własnym systemowym promptem, własnym
zestawem narzędzi i (opcjonalnie) osobnym modelem. Uruchamiany przez
narzędzie `Agent`, dostaje zadanie i **nie widzi** historii rozmowy głównego
agenta — wszystko, co ma wiedzieć, musi być w promptcie wywołania.

Frontmatter:

- `name` — identyfikator, po nim agent jest wybierany
- `description` — kiedy go użyć (to na tej podstawie główny agent decyduje,
  czy zlecić mu zadanie)
- `tools` — biała lista narzędzi; agent nie ma dostępu do niczego poza tym

Przykład — `.claude/agents/recenzent-terraform.md`:

```markdown
---
name: recenzent-terraform
description: Recenzja modułów Terraform pod kątem poprawności, konwencji
  repo i kosztu. Używaj przed apply i w pipeline na PR dotykających plików .tf.
tools: Read, Grep, Glob, Bash
---

Jesteś recenzentem Terraform w zespole platformowym. Recenzujesz kod, nie
piszesz go od nowa. Zawsze zaczynaj od `terraform fmt -check`, `validate`,
`tflint`...
```

Ten agent ma tylko `Read, Grep, Glob, Bash` — nie może np. edytować plików
(`Edit`/`Write` nie są na liście), więc fizycznie nie jest w stanie
„naprawić” tego, co recenzuje, nawet gdyby prompt go do tego namawiał.
Ograniczenie narzędzi jest tu formą kontroli, nie tylko sugestią w tekście.

Drugi agent w repo: `recenzent-bezpieczenstwa` — ten sam wzorzec, inny zakres
(sekrety, uprawnienia, podatności w pipeline).

## Skrót różnic

| Mechanizm | Plik/katalog | Kto uruchamia | Kontekst |
|---|---|---|---|
| Command | `.claude/commands/*.md` | user, explicite `/nazwa` | ten sam wątek rozmowy |
| Skill | `.claude/skills/<nazwa>/SKILL.md` | model, automatycznie po `description` (lub explicite) | zwykle ten sam wątek, część może odpalać się jako subagent w tle |
| Hook | `.claude/hooks/*.sh` + wpis w `settings.json` | harness, na zdarzenie (`PreToolUse` itd.) | brak — to skrypt shellowy, nie LLM |
| Agent (subagent) | `.claude/agents/*.md` | model, przez narzędzie `Agent` | osobny, świeży kontekst, ograniczony `tools` |

Uprawnienia, tryby pracy i priorytety plików `settings.json` opisuje
[claude-code-uprawnienia.md](claude-code-uprawnienia.md).
