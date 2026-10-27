import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../media_tools.dart';

class KindLabel extends StatelessWidget {
  const KindLabel({required this.kind, required this.strings, super.key});

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

IconData kindIcon(MediaKind kind) => switch (kind) {
  MediaKind.video => Icons.movie_outlined,
  MediaKind.audio => Icons.music_note_rounded,
  MediaKind.image => Icons.image_outlined,
};
