import 'package:aioconvert/l10n/generated/app_localizations.dart';
import 'package:aioconvert/pages/settings_page.dart';
import 'package:aioconvert/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Linux Settings menu opens the localized settings route', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AioConvertApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
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
      expect(find.text('Language'), findsNWidgets(2));
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
