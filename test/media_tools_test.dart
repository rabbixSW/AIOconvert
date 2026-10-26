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

    test('distinguishes static and animated GIFs', () {
      expect(
        classifyMedia(
          fileName: 'static.gif',
          streamTypes: ['video'],
          streamFrameCounts: [1],
        ),
        MediaKind.image,
      );
      expect(
        classifyMedia(
          fileName: 'animation.gif',
          streamTypes: ['video'],
          streamFrameCounts: [2],
        ),
        MediaKind.video,
      );
      expect(
        mediaFormats[MediaKind.image]!.map((format) => format.extension),
        contains('png'),
      );
      expect(formatFor(MediaKind.video, 'mp4'), isNotNull);
      expect(formatFor(MediaKind.video, 'gif'), isNotNull);
    });

    test('recognizes audio and video from probed streams', () {
      expect(
        classifyMedia(fileName: 'track.unknown', streamTypes: ['audio']),
        MediaKind.audio,
      );
      expect(
        classifyMedia(fileName: 'track.mp3', streamTypes: ['audio', 'video']),
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

  test('video to GIF conversion excludes audio streams', () {
    final arguments = buildConversionArguments(
      inputPath: '/media/clip.mp4',
      outputPath: '/output/clip.gif',
      format: formatFor(MediaKind.video, 'gif')!,
    );

    expect(arguments, contains('-an'));
    expect(arguments, contains('-filter_complex'));
    expect(arguments.last, '/output/clip.gif');
  });

  test('still image to GIF conversion encodes one scaled frame', () {
    final arguments = buildConversionArguments(
      inputPath: '/media/photo.jpg',
      outputPath: '/output/photo.gif',
      format: formatFor(MediaKind.image, 'gif')!,
    );

    expect(arguments, containsAllInOrder(['-frames:v', '1']));
    expect(
      arguments,
      containsAllInOrder(['-vf', 'scale=960:-1:flags=lanczos']),
    );
    expect(arguments.last, '/output/photo.gif');
  });
}
