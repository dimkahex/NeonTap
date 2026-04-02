$ErrorActionPreference = "Stop"

$ImageName = $env:IMAGE_NAME
if ([string]::IsNullOrWhiteSpace($ImageName)) { $ImageName = "neonpulse-android" }

docker build -t $ImageName -f docker/Dockerfile.android .

docker run --rm -v "${PWD}:/workspace" -w /workspace $ImageName bash -lc @"
  flutter pub get
  flutter build apk --release
  ls -lah build/app/outputs/flutter-apk/
"@

