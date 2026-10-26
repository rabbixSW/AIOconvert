enum MediaKind { video, audio, image }

class OutputFormat {
  const OutputFormat(this.extension, this.label, this.arguments);

  final String extension;
  final String label;
  final List<String> arguments;
}

const mediaFormats = <MediaKind, List<OutputFormat>>{
  MediaKind.video: [
    OutputFormat('mp4', 'MP4 · H.264', [
      '-c:v',
      'libx264',
      '-preset',
      'medium',
      '-crf',
      '23',
      '-c:a',
      'aac',
      '-b:a',
      '192k',
    ]),
    OutputFormat('mkv', 'MKV · H.264', [
      '-c:v',
      'libx264',
      '-preset',
      'medium',
      '-crf',
      '23',
      '-c:a',
      'aac',
      '-b:a',
      '192k',
    ]),
    OutputFormat('mov', 'MOV · H.264', [
      '-c:v',
      'libx264',
      '-preset',
      'medium',
      '-crf',
      '23',
      '-c:a',
      'aac',
      '-b:a',
      '192k',
    ]),
    OutputFormat('webm', 'WebM · VP9', [
      '-c:v',
      'libvpx-vp9',
      '-crf',
      '32',
      '-b:v',
      '0',
      '-c:a',
      'libopus',
      '-b:a',
      '128k',
    ]),
    OutputFormat('avi', 'AVI · MPEG-4', [
      '-c:v',
      'mpeg4',
      '-q:v',
      '4',
      '-c:a',
      'libmp3lame',
      '-q:a',
      '3',
    ]),
    OutputFormat('m4v', 'M4V · H.264', [
      '-c:v',
      'libx264',
      '-preset',
      'medium',
      '-crf',
      '23',
      '-c:a',
      'aac',
      '-b:a',
      '192k',
    ]),
  ],
  MediaKind.audio: [
    OutputFormat('mp3', 'MP3', ['-vn', '-c:a', 'libmp3lame', '-q:a', '2']),
    OutputFormat('wav', 'WAV · PCM', ['-vn', '-c:a', 'pcm_s16le']),
    OutputFormat('aac', 'AAC', [
      '-vn',
      '-c:a',
      'aac',
      '-b:a',
      '192k',
      '-f',
      'adts',
    ]),
    OutputFormat('flac', 'FLAC', ['-vn', '-c:a', 'flac']),
    OutputFormat('m4a', 'M4A · AAC', ['-vn', '-c:a', 'aac', '-b:a', '192k']),
    OutputFormat('ogg', 'OGG · Vorbis', [
      '-vn',
      '-c:a',
      'libvorbis',
      '-q:a',
      '5',
    ]),
    OutputFormat('opus', 'Opus', ['-vn', '-c:a', 'libopus', '-b:a', '128k']),
    OutputFormat('wma', 'WMA', ['-vn', '-c:a', 'wmav2', '-b:a', '192k']),
  ],
  MediaKind.image: [
    OutputFormat('jpg', 'JPEG', [
      '-frames:v',
      '1',
      '-c:v',
      'mjpeg',
      '-q:v',
      '2',
    ]),
    OutputFormat('png', 'PNG', ['-frames:v', '1', '-c:v', 'png']),
    OutputFormat('webp', 'WebP', [
      '-frames:v',
      '1',
      '-c:v',
      'libwebp',
      '-quality',
      '90',
    ]),
    OutputFormat('bmp', 'BMP', ['-frames:v', '1', '-c:v', 'bmp']),
    OutputFormat('tif', 'TIFF', ['-frames:v', '1', '-c:v', 'tiff']),
    OutputFormat('gif', 'GIF', ['-vf', 'fps=12,scale=960:-1:flags=lanczos']),
  ],
};

const imageExtensions = {
  'apng',
  'avif',
  'bmp',
  'cr2',
  'cr3',
  'dng',
  'exr',
  'gif',
  'heic',
  'heif',
  'ico',
  'j2k',
  'jp2',
  'jpe',
  'jpeg',
  'jpg',
  'jxl',
  'nef',
  'orf',
  'pam',
  'pbm',
  'pcx',
  'pgm',
  'pict',
  'png',
  'pnm',
  'ppm',
  'psd',
  'raf',
  'ras',
  'raw',
  'rgb',
  'rw2',
  'sgi',
  'tga',
  'tif',
  'tiff',
  'webp',
  'xbm',
  'xpm',
};

MediaKind? classifyMedia({
  required String fileName,
  required Iterable<String> streamTypes,
}) {
  final extension = fileName.split('.').last.toLowerCase();
  if (imageExtensions.contains(extension)) return MediaKind.image;

  final types = streamTypes.toSet();
  if (types.contains('video')) return MediaKind.video;
  if (types.contains('audio')) return MediaKind.audio;
  return null;
}

OutputFormat? formatFor(MediaKind kind, String extension) {
  for (final format in mediaFormats[kind]!) {
    if (format.extension == extension) return format;
  }
  return null;
}

List<String> buildConversionArguments({
  required String inputPath,
  required String outputPath,
  required OutputFormat format,
}) => ['-y', '-i', inputPath, ...format.arguments, outputPath];
