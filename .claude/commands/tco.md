---
description: Policz koszt szkoleniowego środowiska — infrastruktura plus tokeny AI
---

Policz całkowity koszt i pokaż go jako jedną tabelę.

**Część 1 — infrastruktura.** Z `infra/` wypisz zasoby, które kosztują (EKS control plane,
węzły EC2, ALB, NAT Gateway, S3, ECR, transfer). Dla każdego: cena jednostkowa
w `eu-central-1` i koszt za 8 godzin szkolenia. Ceny, których nie jesteś pewien,
oznacz `[do sprawdzenia]` — nie zaokrąglaj w ciemno.

**Część 2 — tokeny AI.** Z `docs/tco.md` weź założenia (liczba PR na dzień, średni
rozmiar diffa, ile recenzji na PR) i policz koszt miesięczny pipeline'u z AI na każdym PR.

**Część 3 — wniosek.** Jedno zdanie: co kosztuje więcej i przy jakim wolumenie PR
koszt tokenów przekracza koszt klastra.
