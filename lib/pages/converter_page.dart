import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations.dart';
import '../media_tools.dart';
import '../models/media_inspection.dart';
import '../models/media_job.dart';
import 'converter/widgets/conversion_footer.dart';
import 'converter/widgets/drop_zone.dart';
import 'converter/widgets/empty_queue.dart';
import 'converter/widgets/job_card.dart';
import 'converter/widgets/jobs_header.dart';
import 'converter/widgets/output_panel.dart';

const _androidOutputFolderChannel = MethodChannel(
  'com.aioconvert.aioconvert/output_folder',
);

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
  Process? _activeFfmpegProcess;
  String? _outputDirectory;
  String? _outputDirectoryLabel;
  String? _allFormatExtension;
  bool _saveNextToOriginal = false;
  bool _hasAndroidOutputFolderPermission = false;

  bool get _hasMixedKinds => _jobs.map((job) => job.kind).toSet().length > 1;
  bool get _usesSystemFfmpeg => Platform.isLinux || Platform.isWindows;
  bool get _isDesktop => Platform.isLinux || Platform.isWindows;
  bool get _canConvert =>
      _jobs.isNotEmpty &&
      !_isConverting &&
      (_outputDirectory != null || _saveNextToOriginal) &&
      _jobs.every((job) => job.outputFormat != null);

  @override
  void initState() {
    super.initState();
    _loadOutputDirectory();
  }

  Future<void> _loadOutputDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final preferences = await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      final folder = await _getAndroidOutputFolder();
      if (!mounted) return;
      setState(() {
        _outputDirectory = folder?['uri'] ?? appDirectory.path;
        _outputDirectoryLabel = folder?['name'] ?? 'appStorage';
        _hasAndroidOutputFolderPermission = folder != null;
      });
      if (folder == null &&
          !(preferences.getBool('androidDownloadsPrompted') ?? false)) {
        await preferences.setBool('androidDownloadsPrompted', true);
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _promptForAndroidOutputFolder();
        });
      }
      return;
    }

    final saveNextToOriginal =
        preferences.getBool('saveNextToOriginal') ?? false;
    final savedPath = preferences.getString('outputDirectory');
    final downloadsDirectory = await getDownloadsDirectory();
    final homeDirectory = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    final defaultPath =
        downloadsDirectory?.path ??
        (homeDirectory == null ? null : p.join(homeDirectory, 'Downloads'));
    if (defaultPath == null) {
      throw StateError('Could not determine the Downloads folder.');
    }
    final directory = Directory(savedPath ?? defaultPath);
    final selectedDirectory = await directory.exists()
        ? directory.path
        : defaultPath;
    await Directory(selectedDirectory).create(recursive: true);
    if (!mounted) return;
    setState(() {
      _outputDirectory = selectedDirectory;
      _outputDirectoryLabel = p.basename(selectedDirectory);
      _saveNextToOriginal = saveNextToOriginal;
    });
  }

  Future<Map<String, String>?> _getAndroidOutputFolder() async {
    final folder = await _androidOutputFolderChannel
        .invokeMapMethod<String, String>('getOutputFolder');
    return folder;
  }

  Future<Map<String, String>?> _chooseAndroidOutputFolder() async {
    try {
      return await _androidOutputFolderChannel.invokeMapMethod<String, String>(
        'chooseOutputFolder',
      );
    } on PlatformException catch (error) {
      if (mounted) {
        _showMessage(error.message ?? error.code);
      }
      return null;
    }
  }

  Future<void> _promptForAndroidOutputFolder() async {
    if (!mounted) return;
    final strings = AppLocalizations.of(context)!;
    final chooseFolder = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.androidOutputFolderTitle),
        content: Text(strings.androidOutputFolderMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.androidOutputFolderLater),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.androidOutputFolderButton),
          ),
        ],
      ),
    );
    if (chooseFolder == true) {
      final folder = await _chooseAndroidOutputFolder();
      if (folder != null) {
        await _setAndroidOutputFolder(folder);
      } else if (mounted) {
        _showMessage(strings.androidOutputFolderNotGranted);
      }
    }
  }

  Future<void> _setAndroidOutputFolder(Map<String, String> folder) async {
    final uri = folder['uri'];
    final name = folder['name'];
    if (uri == null || name == null) {
      throw StateError('The selected output folder is invalid.');
    }
    if (!mounted) return;
    setState(() {
      _outputDirectory = uri;
      _outputDirectoryLabel = name;
      _hasAndroidOutputFolderPermission = true;
    });
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('outputDirectory', uri);
  }

  Future<void> _showSaveSettings() async {
    final strings = AppLocalizations.of(context)!;
    var selectedDirectory = _outputDirectory;
    var selectedDirectoryLabel = _outputDirectoryLabel;
    var hasAndroidFolderPermission = _hasAndroidOutputFolderPermission;
    var saveNextToOriginal = _saveNextToOriginal;
    final result =
        await showDialog<
          ({
            String? directory,
            String? directoryLabel,
            bool hasAndroidFolderPermission,
            bool nextToOriginal,
          })
        >(
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
                      onChanged: (value) => setDialogState(
                        () => saveNextToOriginal = value ?? false,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 12),
                      child: Text(
                        strings.saveNextToOriginalAndroidUnavailable,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(strings.saveTo, style: _eyebrowStyle(context)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            (selectedDirectoryLabel == 'appStorage'
                                    ? strings.appStorage
                                    : selectedDirectoryLabel) ??
                                (selectedDirectory == null
                                    ? strings.loadingFolder
                                    : p.basename(selectedDirectory ?? '')),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: strings.chooseFolder,
                        onPressed: saveNextToOriginal
                            ? null
                            : () async {
                                if (Platform.isAndroid) {
                                  final folder =
                                      await _chooseAndroidOutputFolder();
                                  if (folder != null) {
                                    await _setAndroidOutputFolder(folder);
                                    setDialogState(() {
                                      selectedDirectory = folder['uri'];
                                      selectedDirectoryLabel = folder['name'];
                                      hasAndroidFolderPermission = true;
                                    });
                                  }
                                } else {
                                  final path =
                                      await FilePicker.getDirectoryPath(
                                        dialogTitle: strings.chooseFolder,
                                        initialDirectory: selectedDirectory,
                                      );
                                  if (path != null) {
                                    setDialogState(() {
                                      selectedDirectory = path;
                                      selectedDirectoryLabel = p.basename(path);
                                    });
                                  }
                                }
                              },
                        icon: const Icon(Icons.folder_open_outlined),
                      ),
                    ],
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
                    directoryLabel: selectedDirectoryLabel,
                    hasAndroidFolderPermission: hasAndroidFolderPermission,
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
      _outputDirectoryLabel = result.directoryLabel;
      _hasAndroidOutputFolderPermission = result.hasAndroidFolderPermission;
      _saveNextToOriginal = result.nextToOriginal;
    });
    final preferences = await SharedPreferences.getInstance();
    if (result.directory != null && !Platform.isAndroid) {
      await preferences.setString('outputDirectory', result.directory!);
    }
    if (!Platform.isAndroid) {
      await preferences.setBool('saveNextToOriginal', result.nextToOriginal);
    }
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

  Future<MediaInspection> _inspectMedia(String path) async {
    if (_usesSystemFfmpeg) {
      final ffprobe = _mediaToolExecutable('ffprobe');
      final result = await Process.run(ffprobe, [
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
          ffprobe,
          [path],
          result.stderr.toString().trim(),
          result.exitCode,
        );
      }

      final data = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
      final format = data['format'] as Map<String, dynamic>? ?? {};
      final streams = data['streams'] as List<dynamic>? ?? [];
      return MediaInspection(
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
    return MediaInspection(
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

  String _mediaToolExecutable(String tool) {
    if (!Platform.isWindows) return tool;
    final bundledExecutable = p.join(
      p.dirname(Platform.resolvedExecutable),
      '$tool.exe',
    );
    return File(bundledExecutable).existsSync()
        ? bundledExecutable
        : '$tool.exe';
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
    final outputFolderNotReady = AppLocalizations.of(context)!
        .outputFolderNotReady;
    final directoryPath = Platform.isAndroid
        ? (await getTemporaryDirectory()).path
        : _saveNextToOriginal
        ? p.dirname(_ffmpegInputPath(job.path))
        : _outputDirectory;
    if (directoryPath == null) {
      throw StateError(outputFolderNotReady);
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
      if (_usesSystemFfmpeg) {
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
      var savedOutputPath = outputPath;
      if (Platform.isAndroid) {
        savedOutputPath = await _saveAndroidOutput(outputPath, job);
        await File(outputPath).delete();
      }
      setState(() {
        job.state = JobState.complete;
        job.progress = 1;
        job.outputPath = savedOutputPath;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        job.state = JobState.failed;
        job.error = error.toString();
      });
    }
  }

  Future<String> _saveAndroidOutput(String temporaryPath, MediaJob job) async {
    final requestedName =
        '${p.basenameWithoutExtension(job.name)}_converted.${job.outputFormat!.extension}';
    if (!_hasAndroidOutputFolderPermission) {
      final directory = Directory(_outputDirectory!);
      await directory.create(recursive: true);
      final stem = p.basenameWithoutExtension(requestedName);
      final extension = p.extension(requestedName);
      var suffix = 0;
      late String candidate;
      do {
        candidate = p.join(
          directory.path,
          '$stem${suffix == 0 ? '' : '_$suffix'}$extension',
        );
        suffix++;
      } while (await File(candidate).exists());
      await File(temporaryPath).copy(candidate);
      return candidate;
    }
    final savedName = await _androidOutputFolderChannel.invokeMethod<String>(
      'saveOutputFile',
      {
        'sourcePath': temporaryPath,
        'displayName': requestedName,
        'extension': job.outputFormat!.extension,
      },
    );
    if (savedName == null) {
      throw StateError('Android did not return the saved output file name.');
    }
    return savedName;
  }

  Future<void> _convertWithSystemFfmpeg(
    MediaJob job,
    List<String> arguments,
    String outputPath,
  ) async {
    final noOutputMessage = AppLocalizations.of(context)!.ffmpegNoOutput;
    final ffmpeg = _mediaToolExecutable('ffmpeg');
    final process = await Process.start(ffmpeg, arguments);
    _activeFfmpegProcess = process;
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
    _activeFfmpegProcess = null;

    if (exitCode != 0) {
      final reason = stderr
          .toString()
          .trim()
          .split('\n')
          .where((line) => line.isNotEmpty)
          .lastOrNull;
      throw ProcessException(
        ffmpeg,
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
    if (_usesSystemFfmpeg) {
      _activeFfmpegProcess?.kill(
        Platform.isWindows ? ProcessSignal.sigterm : ProcessSignal.sigint,
      );
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
      appBar: _isDesktop
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
                        if (_isDesktop)
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
                          Platform.isAndroid
                              ? strings.selectFilesToConvert
                              : strings.heroTitle,
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
                        DropZone(
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
                        JobsHeader(
                          jobCount: _jobs.length,
                          isConverting: _isConverting,
                          onClear: () => setState(() {
                            _jobs.clear();
                            _allFormatExtension = null;
                          }),
                        ),
                        const SizedBox(height: 12),
                        if (_jobs.isEmpty)
                          const EmptyQueue()
                        else
                          ..._jobs.map(
                            (job) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: JobCard(
                                job: job,
                                isConverting: _isConverting,
                                onFormatChanged: (extension) =>
                                    _setJobFormat(job, extension),
                                onCancel: _cancelConversion,
                                onRemove: () => _removeJob(job),
                              ),
                            ),
                          ),
                        if (_jobs.isEmpty) ...[
                          const SizedBox(height: 14),
                          ConversionFooter(
                            hasJobs: false,
                            isConverting: _isConverting,
                            canConvert: _canConvert,
                            onConvert: _convertAll,
                            onCancel: _cancelConversion,
                          ),
                        ],
                      ],
                    ),
                  ),
                  OutputPanel(
                    jobs: _jobs,
                    hasMixedKinds: _hasMixedKinds,
                    allFormatExtension: _allFormatExtension,
                    isConverting: _isConverting,
                    canConvert: _canConvert,
                    onSetAllFormat: _setAllFormat,
                    onConvert: _convertAll,
                    onCancel: _cancelConversion,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle? _eyebrowStyle(BuildContext context) =>
    Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
