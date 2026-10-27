import 'dart:io';

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class ConversionFooter extends StatelessWidget {
  const ConversionFooter({
    required this.hasJobs,
    required this.isConverting,
    required this.canConvert,
    required this.onConvert,
    required this.onCancel,
    super.key,
  });

  final bool hasJobs;
  final bool isConverting;
  final bool canConvert;
  final VoidCallback onConvert;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;
    final narrow = MediaQuery.sizeOf(context).width < 784;
    return Column(
      children: [
        if (narrow && hasJobs) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isConverting
                  ? onCancel
                  : (canConvert ? onConvert : null),
              icon: Icon(
                isConverting ? Icons.stop_rounded : Icons.bolt_rounded,
              ),
              label: Text(
                isConverting ? strings.stopConversion : strings.convertAll,
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
}
