#!/usr/bin/env bash
# Ubuntu: Android emulator + скачивание последнего APK из GitHub Actions (NeonTap).
# Запуск: bash scripts/ubuntu_install_emulator_and_fetch_apk.sh
# Требуется: sudo, сеть. Для скачивания артефакта — `gh auth login` (один раз).

set -euo pipefail

REPO="${NEONTAP_REPO:-dimkahex/NeonTap}"
WORKFLOW_FILE="${NEONTAP_WORKFLOW:-android_apk.yml}"
ARTIFACT_NAME="${NEONTAP_ARTIFACT:-neon_pulse_online-apk}"
OUT_DIR="${NEONTAP_OUT:-$HOME/NeonTap-build}"

echo "== 1) Базовые пакеты (Java, зависимости эмулятора) =="
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  openjdk-17-jdk curl wget unzip ca-certificates \
  libglu1-mesa libnss3 libx11-6 libxcomposite1 libxcursor1 libxdamage1 \
  libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxtst6 \
  libpulse0 libasound2 libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0

echo ""
echo "== 2) Android Studio (рекомендуется: GUI, SDK, эмулятор, AVD) =="
echo "Установка через snap (удобно на чистой Ubuntu):"
if command -v snap >/dev/null 2>&1 && ! snap list android-studio 2>/dev/null | grep -q android-studio; then
  sudo snap install android-studio --classic
fi

echo ""
echo "--- Дальше вручную в Android Studio (один раз) ---"
echo "1) Запустите: android-studio  (или из меню приложений)"
echo "2) More Actions → SDK Manager:"
echo "   - SDK Platforms: установите образ, напр. Android 14 (API 34)"
echo "   - SDK Tools: Android Emulator, Android SDK Platform-Tools"
echo "3) More Actions → Virtual Device Manager → Create Device → выберите образ → Finish"
echo "4) Запуск эмулятора: кнопка Play у AVD"
echo ""
echo "Принять лицензии SDK (если установили sdkmanager отдельно):"
echo "  yes | \"\$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager\" --licenses"
echo "(при использовании только Studio путь к sdkmanager может отличаться — см. SDK location в Studio)"

echo ""
echo "== 3) GitHub CLI: скачать последний успешный APK из Actions =="
if ! command -v gh >/dev/null 2>&1; then
  sudo apt-get install -y gh || sudo snap install gh
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Выполните один раз: gh auth login"
  gh auth login
fi

mkdir -p "$OUT_DIR"
RUN_ID="$(gh run list -R "$REPO" --workflow "$WORKFLOW_FILE" --status success --limit 1 --json databaseId -q '.[0].databaseId')"
if [[ -z "$RUN_ID" || "$RUN_ID" == "null" ]]; then
  echo "Не найден успешный run для workflow $WORKFLOW_FILE. Проверьте репозиторий и права токена (нужен repo)."
  exit 1
fi

echo "Скачиваю артефакт из run $RUN_ID → $OUT_DIR"
gh run download "$RUN_ID" -R "$REPO" -n "$ARTIFACT_NAME" -D "$OUT_DIR"

APK="$OUT_DIR/app-release.apk"
if [[ -f "$APK" ]]; then
  ls -lah "$APK"
  echo ""
  echo "== 4) Установка на запущенный эмулятор / устройство =="
  echo "Убедитесь, что эмулятор уже запущен (или подключите телефон с USB debugging)."
  if command -v adb >/dev/null 2>&1; then
    adb devices
    adb install -r "$APK" && echo "OK: установлено $APK"
  else
    echo "adb не в PATH. Добавьте platform-tools в PATH, например:"
    echo "  export PATH=\"\$HOME/Android/Sdk/platform-tools:\$PATH\""
    echo "или (если SDK в стандартном месте Studio):"
    echo "  export PATH=\"\$HOME/Android/Sdk/platform-tools:\$PATH\""
  fi
else
  echo "Ожидался файл $APK — проверьте имя артефакта ($ARTIFACT_NAME) и содержимое $OUT_DIR"
  ls -la "$OUT_DIR"
  exit 1
fi
