import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.themeMode,
    required this.seedColor,
    required this.locale,
    required this.onThemeModeChanged,
    required this.onSeedColorChanged,
    required this.onLocaleChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final Color seedColor;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Color> onSeedColorChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _hexController;
  late ThemeMode _themeMode;
  late Color _seedColor;
  late Locale? _locale;
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
    _themeMode = widget.themeMode;
    _seedColor = widget.seedColor;
    _locale = widget.locale;
    _hexController = TextEditingController(
      text: _seedColor.toARGB32().toRadixString(16).substring(2),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _applyCustomColor(AppLocalizations strings) {
    final value = _hexController.text.trim().replaceFirst('#', '');
    final parsed = value.length == 6 ? int.tryParse(value, radix: 16) : null;
    if (parsed == null) {
      setState(() => _colorError = strings.invalidHexColor);
      return;
    }
    final color = Color(0xff000000 | parsed);
    widget.onSeedColorChanged(color);
    setState(() {
      _seedColor = color;
      _colorError = null;
    });
  }

  String _languageLabel(AppLocalizations strings, String code) =>
      switch (code) {
        'cs' => strings.czech,
        'de' => strings.german,
        'es' => strings.spanish,
        'fr' => strings.french,
        'it' => strings.italian,
        'nl' => strings.dutch,
        'pl' => strings.polish,
        'pt' => strings.portuguese,
        _ => strings.english,
      };

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final localeCode = _locale?.languageCode ?? 'system';
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings), centerTitle: false),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Text(
                  strings.appearance,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 18),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(strings.dark),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(strings.light),
                      icon: const Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(strings.system),
                      icon: const Icon(Icons.brightness_auto_outlined),
                    ),
                  ],
                  selected: {_themeMode},
                  onSelectionChanged: (selection) {
                    final mode = selection.first;
                    setState(() => _themeMode = mode);
                    widget.onThemeModeChanged(mode);
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  strings.accentColor,
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
                            setState(() {
                              _seedColor = color;
                              _colorError = null;
                            });
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
                                color: _seedColor == color
                                    ? colors.onSurface
                                    : Colors.transparent,
                              ),
                            ),
                            child: _seedColor == color
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
                          labelText: strings.customHexColor,
                          prefixText: '#',
                          errorText: _colorError,
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => _applyCustomColor(strings),
                      child: Text(strings.apply),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  strings.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: localeCode,
                  decoration: InputDecoration(labelText: strings.language),
                  items: [
                    DropdownMenuItem(
                      value: 'system',
                      child: Text(
                        '${strings.system} (${_languageLabel(strings, Localizations.localeOf(context).languageCode)})',
                      ),
                    ),
                    ...AppLocalizations.supportedLocales.map(
                      (locale) => DropdownMenuItem(
                        value: locale.languageCode,
                        child: Text(
                          _languageLabel(strings, locale.languageCode),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    final locale = value == null || value == 'system'
                        ? null
                        : Locale(value);
                    setState(() => _locale = locale);
                    widget.onLocaleChanged(locale);
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  strings.helpMenu,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(strings.about),
                    subtitle: Text(strings.aboutVersion),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'AIOconvert',
                      applicationVersion: '1.0.0',
                      applicationLegalese: strings.aboutVersion,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
