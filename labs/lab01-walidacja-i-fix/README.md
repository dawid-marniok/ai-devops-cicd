# Lab 01 — znajdź i napraw

**Blok 1 · 20 minut**

## Sytuacja

Asystent AI napisał moduł Terraform tworzący bucket na logi aplikacji, rolę dla kolektora
i security group. Moduł przechodzi `terraform validate` bez jednego błędu i wygląda porządnie:
ma tagi, ma wersjonowanie, ma blokadę dostępu publicznego.

Trafił do pull requesta. Jesteś recenzentem.

## Zadanie

W `start/` są **trzy** celowo wprowadzone błędy. Znajdź je i napraw.

Jeden z nich zgłosi skaner. **Dwóch pozostałych nie zgłosi** — musisz je przeczytać.
To nie jest utrudnienie na potrzeby ćwiczenia, tylko realny rozkład: skanery świetnie
łapią znane wzorce i nie widzą wszystkiego innego.

```bash
cd labs/lab01-walidacja-i-fix/start
terraform init -backend=false
terraform validate
tflint
checkov -d . --compact
trivy config .
```

Napraw w kodzie. Nie używaj `#checkov:skip` — to nie jest naprawa, tylko wyciszenie.

## Podpowiedzi

Zaglądaj po kolei, dopiero gdy utkniesz.

<details>
<summary>Podpowiedź 1</summary>

Skanery zgłoszą kilka rzeczy. Nie wszystkie są w tym zadaniu — część dotyczy decyzji
świadomych (patrz tabela na końcu `infra/modules/app-storage/README.md`).

Skup się na dwóch obszarach: **co ten bucket robi z danymi, które w nim lądują**,
oraz **kto może wysłać coś do kolektora**.
</details>

<details>
<summary>Podpowiedź 2</summary>

Trzeciego błędu nie znajdziesz skanerem. Spróbuj tego: wdróż ten moduł mentalnie
dla dwóch różnych uczestników — `anna-k` i `piotr-w`. Czy oba wdrożenia zadziałają tak samo?

Przeczytaj uważnie politykę IAM roli kolektora.
</details>

<details>
<summary>Podpowiedź 3</summary>

1. Bucket ma wersjonowanie i blokadę dostępu publicznego. Czego jeszcze brakuje mu
   z listy rzeczy, które ma moduł referencyjny `infra/modules/app-storage`?
2. Reguła ingress ma opis „Syslog z sieci wewnetrznej". Sprawdź, czy `cidr_blocks`
   mówi to samo co opis.
3. W polityce IAM porównaj `Resource` z nazwą bucketu tworzonego wyżej w tym samym pliku.
</details>

## Weryfikacja

```bash
terraform fmt -check
terraform validate
trivy config .
```

Po naprawie liczba zgłoszeń ma spaść, a te, które zostaną, musisz umieć uzasadnić.
Po zakończeniu prowadzący pokaże rozwiązanie i omówi każdą poprawkę.

## Pułapki

**Wyciszenie zamiast naprawy.** Jeśli poprosisz AI o „sprawienie, żeby Checkov przechodził",
najszybszą drogą jest dopisanie `#checkov:skip` przy każdym zgłoszeniu. Kod będzie zielony
i tak samo dziurawy. Poproś o naprawę przyczyny i osobne uzasadnienie dla zgłoszeń,
które uważasz za fałszywie pozytywne.

**Zielony skaner jako meta.** Moduł referencyjny w tym repo **celowo** nie przechodzi
na zero. Cel to świadoma decyzja przy każdym zgłoszeniu, nie pusta lista.

**Błąd, którego nie widać.** Jeden z błędów to poprawny, bezpieczny, zgodny z politykami kod,
który po prostu nie działa u nikogo poza autorem. Skanery szukają luk bezpieczeństwa,
nie pomyłek.

**Skaner i tak nie widzi wszystkiego.** Otwarta reguła ingress na porcie 514 **nie zostanie
zgłoszona przez Trivy** — reguła `AVD-AWS-0107` reaguje na porty uznane za wrażliwe
(22, 3389), a nie na każdy adres `0.0.0.0/0`. Ten sam kod z portem 22 zamiast 514 zapala
się na czerwono natychmiast. Checkov też jej nie zgłasza (sprawdzone na Trivy 0.62.1
i Checkov 3.3.19). Trivy zgłosi za to jako CRITICAL regułę **egress** na 443 — to nie jest
jeden z trzech błędów, tylko decyzja do uzasadnienia (kolektor musi wysyłać do S3).

To jest wniosek z tego labu: zielony skaner mówi „nie znalazłem znanych wzorców",
a nie „ten kod jest bezpieczny".
