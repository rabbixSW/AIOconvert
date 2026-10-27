# AIOconvert

> **Disclaimer:** This project was made with AI assistance.

A local-first Flutter multimedia converter for Linux, Android, and Windows.
Files are probed with FFprobe, and the format menu for each item is limited to
formats appropriate for its detected media type. Mixed video, audio, and image
queues require a format selection on every file before conversion. GIF files
with video streams are treated as video, allowing conversion to MP4 and other
video formats.

## Requirements and setup

Install the requirements for the platform you want to build on. Release
packaging tools are needed only when creating distributable packages.

### Required for every platform

- Git, to clone the repository and fetch its Git-based Flutter dependency.
- Flutter SDK 3.47.7 or newer (includes the required Dart SDK 3.13.5 or newer).
- An internet connection for `flutter pub get` and first-time platform SDK or
	Gradle downloads.

Clone the repository, open a terminal in its root directory, and check the
Flutter setup for your target platform:

```sh
git clone <repository-url>
cd AIOconvert
flutter doctor -v
flutter pub get
```

Resolve any missing target-platform dependencies reported by `flutter doctor`
before building. Then run `flutter run -d <device>` or one of the build
commands below.

### Windows

- Windows 10 or newer.
- Visual Studio 2022 with the **Desktop development with C++** workload,
	including the MSVC toolchain and a Windows 10/11 SDK. Visual Studio Code
	alone is not the native C++ build toolchain.
- For running the app from source, make `ffmpeg.exe` and `ffprobe.exe`
	available on `PATH`. The Windows portable and installer release scripts
	download and bundle these executables for packaged apps.

### Linux

- A supported Linux desktop environment and the native Flutter desktop
	dependencies. On Debian/Ubuntu, install `clang`, `cmake`, `ninja-build`,
	`pkg-config`, `libgtk-3-dev`, and `libstdc++-12-dev` using the system package
	manager. Package names may differ on other distributions.
- Install `ffmpeg` and `ffprobe` and make them available on `PATH` to run the
	app from source or to create Linux packages.

### Android

- Android Studio with the Android SDK, SDK Platform-Tools, and Android SDK
	Command-line Tools installed. Android Studio also supplies a compatible
	Java runtime; otherwise install JDK 17 and configure Flutter to use it.
- Accept the Android SDK licenses with `flutter doctor --android-licenses`.
	Flutter/Gradle may download the project-required SDK components on the first
	build.
- An emulator or USB-debugging-enabled Android device is needed to run the
	app, but not to build an APK.
- A release APK requires a signing keystore and the four environment variables
	listed in the Android release section below. Debug APKs do not require a
	release keystore.

### Additional release packaging tools

- **Windows installer:** Inno Setup 6 (`ISCC.exe`) for
	`scripts/build-windows-installer.ps1`. The portable ZIP script does not need
	Inno Setup. Both Windows packaging scripts download and verify FFmpeg, so
	network access is required.
- **Linux AppImage:** `linuxdeploy` for
	`scripts/build-linux-appimage.sh`, plus `ffmpeg` and `ffprobe` on `PATH`.
- **Linux Flatpak:** `flatpak` and `flatpak-builder`, with the Flathub remote
	configured. The script builds against the Freedesktop 25.08 runtime and
	downloads its SDK/runtime dependencies through Flathub.
- **Android release APK:** a private release keystore and the signing
	environment variables described below. Keep the keystore and passwords
	private and backed up; the same signing key is needed for future updates.

## Run

Requires Flutter 3.47.7 / Dart 3.13.5 or newer.

```sh
flutter pub get
flutter run -d linux
flutter run -d <android-device-id>
flutter run -d windows
```

Choose files with **Browse files** or drop files onto the compact area above the
queue. Choose output format and conversion settings from the bottom summary.
Linux can save to a selected folder or beside each original file. Android saves
converted files in the app's documents folder. Appearance settings include
dark, light, system, custom accent colors, and English, Czech, German, French,
Spanish, Italian, Polish, Dutch, and Portuguese languages. The language can
follow the system setting or be chosen explicitly. Settings and Help are
available from the gear button in the app bar on Android and in the page header
on Linux and Windows. Linux uses native window decorations.

## Build

```sh
flutter build linux
flutter build apk
flutter build windows
```

Linux uses the system `ffmpeg` and `ffprobe` executables, which must be
installed and available on `PATH`. Android uses `ffmpeg_kit_flutter_new`.
Windows uses the bundled FFmpeg and FFprobe executables in the portable
package; when running from source, install those executables on `PATH`.
The Windows FFmpeg Essentials binaries from gyan.dev are static GPLv3 builds.
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

## Windows portable package

Build the Windows portable ZIP from PowerShell on a Windows machine with
Flutter desktop support and the Visual Studio C++ desktop workload installed:

```powershell
.\scripts\build-windows-portable.ps1
```

The script downloads the FFmpeg Essentials ZIP from gyan.dev, verifies its
published SHA-256 checksum, builds the Windows app, and bundles `ffmpeg.exe`
and `ffprobe.exe` beside `AIOconvert.exe`. The portable ZIP is written to
`dist\`. Use `-Mode debug` to create a debug build for local testing.

## Windows installer

Build the Windows setup executable from PowerShell on a Windows machine with
Flutter desktop support, the Visual Studio C++ desktop workload, and Inno Setup
6 installed:

```powershell
.\scripts\build-windows-installer.ps1
```

The script downloads and verifies FFmpeg, builds the Windows release app,
bundles `ffmpeg.exe` and `ffprobe.exe`, and compiles the installer with Inno
Setup. The installer is written to `dist\AIOconvert-<version>-windows-x64-setup.exe`.
If Inno Setup is installed in a non-standard location, pass its compiler path
with `-InnoSetupCompiler`.
