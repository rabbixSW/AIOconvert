class MediaInspection {
  const MediaInspection({
    required this.streamTypes,
    required this.streamFrameCounts,
    required this.duration,
    required this.fileSize,
  });

  final Iterable<String> streamTypes;
  final Iterable<int?> streamFrameCounts;
  final double? duration;
  final int? fileSize;
}
