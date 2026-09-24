"""Odczyt feature-flag przez OpenFeature.

Na klastrze flagi idą z flagd. Lokalnie — z pliku `flags.json` obok tego modułu,
żeby dało się uruchomić aplikację bez stawiania czegokolwiek.
"""

import json
import os
from pathlib import Path

_LOCAL_FLAGS = Path(__file__).parent / "flags.json"
_provider_ready = False


def _init_flagd() -> bool:
    global _provider_ready
    if _provider_ready:
        return True
    host = os.getenv("FLAGD_HOST")
    if not host:
        return False
    try:
        from openfeature import api
        from openfeature.contrib.provider.flagd import FlagdProvider

        api.set_provider(FlagdProvider(host=host, port=int(os.getenv("FLAGD_PORT", "8013"))))
        _provider_ready = True
        return True
    except Exception:
        # Brak flagd to nie powód, żeby położyć aplikację — wracamy do pliku.
        return False


def flag_enabled(key: str, context: dict | None = None) -> bool:
    if _init_flagd():
        from openfeature import api

        return api.get_client().get_boolean_value(key, False, evaluation_context=context)
    if _LOCAL_FLAGS.exists():
        data = json.loads(_LOCAL_FLAGS.read_text())
        flag = data.get("flags", {}).get(key, {})
        variant = flag.get("defaultVariant")
        return bool(flag.get("variants", {}).get(variant, False))
    return False
