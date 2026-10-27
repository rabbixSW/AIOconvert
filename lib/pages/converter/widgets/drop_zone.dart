import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class DropZone extends StatelessWidget {
  const DropZone({
    required this.hovering,
    required this.compact,
    required this.onDragEntered,
    required this.onDragExited,
    required this.onFilesDropped,
    required this.onPickFiles,
    super.key,
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
    final dropZone = AnimatedContainer(
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
            Platform.isAndroid
                ? (compact
                      ? strings.selectMoreFiles
                      : strings.selectFilesToConvert)
                : compact
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
              label: Text(
                Platform.isAndroid ? strings.selectFiles : strings.browseFiles,
              ),
            ),
          ] else ...[
            TextButton.icon(
              onPressed: onPickFiles,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                Platform.isAndroid ? strings.selectFiles : strings.browseFiles,
              ),
            ),
          ],
        ],
      ),
    );
    if (Platform.isAndroid) return dropZone;
    return DropTarget(
      onDragEntered: (_) => onDragEntered(),
      onDragExited: (_) => onDragExited(),
      onDragDone: (details) async => onFilesDropped(details.files),
      child: dropZone,
    );
  }
}
