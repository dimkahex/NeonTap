#!/usr/bin/env python3
"""
After `flutter create`, Firebase Android needs:
- google-services.json in android/app/
- Gradle plugin `com.google.gms.google-services` (FlutterFire does this via `flutterfire configure`).

CI / fresh clones don't run FlutterFire, so we patch Gradle declaratively.
"""

from __future__ import annotations

import pathlib
import sys


def _read(p: pathlib.Path) -> str:
    return p.read_text(encoding="utf-8")


def _write(p: pathlib.Path, s: str) -> None:
    p.write_text(s, encoding="utf-8", newline="\n")


def patch_settings_gradle(android_dir: pathlib.Path) -> None:
    candidates = [android_dir / "settings.gradle", android_dir / "settings.gradle.kts"]
    p = next((c for c in candidates if c.exists()), None)
    if p is None:
        raise RuntimeError("No android/settings.gradle(.kts) found")

    s = _read(p)
    if "com.google.gms.google-services" in s:
        print(f"[ok] already patched: {p}")
        return

    if p.suffix == ".kts":
        lines = s.splitlines(keepends=True)
        out: list[str] = []
        inserted = False
        for line in lines:
            out.append(line)
            if not inserted and 'id("com.android.application")' in line and "apply false" in line:
                out.append('    id("com.google.gms.google-services") version "4.4.2" apply false\n')
                inserted = True
        if not inserted:
            raise RuntimeError(
                "settings.gradle.kts: couldn't find `id(\"com.android.application\") ... apply false` "
                "(Flutter template changed — update ci/patch_android_firebase_gradle.py)"
            )
        _write(p, "".join(out))
        print(f"[patched] {p}")
        return

    lines = s.splitlines(keepends=True)
    out = []
    inserted = False
    for line in lines:
        out.append(line)
        if not inserted and 'id "com.android.application"' in line and "apply false" in line:
            out.append('    id "com.google.gms.google-services" version "4.4.2" apply false\n')
            inserted = True
    if not inserted:
        raise RuntimeError(
            'settings.gradle: couldn\'t find `id "com.android.application" ... apply false` '
            "(Flutter template changed — update ci/patch_android_firebase_gradle.py)"
        )
    _write(p, "".join(out))
    print(f"[patched] {p}")


def patch_app_gradle(android_dir: pathlib.Path) -> None:
    candidates = [android_dir / "app" / "build.gradle", android_dir / "app" / "build.gradle.kts"]
    p = next((c for c in candidates if c.exists()), None)
    if p is None:
        raise RuntimeError("No android/app/build.gradle(.kts) found")

    s = _read(p)
    if "com.google.gms.google-services" in s:
        print(f"[ok] already patched: {p}")
        return

    if p.suffix == ".kts":
        # plugins { id("com.android.application") ... }
        lines = s.splitlines(keepends=True)
        out: list[str] = []
        inserted = False
        for line in lines:
            out.append(line)
            if not inserted and 'id("com.android.application")' in line:
                out.append('    id("com.google.gms.google-services")\n')
                inserted = True
        if not inserted:
            raise RuntimeError("app/build.gradle.kts: couldn't find com.android.application plugin id")
        _write(p, "".join(out))
        print(f"[patched] {p}")
        return

    # Groovy
    lines = s.splitlines(keepends=True)
    out = []
    inserted = False
    for line in lines:
        out.append(line)
        if not inserted and 'id "com.android.application"' in line:
            out.append('    id "com.google.gms.google-services"\n')
            inserted = True
    if not inserted:
        raise RuntimeError("app/build.gradle: couldn't find com.android.application plugin id")
    _write(p, "".join(out))
    print(f"[patched] {p}")


def main() -> int:
    android = pathlib.Path("android")
    if not android.is_dir():
        print("android/ not found — run flutter create first", file=sys.stderr)
        return 2
    patch_settings_gradle(android)
    patch_app_gradle(android)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
