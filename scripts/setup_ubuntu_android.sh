#!/usr/bin/env bash
set -euo pipefail

# Ubuntu host setup for building + running emulator (not inside Docker).

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk \
  libc6 libstdc++6 libgcc-s1 libglib2.0-0 libnss3 libx11-6 libxcomposite1 libxcursor1 \
  libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxtst6 libpulse0 \
  libasound2t64 libatk1.0-0 libatk-bridge2.0-0 libgtk-3-0 \
  mesa-vulkan-drivers

if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter (snap)..."
  sudo snap install flutter --classic
fi

flutter config --no-analytics
flutter doctor -v

echo ""
echo "Next:"
echo "1) Install Android Studio on the Ubuntu VM (recommended) or install cmdline-tools + SDK."
echo "2) Run: flutter doctor --android-licenses"
echo "3) Create an emulator (AVD) in Android Studio and start it."
echo "4) Build/run:"
echo "   flutter pub get"
echo "   flutter create --platforms=android --org com.neonpulse --project-name neon_pulse_online .   # if android/ missing"
echo "   flutter run"

