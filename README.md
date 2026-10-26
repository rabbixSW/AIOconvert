# AIOconvert

A local-first Flutter multimedia converter for Linux and Android. Files are
probed with FFprobe, and the format menu for each item is limited to formats
appropriate for its detected media type. Mixed video, audio, and image queues
require a format selection on every file before conversion. GIF files with
video streams are treated as video, allowing conversion to MP4 and other video
formats.

## Run

Requires Flutter 3.47.7 / Dart 3.13.5 or newer.

```sh
flutter pub get
flutter run -d linux
flutter run -d <android-device-id>
```

Choose files with **Browse files** or drop files onto the compact area above the
queue. Choose output format and conversion settings from the bottom summary.
Linux can save to a selected folder or beside each original file. Android saves
converted files in the app's documents folder. Appearance settings include
dark, light, system, custom accent colors, and English, Czech, German, French,
Spanish, Italian, Polish, Dutch, and Portuguese languages. The language can
follow the system setting or be chosen explicitly. Settings and Help are
available from the gear button in the app bar on both Linux and Android.
The Linux window uses a compact GTK titlebar.

## Build

```sh
flutter build linux
flutter build apk
```

Linux uses the system `ffmpeg` and `ffprobe` executables, which must be
installed and available on `PATH`. Android uses `ffmpeg_kit_flutter_new`.
Review the package and codec licenses before distributing the application.
The Linux bundle includes a desktop entry and a hicolor app icon. To make the
icon available to a Wayland desktop, install the matching desktop entry and
icon into standard XDG application and icon-theme directories; the compositor
uses the desktop entry matching `com.aioconvert.aioconvert` to select the
running app's icon.

## Release packages

The packaging scripts place finished artifacts in `dist/`:

```sh
./scripts/build-linux-appimage.sh
./scripts/build-linux-flatpak.sh
./scripts/build-android-apk.sh
```

Linux packaging requires `ffmpeg`, `ffprobe`, and `linuxdeploy` on `PATH`.
Both Linux scripts bundle those FFmpeg executables and their shared-library
dependencies. The shared staging script sets `NO_STRIP=1` for linuxdeploy to
avoid failures stripping RELR-enabled system libraries. The AppImage script
uses linuxdeploy's AppImage output plugin.
Flatpak packaging additionally requires `flatpak` and `flatpak-builder`, with
the Flathub remote configured so the Freedesktop 25.08 runtime and SDK can be
installed. Flatpak accesses user files through desktop file chooser and
drag-and-drop portals.

Android release builds require a private release keystore. Set
`ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, and
`ANDROID_KEY_PASSWORD` in the build environment, then run the APK script.
Keep the keystore and passwords out of source control. To create an APK for
local testing without a release key, run:

```sh
./scripts/build-android-apk.sh debug
adb install dist/AIOconvert-1.0.0-arm64-v8a-debug.apk
```

The Android script produces a separate APK for each supported device ABI
(`armeabi-v7a`, `arm64-v8a`, and `x86_64`) to avoid a very large all-architectures
APK. Install the variant matching the device, for example
`adb shell getprop ro.product.cpu.abi` reports the primary ABI. Release APKs
are written as `dist/AIOconvert-<version>-<abi>-release.apk`; the script uses
the same signing key for future updates, so back it up securely. The Android
Gradle wrapper is pinned to the version required by the configured Android
Gradle plugin.
