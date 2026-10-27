import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../l10n/generated/app_localizations.dart';
import '../../../media_tools.dart';
import '../../../models/media_job.dart';
import 'kind_label.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    required this.job,
    required this.isConverting,
    required this.onFormatChanged,
    required this.onCancel,
    required this.onRemove,
    super.key,
  });

  final MediaJob job;
  final bool isConverting;
  final ValueChanged<String?> onFormatChanged;
  final VoidCallback onCancel;
  final VoidCallback onRemove;

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
      onChanged: isConverting ? null : onFormatChanged,
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
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded),
                  )
                else if (!isConverting)
                  IconButton(
                    tooltip: strings.removeFile,
                    onPressed: onRemove,
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
