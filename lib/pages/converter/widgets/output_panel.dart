import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../media_tools.dart';
import '../../../models/media_job.dart';

class OutputPanel extends StatelessWidget {
  const OutputPanel({
    required this.jobs,
    required this.hasMixedKinds,
    required this.allFormatExtension,
    required this.isConverting,
    required this.canConvert,
    required this.onSetAllFormat,
    required this.onConvert,
    required this.onCancel,
    super.key,
  });

  final List<MediaJob> jobs;
  final bool hasMixedKinds;
  final String? allFormatExtension;
  final bool isConverting;
  final bool canConvert;
  final ValueChanged<String?> onSetAllFormat;
  final VoidCallback onConvert;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final commonKind = jobs.isEmpty || hasMixedKinds ? null : jobs.first.kind;
    final formats = commonKind == null
        ? const <OutputFormat>[]
        : mediaFormats[commonKind]!;
    final allFormatValue =
        formats.any((format) => format.extension == allFormatExtension)
        ? allFormatExtension
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
                hintText: hasMixedKinds
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
              onChanged: commonKind == null ? null : onSetAllFormat,
            );
            final formatControl = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                formatDropdown,
                if (hasMixedKinds)
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
              onPressed: isConverting
                  ? onCancel
                  : (canConvert ? onConvert : null),
              icon: Icon(
                isConverting ? Icons.stop_rounded : Icons.bolt_rounded,
              ),
              label: Text(
                isConverting ? strings.stopConversion : strings.convertAll,
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
}
