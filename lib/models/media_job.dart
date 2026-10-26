import '../media_tools.dart';

enum JobState { ready, converting, complete, failed }

class MediaJob {
  MediaJob({
    required this.id,
    required this.path,
    required this.name,
    required this.kind,
    required this.sourceFormat,
    required this.fileSize,
    required this.duration,
    this.outputFormat,
  });

  final String id;
  final String path;
  final String name;
  final MediaKind kind;
  final String sourceFormat;
  final int? fileSize;
  final double? duration;
  OutputFormat? outputFormat;
  JobState state = JobState.ready;
  double progress = 0;
  String? error;
  String? outputPath;
}
