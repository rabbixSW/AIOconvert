# AIOconvert

A local-first Flutter multimedia converter for Linux and Android. Files are
probed with FFprobe, and the format menu for each item is limited to formats
appropriate for its detected media type. Mixed video, audio, and image queues
require a format selection on every file before conversion.

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
