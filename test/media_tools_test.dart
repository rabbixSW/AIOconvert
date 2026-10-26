import 'package:aioconvert/media_tools.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classifyMedia', () {
    test('recognizes images from their extensions', () {
      expect(
        classifyMedia(fileName: 'cover.webp', streamTypes: ['video']),
        MediaKind.image,
      );
      expect(
        classifyMedia(fileName: 'camera.heic', streamTypes: ['video']),
        MediaKind.image,
      );
    });

    test('recognizes audio and video from probed streams', () {
      expect(
        classifyMedia(fileName: 'track.unknown', streamTypes: ['audio']),
        MediaKind.audio,
      );
      expect(
        classifyMedia(
          fileName: 'clip.unknown',
          streamTypes: ['audio', 'video'],
        ),
        MediaKind.video,
      );
    });

    test('rejects files with no supported streams', () {
      expect(
        classifyMedia(fileName: 'notes.txt', streamTypes: ['data']),
        isNull,
      );
    });
  });

  test('offers only a media kind compatible output list', () {
    expect(
      mediaFormats[MediaKind.image]!.map((format) => format.extension),
      containsAll(['jpg', 'png', 'webp']),
    );
    expect(
      mediaFormats[MediaKind.audio]!.map((format) => format.extension),
      contains('mp3'),
    );
    expect(
      mediaFormats[MediaKind.video]!.map((format) => format.extension),
      isNot(contains('mp3')),
    );
  });

  test('builds arguments without shell-quoting user paths', () {
    final arguments = buildConversionArguments(
      inputPath: '/media/my file.mp4',
      outputPath: '/output/my file_converted.webm',
      format: formatFor(MediaKind.video, 'webm')!,
    );

    expect(arguments, contains('/media/my file.mp4'));
    expect(arguments, contains('/output/my file_converted.webm'));
    expect(arguments.first, '-y');
    expect(arguments, contains('libvpx-vp9'));
  });
}
