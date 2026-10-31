import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../../l10n/generated/app_localizations.dart';
import '../../../media_tools.dart';
import '../../../models/media_job.dart';
import 'kind_label.dart';

class JobCard extends StatefulWidget {
  const JobCard({
    required this.job,
    required this.isConverting,
    required this.onFormatChanged,
    required this.onOutputNameChanged,
    required this.onCancel,
    required this.onRemove,
    super.key,
  });

  final MediaJob job;
  final bool isConverting;
  final ValueChanged<String?> onFormatChanged;
  final ValueChanged<String?> onOutputNameChanged;
  final VoidCallback onCancel;
  final VoidCallback onRemove;

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _displayName);
    _nameFocusNode = FocusNode()..addListener(_handleNameFocusChange);
  }

  @override
  void didUpdateWidget(covariant JobCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditingName &&
        (oldWidget.job.name != widget.job.name ||
            oldWidget.job.outputName != widget.job.outputName)) {
      _nameController.text = _displayName;
    }
  }

  @override
  void dispose() {
    _nameFocusNode
      ..removeListener(_handleNameFocusChange)
      ..dispose();
    _nameController.dispose();
    super.dispose();
  }

  String get _displayName => widget.job.outputName ?? widget.job.name;

  void _startEditingName() {
    if (widget.isConverting) return;
    _nameController.text = _displayName;
    _nameController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _nameController.text.length,
    );
    setState(() => _isEditingName = true);
  }

  void _handleNameFocusChange() {
    if (!_nameFocusNode.hasFocus && _isEditingName) {
      _finishNameEditing(save: true);
    }
  }

  KeyEventResult _handleNameKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _finishNameEditing(save: false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _finishNameEditing({required bool save}) {
    if (!_isEditingName) return;
    final typedName = _nameController.text.trim();
    final hasValidName =
        typedName.isNotEmpty &&
        typedName != '.' &&
        typedName != '..' &&
        p.basename(typedName) == typedName &&
        p.basenameWithoutExtension(typedName).isNotEmpty;
    final newName = save && hasValidName ? typedName : _displayName;
    setState(() => _isEditingName = false);
    _nameController.text = newName;
    if (save && newName != widget.job.outputName) {
      widget.onOutputNameChanged(newName);
    }
    _nameFocusNode.unfocus();
  }

  void _restoreOriginalName() {
    _nameController.text = widget.job.name;
    widget.onOutputNameChanged(null);
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final isConverting = widget.isConverting;
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
      onChanged: isConverting ? null : widget.onFormatChanged,
    );
    final metadata = Row(
      children: [
        KindLabel(kind: job.kind, strings: strings),
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
                  child: Icon(kindIcon(job.kind), color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _isEditingName
                                ? Focus(
                                    onKeyEvent: _handleNameKey,
                                    child: TextField(
                                      controller: _nameController,
                                      focusNode: _nameFocusNode,
                                      autofocus: true,
                                      maxLines: 1,
                                      textInputAction: TextInputAction.done,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                          RegExp(r'[/\\:*?"<>|\u0000-\u001F]'),
                                        ),
                                      ],
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      onSubmitted: (_) =>
                                          _finishNameEditing(save: true),
                                      onTapOutside: (_) =>
                                          _finishNameEditing(save: true),
                                    ),
                                  )
                                : InkWell(
                                    onTap: isConverting
                                        ? null
                                        : _startEditingName,
                                    child: Text(
                                      _displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 4),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: AnimatedOpacity(
                              opacity: job.outputName == null ? 0 : 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              child: IgnorePointer(
                                ignoring:
                                    job.outputName == null || isConverting,
                                child: ExcludeSemantics(
                                  excluding: job.outputName == null,
                                  child: IconButton(
                                    tooltip: strings.restoreFileName,
                                    onPressed:
                                        job.outputName == null || isConverting
                                        ? null
                                        : _restoreOriginalName,
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.undo_rounded),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close_rounded),
                  )
                else if (!isConverting)
                  IconButton(
                    tooltip: strings.removeFile,
                    onPressed: widget.onRemove,
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
}
