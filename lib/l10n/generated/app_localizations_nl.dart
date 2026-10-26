// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get settings => 'Instellingen';

  @override
  String get helpMenu => 'Help';

  @override
  String get about => 'Over AIOconvert';

  @override
  String get heroTitle => 'Sleep bestanden hierheen om ze te converteren';

  @override
  String get heroSubtitle =>
      'Converteer video, audio en afbeeldingen rechtstreeks op je apparaat.';

  @override
  String get dropPrompt => 'Sleep bestanden hierheen';

  @override
  String get dropHover => 'Laat bestanden los om ze toe te voegen';

  @override
  String get dropMoreFiles => 'Sleep hier meer bestanden heen of blader';

  @override
  String get mediaKinds => 'Video · Audio · Afbeeldingen';

  @override
  String get browseFiles => 'Bestanden zoeken';

  @override
  String get saveTo => 'OPSLAAN IN';

  @override
  String get saveFolderSelection => 'Opslagmap selecteren';

  @override
  String get saveNextToOriginal => 'Opslaan naast het origineel';

  @override
  String get saveNextToOriginalAndroidUnavailable =>
      'Android beperkt toegang tot de oorspronkelijke map. Bestanden worden opgeslagen in de app-opslag.';

  @override
  String get loadingFolder => 'Map laden…';

  @override
  String get appStorage => 'App-opslag';

  @override
  String get chooseFormat => 'Kies een formaat';

  @override
  String get setEachFile => 'Kies een formaat voor elk bestand';

  @override
  String get mixedMediaWarning =>
      'Verschillende mediatypen gevonden — kies voor elk bestand een passend formaat.';

  @override
  String get filesTitle => 'Je bestanden';

  @override
  String get clearQueue => 'Lijst wissen';

  @override
  String get clear => 'Wissen';

  @override
  String get queueEmpty => 'De conversiewachtrij is leeg';

  @override
  String get emptySubtitle =>
      'Voeg een bestand toe om het type en de geschikte formaten te bekijken.';

  @override
  String get video => 'VIDEO';

  @override
  String get audio => 'AUDIO';

  @override
  String get image => 'AFBEELDING';

  @override
  String get convertAll => 'Alles converteren';

  @override
  String get stopConversion => 'Conversie stoppen';

  @override
  String get cancel => 'Conversie annuleren';

  @override
  String get closeDialog => 'Sluiten';

  @override
  String get removeFile => 'Bestand verwijderen';

  @override
  String get convertingProgress => 'Converteren…';

  @override
  String convertingPercent(int percent) {
    return '$percent% · converteren';
  }

  @override
  String savedOutput(String name) {
    return 'Opgeslagen als $name';
  }

  @override
  String get footerAndroid =>
      'Bestanden worden op je apparaat verwerkt · uitvoer in app-documenten';

  @override
  String get footerDesktop =>
      'Bestanden worden op je apparaat verwerkt · niets wordt geüpload';

  @override
  String get appearance => 'Weergave';

  @override
  String get dark => 'Donker';

  @override
  String get light => 'Licht';

  @override
  String get system => 'Systeem';

  @override
  String get accentColor => 'Accentkleur';

  @override
  String get customHexColor => 'Aangepaste hexkleur';

  @override
  String get apply => 'Toepassen';

  @override
  String get invalidHexColor => 'Voer een geldige hexkleur van 6 tekens in.';

  @override
  String get language => 'Taal';

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
  String get chooseFolder => 'Kies een uitvoermap';

  @override
  String get dropFoldersUnsupported => 'Sleep bestanden hierheen, geen mappen.';

  @override
  String inspectFailed(String name, String error) {
    return 'Kan “$name” niet lezen: $error';
  }

  @override
  String get unsupportedFile =>
      'Het bestand bevat geen ondersteunde audio-, video- of afbeeldingsstream.';

  @override
  String get outputFolderNotReady => 'De uitvoermap is nog niet klaar.';

  @override
  String get ffmpegNoOutput =>
      'FFmpeg meldde succes, maar er is geen uitvoerbestand gemaakt.';

  @override
  String convertStopped(int count) {
    return 'Conversie gestopt. $count bestand(en) voltooid.';
  }

  @override
  String convertPartial(int completed, int failed) {
    return '$completed voltooid, $failed mislukt. Bekijk de details per bestand.';
  }

  @override
  String convertSuccess(int count) {
    return '$count bestand(en) geconverteerd.';
  }

  @override
  String get gifAudioLossTitle => 'Audio gaat verloren';

  @override
  String get gifAudioLossMessage =>
      'GIF ondersteunt geen audio. De GIF wordt stil. Doorgaan?';

  @override
  String get keepVideo => 'Video behouden';

  @override
  String get convertWithoutAudio => 'Converteren zonder audio';

  @override
  String get aboutVersion =>
      'Een lokale mediaconverter aangedreven door FFmpeg.';
}
