# NEON PULSE ONLINE (Phase 1)

Ultra-minimalist neon timing game (one tap, pure skill).  
Phase 1 focuses on **offline core gameplay** + **base UI** with online foundations.

## Screens (7)
- Splash
- Main Menu
- Arena (placeholder)
- Versus (placeholder)
- Game (core)
- Results
- Profile / Player Card (placeholder)

## Tech
- Flutter 3.x (null-safety)
- Firebase: guest auth only (Phase 1)
- Realtime Database: wired (not used yet)
- Rive / Ads / RevenueCat / Notifications: deps added, usage later

## Local storage
- Best score / best combo: `SharedPreferences`

## Версии и APK (CI)
Версия задаётся в `pubspec.yaml`: строка `version: X.Y.Z+B` — **X.Y.Z** имя релиза, **B** номер сборки.

После успешного **Android APK (Release)** в артефакте один универсальный файл:
`NeonPulse-vX.Y.Z-bB.apk`.

Перед новой публичной сборкой увеличь **+1** в `version` (например `0.2.0+2` → `0.2.0+3` или `0.3.0+1`).

## Containerized Android build (CI-friendly)
This repo includes a Docker image setup for building an Android APK in a reproducible environment.

- Dockerfile: `docker/Dockerfile.android`
- Build script: `scripts/build_android.ps1` or `scripts/build_android.sh`

Note: running an Android emulator inside Docker is usually not practical; the container is meant for **build**.  
On Ubuntu VM, run emulator on host, install APK from build output.

