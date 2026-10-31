import 'package:path/path.dart' as p;

import '../media_tools.dart';

enum JobState { ready, converting, complete, failed }

class MediaJob {
  MediaJob({
    required this.id,
    required this.path,
    required this.name,
    required this.kind,
    required this.hasAudio,
    required this.sourceFormat,
    required this.fileSize,
    required this.duration,
    this.outputFormat,
  });

  final String id;
  final String path;
  final String name;
  String? outputName;
  final MediaKind kind;
  final bool hasAudio;
  final String sourceFormat;
  final int? fileSize;
  final double? duration;
  OutputFormat? outputFormat;
  JobState state = JobState.ready;
  double progress = 0;
  String? error;
  String? outputPath;

  String outputFileName(String extension) {
    final stem = outputName == null
        ? '${p.basenameWithoutExtension(name)}_converted'
        : p.basenameWithoutExtension(outputName!);
    return '$stem.$extension';
  }
}
