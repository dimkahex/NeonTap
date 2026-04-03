# NEON PULSE ONLINE (Phase 1)

Ultra-minimalist neon timing game (one tap, pure skill).  
Phase 1 focuses on **offline core gameplay** + **base UI** with online foundations.

## Screens (7)
- Splash
- Main Menu
- Leaderboard (global + friends)
- Versus (placeholder)
- Game (core)
- Results
- Profile (ник, код друга, список друзей)

## Tech
- Flutter 3.x (null-safety)
- Firebase: anonymous auth + Realtime Database (глобальный рейтинг, друзья по коду)
- Rive / Ads / RevenueCat / Notifications: deps added, usage later

## Local storage
- Best score / best combo: `SharedPreferences`

## Версии и APK (CI)
Версия задаётся в `pubspec.yaml`: строка `version: X.Y.Z+B` — **X.Y.Z** видимое имя, **B** — `versionCode` Android (его должен поднимать каждый релиз в Store / внутренние тесты).

Почему раньше имена казались одинаковыми: CI брал **X.Y.Z** и **B** только из `pubspec`. Если не менять `+B` между пушами, имя и код внутри APK не менялись.

Сейчас в артефакте файл вида **`NeonPulse-vX.Y.Z-bB-rN.apk`**, где **`N` = `github.run_number`** — уникален для каждого прогона. Перед «настоящим» релизом всё равно увеличивай **`+B`** в `pubspec.yaml` на один шаг.

## Phase 2 (что логично дальше)
Phase 1 закрыт: **ядро геймплея**, офлайн-статистика, базовый UI, заготовки Firebase.

Дальше по приоритету (выбери направление):
1. **Онлайн-мета** — таблица лидеров (Firebase RTDB/Firestore), гостевой ник, отправка лучшего после забега.
2. **Экраны-заглушки** — Arena / Versus / Profile: хотя бы каркас с данными и навигацией.
3. **Полировка** — звук, настройки, haptics toggle, локализация.
4. **Монетизация позже** — реклама / IAP, когда ядро и онлайн устраивают.

Правило: ветка **не в `master` без bump `+B`**, если тестируешь установку «поверх» старой сборки.

## Firebase (в финале релиза)
По умолчанию **`kFirebaseOnlineFeaturesEnabled = false`** в `lib/src/config/online_config.dart` — игра и рейтинг работают **локально**, без консоли.

Когда подключишь облако: поставь **`true`**, затем чеклист **[firebase/README.md](firebase/README.md)** (правила RTDB, Anonymous Auth, `google-services.json`).

## Containerized Android build (CI-friendly)
This repo includes a Docker image setup for building an Android APK in a reproducible environment.

- Dockerfile: `docker/Dockerfile.android`
- Build script: `scripts/build_android.ps1` or `scripts/build_android.sh`

Note: running an Android emulator inside Docker is usually not practical; the container is meant for **build**.  
On Ubuntu VM, run emulator on host, install APK from build output.

