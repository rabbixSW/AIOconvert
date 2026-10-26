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

Choose files with **Browse files** or drag files onto the drop area. On Linux,
choose an output folder from the format panel. Android saves converted files in
the app's documents folder. Appearance settings include dark, light, system,
custom accent colors, and English, Czech, German, French, Spanish, Italian,
Polish, Dutch, and Portuguese languages. The language can follow the system
setting or be chosen explicitly. Linux has File, Settings, and Help menus;
Android keeps the settings button in the app bar.

## Build

```sh
flutter build linux
flutter build apk
```

Linux uses the system `ffmpeg` and `ffprobe` executables, which must be
installed and available on `PATH`. Android uses `ffmpeg_kit_flutter_new`.
Review the package and codec licenses before distributing the application.
