// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settings => 'Einstellungen';

  @override
  String get fileMenu => 'Datei';

  @override
  String get helpMenu => 'Hilfe';

  @override
  String get about => 'Über AIOconvert';

  @override
  String get quit => 'Beenden';

  @override
  String get heroTitle => 'Jedes Format im Griff.';

  @override
  String get heroSubtitle =>
      'Videos, Audio und Bilder direkt auf deinem Gerät konvertieren.';

  @override
  String get dropPrompt => 'Dateien hier ablegen';

  @override
  String get dropHover => 'Dateien zum Hinzufügen ablegen';

  @override
  String get mediaKinds => 'Video · Audio · Bilder';

  @override
  String get browseFiles => 'Dateien auswählen';

  @override
  String get formatAll => 'FORMAT FÜR ALLE';

  @override
  String get saveTo => 'SPEICHERN IN';

  @override
  String get loadingFolder => 'Ordner wird geladen…';

  @override
  String get appStorage => 'App-Speicher';

  @override
  String get chooseFormat => 'Format auswählen';

  @override
  String get setEachFile => 'Format für jede Datei festlegen';

  @override
  String get mixedMediaWarning =>
      'Verschiedene Medientypen erkannt — wähle für jede Datei ein passendes Format.';

  @override
  String get filesTitle => 'Deine Dateien';

  @override
  String get clearQueue => 'Liste leeren';

  @override
  String get clear => 'Leeren';

  @override
  String get queueEmpty => 'Die Warteschlange ist leer';

  @override
  String get emptySubtitle =>
      'Füge eine Datei hinzu, um Typ und kompatible Formate zu sehen.';

  @override
  String get video => 'VIDEO';

  @override
  String get audio => 'AUDIO';

  @override
  String get image => 'BILD';

  @override
  String get converting => 'Konvertierung läuft…';

  @override
  String get convertAll => 'Alle konvertieren';

  @override
  String get stopConversion => 'Konvertierung stoppen';

  @override
  String get cancel => 'Konvertierung abbrechen';

  @override
  String get removeFile => 'Datei entfernen';

  @override
  String get convertingProgress => 'Konvertierung läuft…';

  @override
  String convertingPercent(int percent) {
    return '$percent % · wird konvertiert';
  }

  @override
  String savedOutput(String name) {
    return 'Gespeichert als $name';
  }

  @override
  String get footerAndroid =>
      'Dateien werden lokal verarbeitet · Ausgabe im App-Dokumenteordner';

  @override
  String get footerDesktop => 'Dateien werden lokal verarbeitet · kein Upload';

  @override
  String get appearance => 'Darstellung';

  @override
  String get dark => 'Dunkel';

  @override
  String get light => 'Hell';

  @override
  String get system => 'System';

  @override
  String get accentColor => 'Akzentfarbe';

  @override
  String get customHexColor => 'Eigene Hex-Farbe';

  @override
  String get apply => 'Anwenden';

  @override
  String get invalidHexColor =>
      'Gib einen gültigen 6-stelligen Hex-Farbwert ein.';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'English';

  @override
  String get czech => 'Čeština';

  @override
  String get german => 'Deutsch';

  @override
  String get french => 'Français';

  @override
  String get spanish => 'Español';

  @override
  String get italian => 'Italiano';

  @override
  String get polish => 'Polski';

  @override
  String get dutch => 'Nederlands';

  @override
  String get portuguese => 'Português';

  @override
  String get chooseFolder => 'Ausgabeordner auswählen';

  @override
  String get dropFoldersUnsupported => 'Bitte Dateien statt Ordner ablegen.';

  @override
  String inspectFailed(String name, String error) {
    return '„$name“ konnte nicht gelesen werden: $error';
  }

  @override
  String get unsupportedFile =>
      'Die Datei enthält keinen unterstützten Audio-, Video- oder Bildstream.';

  @override
  String get probeFailed => 'FFprobe konnte diese Mediendatei nicht lesen.';

  @override
  String get outputFolderNotReady => 'Der Ausgabeordner ist noch nicht bereit.';

  @override
  String get ffmpegNoOutput =>
      'FFmpeg meldet Erfolg, aber es wurde keine Ausgabedatei erstellt.';

  @override
  String convertStopped(int count) {
    return 'Konvertierung gestoppt. $count Datei(en) abgeschlossen.';
  }

  @override
  String convertPartial(int completed, int failed) {
    return '$completed abgeschlossen, $failed fehlgeschlagen. Details stehen bei den Dateien.';
  }

  @override
  String convertSuccess(int count) {
    return '$count Datei(en) erfolgreich konvertiert.';
  }

  @override
  String get aboutVersion => 'Ein lokaler Multimedia-Konverter mit FFmpeg.';
}
