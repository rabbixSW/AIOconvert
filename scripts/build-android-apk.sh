#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(sed -n 's/^version: *\([^+ ]*\).*/\1/p' "$ROOT_DIR/pubspec.yaml")"
MODE="${1:-release}"
OUTPUT_DIR="$ROOT_DIR/dist"

if [[ -z "$VERSION" ]]; then
  printf 'Could not read the app version from pubspec.yaml.\n' >&2
  exit 1
fi

if [[ "$MODE" != release && "$MODE" != debug ]]; then
  printf 'Usage: %s [release|debug]\n' "$0" >&2
  exit 2
fi

if (( $# > 1 )); then
  printf 'Usage: %s [release|debug]\n' "$0" >&2
  exit 2
fi

if ! command -v flutter >/dev/null 2>&1; then
  printf 'Flutter was not found on PATH.\n' >&2
  exit 1
fi

cd "$ROOT_DIR"
if [[ "$MODE" == release ]]; then
  missing_variables=()
  [[ -n "${ANDROID_KEYSTORE_PATH:-}" ]] || missing_variables+=(ANDROID_KEYSTORE_PATH)
  [[ -n "${ANDROID_KEYSTORE_PASSWORD:-}" ]] || missing_variables+=(ANDROID_KEYSTORE_PASSWORD)
  [[ -n "${ANDROID_KEY_ALIAS:-}" ]] || missing_variables+=(ANDROID_KEY_ALIAS)
  [[ -n "${ANDROID_KEY_PASSWORD:-}" ]] || missing_variables+=(ANDROID_KEY_PASSWORD)
  if (( ${#missing_variables[@]} > 0 )); then
    printf 'Set %s to build a release-signed APK. Use "%s debug" for a local debug APK.\n' \
      "${missing_variables[0]}" "$0" >&2
    exit 1
  fi
  if [[ ! -f "$ANDROID_KEYSTORE_PATH" ]]; then
    printf 'Keystore not found: %s\n' "$ANDROID_KEYSTORE_PATH" >&2
    exit 1
  fi
  ANDROID_KEYSTORE_PATH="$(realpath "$ANDROID_KEYSTORE_PATH")"
  export ANDROID_KEYSTORE_PATH

  flutter build apk --release --split-per-abi
  BUILD_SUFFIX=release
else
  flutter build apk --debug --split-per-abi
  BUILD_SUFFIX=debug
fi

mkdir -p "$OUTPUT_DIR"
produced_apks=0
for abi in armeabi-v7a arm64-v8a x86_64; do
  SOURCE_APK="$ROOT_DIR/build/app/outputs/flutter-apk/app-$abi-$BUILD_SUFFIX.apk"
  OUTPUT_APK="$OUTPUT_DIR/AIOconvert-$VERSION-$abi-$BUILD_SUFFIX.apk"
  if [[ -f "$SOURCE_APK" ]]; then
    install -m 644 "$SOURCE_APK" "$OUTPUT_APK"
    printf 'Created %s\n' "$OUTPUT_APK"
    produced_apks=$((produced_apks + 1))
  fi
done

if (( produced_apks == 0 )); then
  printf 'Flutter did not produce any ABI-split APKs.\n' >&2
  exit 1
fi
