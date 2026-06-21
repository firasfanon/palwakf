#!/usr/bin/env bash
set -euo pipefail

echo "Installing Flutter SDK..."

git clone https://github.com/flutter/flutter.git --depth 1 -b "${FLUTTER_VERSION:-stable}" "$HOME/flutter"

export PATH="$PATH:$HOME/flutter/bin"

flutter --version
flutter pub get

flutter build web --release
