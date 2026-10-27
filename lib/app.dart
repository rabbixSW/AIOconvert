import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/generated/app_localizations.dart';
import 'pages/converter_page.dart';
import 'pages/settings_page.dart';

class AioConvertApp extends StatefulWidget {
  const AioConvertApp({super.key});

  @override
  State<AioConvertApp> createState() => _AioConvertAppState();
}

class _AioConvertAppState extends State<AioConvertApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  ThemeMode _themeMode = ThemeMode.dark;
  Color _seedColor = const Color(0xff7c8cff);
  Locale? _locale;
  late final Locale? _systemLocale;

  @override
  void initState() {
    super.initState();
    _systemLocale = _resolveSystemLocale();
    _loadSettings();
  }

  Locale? _resolveSystemLocale() {
    for (final deviceLocale
        in WidgetsBinding.instance.platformDispatcher.locales) {
      for (final supportedLocale in AppLocalizations.supportedLocales) {
        if (supportedLocale.languageCode == deviceLocale.languageCode) {
          return supportedLocale;
        }
      }
    }
    return null;
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final themeName = preferences.getString('themeMode') ?? 'dark';
    final colorValue = preferences.getInt('seedColor') ?? 0xff7c8cff;
    final languageCode = preferences.getString('languageCode');
    if (!mounted) return;
    setState(() {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeName,
        orElse: () => ThemeMode.dark,
      );
      _seedColor = Color(colorValue);
      _locale = languageCode == null || languageCode == 'system'
          ? null
          : Locale(languageCode);
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

  Future<void> _setLocale(Locale? locale) async {
    setState(() => _locale = locale);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'languageCode',
      locale?.languageCode ?? 'system',
    );
  }

  Future<void> _openSettings() async {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;
    await navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(
          themeMode: _themeMode,
          seedColor: _seedColor,
          locale: _locale,
          systemLocale: _systemLocale,
          onThemeModeChanged: _setThemeMode,
          onSeedColorChanged: _setSeedColor,
          onLocaleChanged: _setLocale,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'AIOconvert',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ConverterPage(onOpenSettings: _openSettings),
    );
  }
}
