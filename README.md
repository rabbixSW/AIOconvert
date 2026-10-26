# AIOconvert

A local-first Flutter multimedia converter for Linux and Android. Files are
probed with FFprobe, and the format menu for each item is limited to formats
appropriate for its detected media type. Mixed video, audio, and image queues
require a format selection on every file before conversion.

## Run

```sh
flutter pub get
flutter run -d linux
flutter run -d <android-device-id>
```

Choose files with **Browse files** or drag files onto the drop area. On Linux,
choose an output folder from the format panel. Android saves converted files in
the app's documents folder. Appearance settings include dark, light, system,
and a custom accent color.

## Build

```sh
flutter build linux
flutter build apk
```

FFmpeg and FFprobe are provided by `ffmpeg_kit_flutter_new`, which bundles the
full GPL codec set for both target platforms. Review the package and codec
licenses before distributing the application.
