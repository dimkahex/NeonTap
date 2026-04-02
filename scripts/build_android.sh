#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-neonpulse-android}"

docker build -t "$IMAGE_NAME" -f docker/Dockerfile.android .

docker run --rm -v "$(pwd)":/workspace -w /workspace "$IMAGE_NAME" bash -lc "
  flutter pub get
  flutter build apk --release
  ls -lah build/app/outputs/flutter-apk/
"

