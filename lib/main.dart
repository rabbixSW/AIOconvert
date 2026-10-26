import 'dart:async';
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

import 'media_tools.dart';

void main() => runApp(const AioConvertApp());

class AioConvertApp extends StatefulWidget {
  const AioConvertApp({super.key});

  @override
  State<AioConvertApp> createState() => _AioConvertAppState();
}

class _AioConvertAppState extends State<AioConvertApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Color _seedColor = const Color(0xff7c8cff);
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final themeName = preferences.getString('themeMode') ?? 'dark';
    final colorValue = preferences.getInt('seedColor') ?? 0xff7c8cff;
    if (!mounted) return;
    setState(() {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeName,
        orElse: () => ThemeMode.dark,
      );
      _seedColor = Color(colorValue);
      _settingsLoaded = true;
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('themeMode', mode.name);
  }

  Future<void> _setSeedColor(Color color) async {
    setState(() => _seedColor = color);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('seedColor', color.toARGB32());
  }

  ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xff111318)
          : const Color(0xfff6f7fb),
      cardTheme: CardThemeData(
        color: brightness == Brightness.dark
            ? const Color(0xff1a1c23)
            : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xff111318)
            : const Color(0xfff6f7fb),
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? const Color(0xff22252d)
            : const Color(0xfff0f1f6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SettingsSheet(
        themeMode: _themeMode,
        seedColor: _seedColor,
        onThemeModeChanged: _setThemeMode,
        onSeedColorChanged: _setSeedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIOconvert',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _themeMode,
      home: ConverterPage(
        settingsLoaded: _settingsLoaded,
        onOpenSettings: _openSettings,
      ),
    );
  }
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({
    super.key,
    required this.themeMode,
    required this.seedColor,
    required this.onThemeModeChanged,
    required this.onSeedColorChanged,
  });

  final ThemeMode themeMode;
  final Color seedColor;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Color> onSeedColorChanged;

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late final TextEditingController _hexController;
  String? _colorError;

  static const _colors = <Color>[
    Color(0xff7c8cff),
    Color(0xff49c5b6),
    Color(0xffffa451),
    Color(0xffe779aa),
    Color(0xffa68bfa),
    Color(0xffe56363),
    Color(0xff68a8ff),
    Color(0xffb0bdc6),
  ];

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(
      text: widget.seedColor.toARGB32().toRadixString(16).substring(2),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _applyCustomColor() {
    final value = _hexController.text.trim().replaceFirst('#', '');
    final parsed = value.length == 6 ? int.tryParse(value, radix: 16) : null;
    if (parsed == null) {
      setState(() => _colorError = 'Enter a valid 6-digit hex color.');
      return;
    }
    widget.onSeedColorChanged(Color(0xff000000 | parsed));
    setState(() => _colorError = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto_outlined),
                  ),
                ],
                selected: {widget.themeMode},
                onSelectionChanged: (selection) =>
                    widget.onThemeModeChanged(selection.first),
              ),
              const SizedBox(height: 24),
              Text(
                'Accent color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors
                    .map(
                      (color) => InkWell(
                        onTap: () {
                          widget.onSeedColorChanged(color);
                          _hexController.text = color
                              .toARGB32()
                              .toRadixString(16)
                              .substring(2);
                          setState(() => _colorError = null);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              width: 3,
                              color: widget.seedColor == color
                                  ? colors.onSurface
                                  : Colors.transparent,
                            ),
                          ),
                          child: widget.seedColor == color
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      maxLength: 6,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Custom hex color',
                        prefixText: '#',
                        errorText: _colorError,
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _applyCustomColor,
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class ConverterPage extends StatefulWidget {
  const ConverterPage({
    required this.settingsLoaded,
    required this.onOpenSettings,
    super.key,
  });

  final bool settingsLoaded;
  final VoidCallback onOpenSettings;

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final List<MediaJob> _jobs = [];
  bool _isHovering = false;
  bool _isConverting = false;
  bool _cancelRequested = false;
  String? _outputDirectory;
  String? _allFormatExtension;

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
    setState(() => _outputDirectory = selectedDirectory);
  }

  Future<void> _chooseOutputDirectory() async {
    final path = await FilePicker.getDirectoryPath(
      dialogTitle: 'Choose an output folder',
      initialDirectory: _outputDirectory,
    );
    if (path == null || !mounted) return;
    setState(() => _outputDirectory = path);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('outputDirectory', path);
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(type: FileType.any);
    for (final file in result) {
      await _addFile(
        file.path ?? file.uri.toString(),
        file.name,
        fileSize: file.lengthSync(),
      );
    }
  }

  Future<void> _addDroppedFiles(List<DropItem> items) async {
    for (final item in items) {
      if (item is DropItemDirectory) {
        _showMessage('Please drop files, not folders.');
        continue;
      }
      await _addFile(item.path, item.name, fileSize: await item.length());
    }
  }

  Future<void> _addFile(String path, String name, {int? fileSize}) async {
    if (_jobs.any((job) => job.path == path)) return;
    try {
      final probePath = _ffmpegInputPath(path);
      final probeSession = await FFprobeKit.getMediaInformation(probePath);
      final information = probeSession.getMediaInformation();
      if (information == null) {
        throw const FormatException('FFprobe could not read this media file.');
      }
      final kind = classifyMedia(
        fileName: name,
        streamTypes: information.getStreams().map(
          (stream) => stream.getType() ?? '',
        ),
      );
      if (kind == null) {
        throw const FormatException(
          'The selected file does not contain a supported audio, video, or image stream.',
        );
      }

      final duration = double.tryParse(information.getDuration() ?? '');
      final job = MediaJob(
        id: '${DateTime.now().microsecondsSinceEpoch}-${_jobs.length}',
        path: path,
        name: name,
        kind: kind,
        sourceFormat: p.extension(name).replaceFirst('.', '').toUpperCase(),
        fileSize: fileSize ?? int.tryParse(information.getSize() ?? ''),
        duration: duration,
        outputFormat: _hasMixedKinds
            ? null
            : formatFor(kind, _allFormatExtension ?? ''),
      );
      if (!mounted) return;
      setState(() => _jobs.add(job));
    } catch (error) {
      _showMessage('Could not inspect "$name": $error');
    }
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
    final directoryPath = _outputDirectory;
    if (directoryPath == null) {
      throw StateError('The output folder is not ready yet.');
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
    if (_cancelRequested) {
      _showMessage('Conversion stopped. $completed file(s) completed.');
    } else if (failed > 0) {
      _showMessage(
        '$completed completed, $failed failed. See each file for details.',
      );
    } else {
      _showMessage('$completed file(s) converted successfully.');
    }
  }

  Future<void> _convert(MediaJob job) async {
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
        throw const FileSystemException(
          'FFmpeg reported success but no output file was created.',
        );
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

  Future<void> _cancelConversion() async {
    _cancelRequested = true;
    await FFmpegKit.cancel();
  }

  void _removeJob(MediaJob job) {
    if (_isConverting) return;
    setState(() {
      _jobs.remove(job);
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
    return Scaffold(
      appBar: AppBar(
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
              child: Icon(Icons.swap_horiz_rounded, color: colors.primary),
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
            tooltip: 'Settings',
            onPressed: widget.onOpenSettings,
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              children: [
                Text(
                  'Make every format work for you.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Convert videos, audio and images privately on your device.',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                _DropZone(
                  hovering: _isHovering,
                  onDragEntered: () => setState(() => _isHovering = true),
                  onDragExited: () => setState(() => _isHovering = false),
                  onFilesDropped: _addDroppedFiles,
                  onPickFiles: _pickFiles,
                ),
                const SizedBox(height: 28),
                _buildOutputPanel(context),
                const SizedBox(height: 24),
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
                const SizedBox(height: 14),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutputPanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 580;
            final formatControl = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FORMAT ALL', style: _eyebrowStyle(context)),
                const SizedBox(height: 8),
                SizedBox(
                  width: narrow ? double.infinity : 230,
                  child: DropdownButtonFormField<String>(
                    initialValue: allFormatValue,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: _hasMixedKinds
                          ? 'Set each file separately'
                          : 'Choose a format',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                    ),
                    items: formats
                        .map(
                          (format) => DropdownMenuItem(
                            value: format.extension,
                            child: Text(
                              format.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: commonKind == null ? null : _setAllFormat,
                  ),
                ),
              ],
            );
            final folderControl = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SAVE TO', style: _eyebrowStyle(context)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: Platform.isAndroid ? null : _chooseOutputDirectory,
                  icon: const Icon(Icons.folder_open_outlined, size: 18),
                  label: Text(
                    _outputDirectory == null
                        ? 'Loading folder…'
                        : Platform.isAndroid
                        ? 'App storage'
                        : p.basename(_outputDirectory!),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
            return narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      formatControl,
                      const SizedBox(height: 16),
                      folderControl,
                      if (_hasMixedKinds) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Mixed media detected — choose a compatible output for every file.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: formatControl),
                      const SizedBox(width: 24),
                      folderControl,
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _canConvert ? _convertAll : null,
                        icon: Icon(
                          _isConverting ? Icons.sync : Icons.bolt_rounded,
                        ),
                        label: Text(
                          _isConverting ? 'Converting…' : 'Convert all',
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildJobsHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Row(
      children: [
        Text(
          'Your files',
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
            label: Text(narrow ? 'Clear' : 'Clear list'),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            'Your conversion queue is empty',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a file to see its detected type and compatible formats.',
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
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final formatDropdown = DropdownButton<String>(
      value: job.outputFormat?.extension,
      hint: const Text('Choose format'),
      isExpanded: true,
      underline: const SizedBox.shrink(),
      borderRadius: BorderRadius.circular(14),
      items: mediaFormats[job.kind]!
          .map(
            (format) => DropdownMenuItem(
              value: format.extension,
              child: Text(format.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: _isConverting
          ? null
          : (extension) => _setJobFormat(job, extension),
    );
    final metadata = Row(
      children: [
        _KindLabel(kind: job.kind),
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
                    tooltip: 'Cancel conversion',
                    onPressed: _cancelConversion,
                    icon: const Icon(Icons.close_rounded),
                  )
                else if (!_isConverting)
                  IconButton(
                    tooltip: 'Remove file',
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
                    ? '${(job.progress * 100).round()}% · converting'
                    : 'Converting…',
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
                      'Saved to ${p.basename(job.outputPath!)}',
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
    final narrow = MediaQuery.sizeOf(context).width < 628;
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
              label: Text(_isConverting ? 'Stop conversion' : 'Convert all'),
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
                    ? 'Files are processed on your device · outputs are stored in app documents'
                    : 'Files are processed on your device · no uploads',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
        if (!widget.settingsLoaded)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Loading preferences…',
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
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

class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.hovering,
    required this.onDragEntered,
    required this.onDragExited,
    required this.onFilesDropped,
    required this.onPickFiles,
  });

  final bool hovering;
  final VoidCallback onDragEntered;
  final VoidCallback onDragExited;
  final ValueChanged<List<DropItem>> onFilesDropped;
  final VoidCallback onPickFiles;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DropTarget(
      onDragEntered: (_) => onDragEntered(),
      onDragExited: (_) => onDragExited(),
      onDragDone: (details) async => onFilesDropped(details.files),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.file_upload_outlined, color: colors.primary),
            ),
            const SizedBox(height: 13),
            Text(
              hovering ? 'Drop files to add them' : 'Drop your files here',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(
              'Video · audio · images',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onPickFiles,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Browse files'),
            ),
          ],
        ),
      ),
    );
  }
}

class _KindLabel extends StatelessWidget {
  const _KindLabel({required this.kind});

  final MediaKind kind;

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
        kind.name.toUpperCase(),
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
