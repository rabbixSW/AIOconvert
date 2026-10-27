import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class JobsHeader extends StatelessWidget {
  const JobsHeader({
    required this.jobCount,
    required this.isConverting,
    required this.onClear,
    super.key,
  });

  final int jobCount;
  final bool isConverting;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
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
        if (jobCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$jobCount',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        const Spacer(),
        if (jobCount > 0 && !isConverting)
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: Text(narrow ? strings.clear : strings.clearQueue),
          ),
      ],
    );
  }
}
