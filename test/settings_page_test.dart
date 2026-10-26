import 'package:aioconvert/l10n/generated/app_localizations.dart';
import 'package:aioconvert/pages/settings_page.dart';
import 'package:aioconvert/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Settings button opens the localized settings route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AioConvertApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('About AIOconvert'), findsOneWidget);
    await tester.tap(find.text('About AIOconvert'));
    await tester.pumpAndSettle();
    expect(
      find.text('A local-first multimedia converter powered by FFmpeg.'),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('converter shows compact add and save settings controls', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AioConvertApp());
    await tester.pumpAndSettle();

    expect(find.text('Drag and drop files to convert them'), findsOneWidget);
    expect(find.byTooltip('Save folder selection'), findsOneWidget);

    await tester.tap(find.byTooltip('Save folder selection'));
    await tester.pumpAndSettle();
    expect(find.text('Save folder selection'), findsOneWidget);
    expect(find.text('Save next to original'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'settings page is localized and exposes theme and language options',
    (tester) async {
      Locale? selectedLocale;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsPage(
            themeMode: ThemeMode.dark,
            seedColor: const Color(0xff7c8cff),
            locale: null,
            onThemeModeChanged: (_) {},
            onSeedColorChanged: (_) {},
            onLocaleChanged: (locale) => selectedLocale = locale,
          ),
        ),
      );

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Accent color'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      expect(find.text('Čeština'), findsOneWidget);
      await tester.tap(find.text('Čeština'));
      await tester.pumpAndSettle();
      expect(selectedLocale, const Locale('cs'));
    },
  );
}
