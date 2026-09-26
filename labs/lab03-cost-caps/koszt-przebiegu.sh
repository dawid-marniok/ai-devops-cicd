#!/usr/bin/env bash
# Liczy, ile kosztowałby przebieg workflow w repo prywatnym.
#
#   ./labs/lab03-cost-caps/koszt-przebiegu.sh <run-id>
#
# W repo publicznym (np. Twoim forku) GitHub nie pobiera opłat i endpoint /timing
# zwraca 0 ms. Dlatego liczymy z czasów jobów: każdy job zaokrąglony w górę do pełnej
# minuty, razy stawka za minutę dla systemu.
#
# Stawki: https://docs.github.com/en/billing/reference/actions-runner-pricing
# (standardowe runnery, sprawdzone 2026-09-26).

set -euo pipefail
RUN_ID="${1:?Podaj ID przebiegu — z gh run list --workflow kosztowny.yml}"

gh api "repos/{owner}/{repo}/actions/runs/$RUN_ID/jobs" --paginate --jq '
  {"linux": 0.006, "windows": 0.010, "macos": 0.062} as $cena
  | [.jobs[] | {os: (.labels[0] | if startswith("macos") then "macos"
                                  elif startswith("windows") then "windows" else "linux" end),
                min: (((.completed_at|fromdateiso8601) - (.started_at|fromdateiso8601)) / 60 | ceil)}]
  | group_by(.os) | map({os: .[0].os, joby: length, min: (map(.min)|add)})
  | map(. + {usd: (.min * $cena[.os])})
  | (.[] | "\(.os): \(.joby) jobów, \(.min) min × \($cena[.os]) USD = \(.usd * 1000 | round / 1000) USD"),
    "RAZEM: \(map(.usd)|add * 1000 | round / 1000) USD, czyli \(map(.usd)|add / 0.006 | round) min w przeliczeniu na Linuksa"'
