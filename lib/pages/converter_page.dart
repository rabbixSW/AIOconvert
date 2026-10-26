import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';
import '../media_tools.dart';
import '../models/media_job.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({required this.onOpenSettings, super.key});

  final VoidCallback onOpenSettings;

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final List<MediaJob> _jobs = [];
  bool _isHovering = false;
  bool _isConverting = false;
  bool _cancelRequested = false;
  Process? _activeLinuxProcess;
  String? _outputDirectory;
  String? _allFormatExtension;
  bool _saveNextToOriginal = false;

  bool get _hasMixedKinds => _jobs.map((job) => job.kind).toSet().length > 1;
  bool get _canConvert =>
      _jobs.isNotEmpty &&
      !_isConverting &&
      _jobs.every((job) => job.outputFormat != null);

  @override
  void initState() {
    super.initState();
    _loadOutputDirectory();
  }

  Future<void> _loadOutputDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final preferences = await SharedPreferences.getInstance();
    final saveNextToOriginal =
        !Platform.isAndroid &&
        (preferences.getBool('saveNextToOriginal') ?? false);
    final savedPath = !Platform.isAndroid
        ? preferences.getString('outputDirectory')
        : null;
    final directory = savedPath == null
        ? Directory(appDirectory.path)
        : Directory(savedPath);
    final selectedDirectory = await directory.exists()
        ? directory.path
        : appDirectory.path;
    if (!mounted) return;
    setState(() {
      _outputDirectory = selectedDirectory;
      _saveNextToOriginal = saveNextToOriginal;
    });
  }

  Future<void> _showSaveSettings() async {
    final strings = AppLocalizations.of(context)!;
    var selectedDirectory = _outputDirectory;
    var saveNextToOriginal = _saveNextToOriginal;
    final result = await showDialog<({String? directory, bool nextToOriginal})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(strings.saveFolderSelection),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!Platform.isAndroid)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: saveNextToOriginal,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(strings.saveNextToOriginal),
                  ),
                  onChanged: (value) =>
                      setDialogState(() => saveNextToOriginal = value ?? false),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 12),
                  child: Text(
                    strings.saveNextToOriginalAndroidUnavailable,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (!Platform.isAndroid) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(strings.saveTo, style: _eyebrowStyle(context)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final directory = selectedDirectory;
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              directory == null
                                  ? strings.loadingFolder
                                  : p.basename(directory),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: strings.chooseFolder,
                      onPressed: saveNextToOriginal
                          ? null
                          : () async {
                              final path = await FilePicker.getDirectoryPath(
                                dialogTitle: strings.chooseFolder,
                                initialDirectory: selectedDirectory,
                              );
                              if (path != null) {
                                setDialogState(() => selectedDirectory = path);
                              }
                            },
                      icon: const Icon(Icons.folder_open_outlined),
                    ),
                  ],
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(strings.appStorage),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.closeDialog),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, (
                directory: selectedDirectory,
                nextToOriginal: saveNextToOriginal,
              )),
              child: Text(strings.apply),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _outputDirectory = result.directory;
      _saveNextToOriginal = result.nextToOriginal;
    });
    final preferences = await SharedPreferences.getInstance();
    if (result.directory != null) {
      await preferences.setString('outputDirectory', result.directory!);
    }
    await preferences.setBool('saveNextToOriginal', result.nextToOriginal);
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(type: FileType.any);
    if (result.isNotEmpty) _clearCompletedForNewBatch();
    for (final file in result) {
      await _addFile(
        file.path ?? file.uri.toString(),
        file.name,
        fileSize: file.lengthSync(),
      );
    }
  }

  Future<void> _addDroppedFiles(List<DropItem> items) async {
    final strings = AppLocalizations.of(context)!;
    if (items.any((item) => item is! DropItemDirectory)) {
      _clearCompletedForNewBatch();
    }
    for (final item in items) {
      if (item is DropItemDirectory) {
        _showMessage(strings.dropFoldersUnsupported);
        continue;
      }
      final fileSize = await item.length();
      if (!mounted) return;
      await _addFile(item.path, item.name, fileSize: fileSize);
    }
  }

  Future<void> _addFile(String path, String name, {int? fileSize}) async {
    if (_jobs.any((job) => job.path == path)) return;
    final strings = AppLocalizations.of(context)!;
    try {
      final probePath = _ffmpegInputPath(path);
      final inspection = await _inspectMedia(probePath);
      final kind = classifyMedia(
        fileName: name,
        streamTypes: inspection.streamTypes,
        streamFrameCounts: inspection.streamFrameCounts,
      );
      if (kind == null) {
        throw FormatException(strings.unsupportedFile);
      }

      final job = MediaJob(
        id: '${DateTime.now().microsecondsSinceEpoch}-${_jobs.length}',
        path: path,
        name: name,
        kind: kind,
        hasAudio: inspection.streamTypes.contains('audio'),
        sourceFormat: p.extension(name).replaceFirst('.', '').toUpperCase(),
        fileSize: fileSize ?? inspection.fileSize,
        duration: inspection.duration,
        outputFormat: _hasMixedKinds
            ? null
            : formatFor(kind, _allFormatExtension ?? ''),
      );
      if (!mounted) return;
      setState(() => _jobs.add(job));
    } catch (error) {
      _showMessage(strings.inspectFailed(name, error.toString()));
    }
  }

  Future<_MediaInspection> _inspectMedia(String path) async {
    if (Platform.isLinux) {
      final result = await Process.run('ffprobe', [
        '-v',
        'error',
        '-show_entries',
        'format=duration,size:stream=codec_type,nb_frames',
        '-of',
        'json',
        path,
      ]);
      if (result.exitCode != 0) {
        throw ProcessException(
          'ffprobe',
          [path],
          result.stderr.toString().trim(),
          result.exitCode,
        );
      }

      final data = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
      final format = data['format'] as Map<String, dynamic>? ?? {};
      final streams = data['streams'] as List<dynamic>? ?? [];
      return _MediaInspection(
        streamTypes: streams
            .whereType<Map<String, dynamic>>()
            .map((stream) => stream['codec_type'] as String? ?? '')
            .toList(),
        streamFrameCounts: streams
            .whereType<Map<String, dynamic>>()
            .map(
              (stream) => int.tryParse(stream['nb_frames']?.toString() ?? ''),
            )
            .toList(),
        duration: double.tryParse(format['duration'] as String? ?? ''),
        fileSize: int.tryParse(format['size'] as String? ?? ''),
      );
    }

    final probeSession = await FFprobeKit.getMediaInformation(path);
    final information = probeSession.getMediaInformation();
    if (information == null) {
      throw const FormatException('FFprobe could not read this media file.');
    }
    return _MediaInspection(
      streamTypes: information
          .getStreams()
          .map((stream) => stream.getType() ?? '')
          .toList(),
      streamFrameCounts: information
          .getStreams()
          .map(
            (stream) =>
                int.tryParse(stream.getProperty('nb_frames')?.toString() ?? ''),
          )
          .toList(),
      duration: double.tryParse(information.getDuration() ?? ''),
      fileSize: int.tryParse(information.getSize() ?? ''),
    );
  }

  String _ffmpegInputPath(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.scheme == 'file') return uri.toFilePath();
    return path;
  }

  void _setAllFormat(String? extension) {
    if (extension == null || _jobs.isEmpty || _hasMixedKinds) return;
    final kind = _jobs.first.kind;
    final format = formatFor(kind, extension);
    if (format == null) return;
    setState(() {
      _allFormatExtension = extension;
      for (final job in _jobs) {
        job.outputFormat = format;
      }
    });
  }

  void _setJobFormat(MediaJob job, String? extension) {
    if (extension == null) return;
    final format = formatFor(job.kind, extension);
    if (format == null) return;
    setState(() {
      job.outputFormat = format;
      if (!_hasMixedKinds &&
          _jobs.every((entry) => entry.outputFormat?.extension == extension)) {
        _allFormatExtension = extension;
      }
    });
  }

  Future<String> _availableOutputPath(MediaJob job) async {
    final directoryPath = _saveNextToOriginal
        ? p.dirname(_ffmpegInputPath(job.path))
        : _outputDirectory;
    if (directoryPath == null) {
      throw StateError(AppLocalizations.of(context)!.outputFolderNotReady);
    }
    final directory = Directory(directoryPath);
    await directory.create(recursive: true);
    final stem = p.basenameWithoutExtension(job.name);
    final extension = job.outputFormat!.extension;
    var suffix = 0;
    late String candidate;
    do {
      final suffixText = suffix == 0 ? '' : '_$suffix';
      candidate = p.join(
        directoryPath,
        '${stem}_converted$suffixText.$extension',
      );
      suffix++;
    } while (await File(candidate).exists());
    return candidate;
  }

  Future<void> _convertAll() async {
    if (!_canConvert) return;
    final gifJobsWithAudio = _jobs.where(
      (job) =>
          job.state != JobState.complete &&
          job.outputFormat?.extension == 'gif' &&
          job.hasAudio,
    );
    if (gifJobsWithAudio.isNotEmpty) {
      final strings = AppLocalizations.of(context)!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.gifAudioLossTitle),
          content: Text(strings.gifAudioLossMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.keepVideo),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.convertWithoutAudio),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() {
      _isConverting = true;
      _cancelRequested = false;
    });
    for (final job in _jobs) {
      if (_cancelRequested) break;
      if (job.state == JobState.complete) continue;
      await _convert(job);
    }
    if (!mounted) return;
    setState(() => _isConverting = false);
    final completed = _jobs
        .where((job) => job.state == JobState.complete)
        .length;
    final failed = _jobs.where((job) => job.state == JobState.failed).length;
    final strings = AppLocalizations.of(context)!;
    if (_cancelRequested) {
      _showMessage(strings.convertStopped(completed));
    } else if (failed > 0) {
      _showMessage(strings.convertPartial(completed, failed));
    } else {
      _showMessage(strings.convertSuccess(completed));
    }
  }

  Future<void> _convert(MediaJob job) async {
    final strings = AppLocalizations.of(context)!;
    setState(() {
      job.state = JobState.converting;
      job.progress = 0;
      job.error = null;
    });
    try {
      final outputPath = await _availableOutputPath(job);
      final arguments = buildConversionArguments(
        inputPath: _ffmpegInputPath(job.path),
        outputPath: outputPath,
        format: job.outputFormat!,
      );
      if (Platform.isLinux) {
        await _convertWithSystemFfmpeg(job, arguments, outputPath);
        return;
      }

      final done = Completer<void>();
      var lastProgressUpdate = DateTime.fromMillisecondsSinceEpoch(0);
      final session = await FFmpegKit.executeWithArgumentsAsync(
        arguments,
        (_) {
          if (!done.isCompleted) done.complete();
        },
        null,
        (statistics) {
          if (job.duration == null || job.duration! <= 0) return;
          final now = DateTime.now();
          if (now.difference(lastProgressUpdate).inMilliseconds < 250) return;
          lastProgressUpdate = now;
          if (!mounted) return;
          setState(() {
            job.progress = (statistics.getTime() / (job.duration! * 1000))
                .clamp(0.0, 1.0);
          });
        },
      );
      await done.future;
      final returnCode = await session.getReturnCode();
      if (!ReturnCode.isSuccess(returnCode)) {
        final details = await session.getOutput();
        final reason = details
            ?.trim()
            .split('\n')
            .where((line) => line.isNotEmpty)
            .lastOrNull;
        throw ProcessException(
          'ffmpeg',
          arguments,
          reason ??
              'FFmpeg exited with code ${returnCode?.getValue() ?? 'unknown'}.',
        );
      }
      if (!await File(outputPath).exists()) {
        throw FileSystemException(strings.ffmpegNoOutput);
      }
      setState(() {
        job.state = JobState.complete;
        job.progress = 1;
        job.outputPath = outputPath;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        job.state = JobState.failed;
        job.error = error.toString();
      });
    }
  }

  Future<void> _convertWithSystemFfmpeg(
    MediaJob job,
    List<String> arguments,
    String outputPath,
  ) async {
    final noOutputMessage = AppLocalizations.of(context)!.ffmpegNoOutput;
    final process = await Process.start('ffmpeg', arguments);
    _activeLinuxProcess = process;
    final stderr = StringBuffer();
    var lastProgressUpdate = DateTime.fromMillisecondsSinceEpoch(0);
    final stderrDone = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          stderr.writeln(line);
          final match = RegExp(r'time=(\d+):(\d+):(\d+(?:\.\d+)?)')
              .firstMatch(line);
          if (match == null || job.duration == null || job.duration! <= 0) {
            return;
          }
          final elapsed =
              int.parse(match[1]!) * 3600 +
              int.parse(match[2]!) * 60 +
              double.parse(match[3]!);
          final now = DateTime.now();
          if (now.difference(lastProgressUpdate).inMilliseconds < 250 ||
              !mounted) {
            return;
          }
          lastProgressUpdate = now;
          setState(() {
            job.progress = (elapsed / job.duration!).clamp(0.0, 1.0);
          });
        })
        .asFuture<void>();
    final stdoutDone = process.stdout.drain<void>();
    final exitCode = await process.exitCode;
    await Future.wait([stderrDone, stdoutDone]);
    _activeLinuxProcess = null;

    if (exitCode != 0) {
      final reason = stderr
          .toString()
          .trim()
          .split('\n')
          .where((line) => line.isNotEmpty)
          .lastOrNull;
      throw ProcessException(
        'ffmpeg',
        arguments,
        reason ?? 'FFmpeg exited with code $exitCode.',
        exitCode,
      );
    }
    if (!await File(outputPath).exists()) {
      throw FileSystemException(noOutputMessage);
    }
    if (!mounted) return;
    setState(() {
      job.state = JobState.complete;
      job.progress = 1;
      job.outputPath = outputPath;
    });
  }

  Future<void> _cancelConversion() async {
    _cancelRequested = true;
    if (Platform.isLinux) {
      _activeLinuxProcess?.kill(ProcessSignal.sigint);
    } else {
      await FFmpegKit.cancel();
    }
  }

  void _removeJob(MediaJob job) {
    if (_isConverting) return;
    setState(() {
      _jobs.remove(job);
      if (_jobs.isEmpty) _allFormatExtension = null;
    });
  }

  void _clearCompletedForNewBatch() {
    if (_isConverting || !_jobs.any((job) => job.state == JobState.complete)) {
      return;
    }
    setState(() {
      _jobs.removeWhere((job) => job.state == JobState.complete);
      if (_jobs.isEmpty) _allFormatExtension = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: Platform.isLinux
          ? null
          : AppBar(
              titleSpacing: 24,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Text(
                    'AIOconvert',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: strings.saveFolderSelection,
                  onPressed: _showSaveSettings,
                  icon: Icon(
                    Icons.folder_outlined,
                    color: _saveNextToOriginal
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                IconButton(
                  tooltip: strings.settings,
                  onPressed: widget.onOpenSettings,
                  icon: const Icon(Icons.settings_outlined),
                ),
                const SizedBox(width: 12),
              ],
            ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
                      children: [
                        if (Platform.isLinux)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: strings.saveFolderSelection,
                                  onPressed: _showSaveSettings,
                                  icon: Icon(
                                    Icons.folder_outlined,
                                    color: _saveNextToOriginal
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                ),
                                IconButton(
                                  tooltip: strings.settings,
                                  onPressed: widget.onOpenSettings,
                                  icon: const Icon(Icons.settings_outlined),
                                ),
                              ],
                            ),
                          ),
                        Text(
                          strings.heroTitle,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.heroSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        _DropZone(
                          hovering: _isHovering,
                          compact: _jobs.isNotEmpty,
                          onDragEntered: () =>
                              setState(() => _isHovering = true),
                          onDragExited: () =>
                              setState(() => _isHovering = false),
                          onFilesDropped: _addDroppedFiles,
                          onPickFiles: _pickFiles,
                        ),
                        const SizedBox(height: 18),
                        _buildJobsHeader(context),
                        const SizedBox(height: 12),
                        if (_jobs.isEmpty)
                          _buildEmptyState(context)
                        else
                          ..._jobs.map(
                            (job) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildJobCard(context, job),
                            ),
                          ),
                        if (_jobs.isEmpty) ...[
                          const SizedBox(height: 14),
                          _buildFooter(context),
                        ],
                      ],
                    ),
                  ),
                  _buildOutputPanel(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputPanel(BuildContext context) {
    final commonKind = _jobs.isEmpty || _hasMixedKinds
        ? null
        : _jobs.first.kind;
    final formats = commonKind == null
        ? const <OutputFormat>[]
        : mediaFormats[commonKind]!;
    final allFormatValue =
        formats.any((format) => format.extension == _allFormatExtension)
        ? _allFormatExtension
        : null;
    final strings = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 600;
            final formatDropdown = DropdownButtonFormField<String>(
              initialValue: allFormatValue,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: _hasMixedKinds
                    ? strings.setEachFile
                    : strings.chooseFormat,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
              ),
              items: formats
                  .map(
                    (format) => DropdownMenuItem(
                      value: format.extension,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          format.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: commonKind == null ? null : _setAllFormat,
            );
            final formatControl = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                formatDropdown,
                if (_hasMixedKinds)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      strings.mixedMediaWarning,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            );
            final convertButton = FilledButton.icon(
              onPressed: _isConverting
                  ? _cancelConversion
                  : (_canConvert ? _convertAll : null),
              icon: Icon(
                _isConverting ? Icons.stop_rounded : Icons.bolt_rounded,
              ),
              label: Text(
                _isConverting ? strings.stopConversion : strings.convertAll,
              ),
            );
            return narrow
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [Expanded(child: formatControl)]),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity, child: convertButton),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: formatControl),
                      const SizedBox(width: 12),
                      convertButton,
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildJobsHeader(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Row(
      children: [
        Text(
          strings.filesTitle,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 10),
        if (_jobs.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_jobs.length}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        const Spacer(),
        if (_jobs.isNotEmpty && !_isConverting)
          TextButton.icon(
            onPressed: () => setState(() {
              _jobs.clear();
              _allFormatExtension = null;
            }),
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: Text(narrow ? strings.clear : strings.clearQueue),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 30,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 9),
          Text(
            strings.queueEmpty,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            strings.emptySubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, MediaJob job) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final formatDropdown = DropdownButton<String>(
      value: job.outputFormat?.extension,
      hint: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(strings.chooseFormat),
      ),
      isExpanded: true,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      underline: const SizedBox.shrink(),
      borderRadius: BorderRadius.circular(14),
      items: mediaFormats[job.kind]!
          .map(
            (format) => DropdownMenuItem(
              value: format.extension,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(format.label, overflow: TextOverflow.ellipsis),
              ),
            ),
          )
          .toList(),
      onChanged: _isConverting
          ? null
          : (extension) => _setJobFormat(job, extension),
    );
    final metadata = Row(
      children: [
        _KindLabel(kind: job.kind, strings: strings),
        const SizedBox(width: 8),
        Text(
          job.sourceFormat.isEmpty ? 'MEDIA' : job.sourceFormat,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: colors.onSurfaceVariant, letterSpacing: .6),
        ),
        if (job.fileSize != null) ...[
          const SizedBox(width: 8),
          Text(
            '· ${_formatBytes(job.fileSize!)}',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(_kindIcon(job.kind), color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      metadata,
                    ],
                  ),
                ),
                if (!narrow) ...[
                  const SizedBox(width: 14),
                  SizedBox(width: 190, child: formatDropdown),
                  const SizedBox(width: 8),
                ],
                if (job.state == JobState.converting)
                  IconButton(
                    tooltip: strings.cancel,
                    onPressed: _cancelConversion,
                    icon: const Icon(Icons.close_rounded),
                  )
                else if (!_isConverting)
                  IconButton(
                    tooltip: strings.removeFile,
                    onPressed: () => _removeJob(job),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
            if (narrow) ...[const SizedBox(height: 12), formatDropdown],
            if (job.state == JobState.converting) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: job.duration != null && job.duration! > 0
                    ? job.progress
                    : null,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 6),
              Text(
                job.duration != null && job.duration! > 0
                    ? strings.convertingPercent((job.progress * 100).round())
                    : strings.convertingProgress,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
            if (job.state == JobState.complete) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                    color: colors.tertiary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      strings.savedOutput(p.basename(job.outputPath!)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: colors.tertiary),
                    ),
                  ),
                ],
              ),
            ],
            if (job.state == JobState.failed && job.error != null) ...[
              const SizedBox(height: 10),
              Text(
                job.error!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: colors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;
    final narrow = MediaQuery.sizeOf(context).width < 784;
    return Column(
      children: [
        if (narrow && _jobs.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isConverting
                  ? _cancelConversion
                  : (_canConvert ? _convertAll : null),
              icon: Icon(
                _isConverting ? Icons.stop_rounded : Icons.bolt_rounded,
              ),
              label: Text(
                _isConverting ? strings.stopConversion : strings.convertAll,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                Platform.isAndroid
                    ? strings.footerAndroid
                    : strings.footerDesktop,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _MediaInspection {
  const _MediaInspection({
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

class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.hovering,
    required this.compact,
    required this.onDragEntered,
    required this.onDragExited,
    required this.onFilesDropped,
    required this.onPickFiles,
  });

  final bool hovering;
  final bool compact;
  final VoidCallback onDragEntered;
  final VoidCallback onDragExited;
  final ValueChanged<List<DropItem>> onFilesDropped;
  final VoidCallback onPickFiles;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;
    return DropTarget(
      onDragEntered: (_) => onDragEntered(),
      onDragExited: (_) => onDragExited(),
      onDragDone: (details) async => onFilesDropped(details.files),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 20,
          vertical: compact ? 8 : 25,
        ),
        decoration: BoxDecoration(
          color: hovering
              ? colors.primaryContainer.withValues(alpha: .28)
              : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hovering ? colors.primary : colors.outlineVariant,
            width: hovering ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 30 : 48,
              height: compact ? 30 : 48,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.file_upload_outlined, color: colors.primary),
            ),
            SizedBox(height: compact ? 3 : 13),
            Text(
              compact
                  ? (hovering ? strings.dropHover : strings.dropMoreFiles)
                  : (hovering ? strings.dropHover : strings.dropPrompt),
              style:
                  (compact
                          ? Theme.of(context).textTheme.bodyMedium
                          : Theme.of(context).textTheme.titleMedium)
                      ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (!compact) ...[
              const SizedBox(height: 5),
              Text(
                strings.mediaKinds,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onPickFiles,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(strings.browseFiles),
              ),
            ] else ...[
              TextButton.icon(
                onPressed: onPickFiles,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(strings.browseFiles),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KindLabel extends StatelessWidget {
  const _KindLabel({required this.kind, required this.strings});

  final MediaKind kind;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        switch (kind) {
          MediaKind.video => strings.video,
          MediaKind.audio => strings.audio,
          MediaKind.image => strings.image,
        },
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
      ),
    );
  }
}

IconData _kindIcon(MediaKind kind) => switch (kind) {
  MediaKind.video => Icons.movie_outlined,
  MediaKind.audio => Icons.music_note_rounded,
  MediaKind.image => Icons.image_outlined,
};

TextStyle? _eyebrowStyle(BuildContext context) =>
    Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
