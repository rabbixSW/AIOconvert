// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get settings => 'Ustawienia';

  @override
  String get helpMenu => 'Pomoc';

  @override
  String get about => 'O AIOconvert';

  @override
  String get heroTitle => 'Przeciągnij pliki tutaj, aby je przekonwertować';

  @override
  String get heroSubtitle =>
      'Konwertuj filmy, dźwięk i obrazy bezpośrednio na swoim urządzeniu.';

  @override
  String get dropPrompt => 'Upuść pliki tutaj';

  @override
  String get dropHover => 'Upuść pliki, aby je dodać';

  @override
  String get dropMoreFiles => 'Upuść tutaj kolejne pliki lub wybierz je';

  @override
  String get mediaKinds => 'Wideo · Audio · Obrazy';

  @override
  String get browseFiles => 'Przeglądaj pliki';

  @override
  String get saveTo => 'ZAPISZ W';

  @override
  String get saveFolderSelection => 'Wybierz folder zapisu';

  @override
  String get saveNextToOriginal => 'Zapisz obok oryginału';

  @override
  String get saveNextToOriginalAndroidUnavailable =>
      'Android ogranicza dostęp do folderu źródłowego. Pliki są zapisywane w pamięci aplikacji.';

  @override
  String get loadingFolder => 'Wczytywanie folderu…';

  @override
  String get appStorage => 'Pamięć aplikacji';

  @override
  String get chooseFormat => 'Wybierz format';

  @override
  String get setEachFile => 'Ustaw format dla każdego pliku';

  @override
  String get mixedMediaWarning =>
      'Wykryto różne typy multimediów — wybierz zgodny format dla każdego pliku.';

  @override
  String get filesTitle => 'Twoje pliki';

  @override
  String get clearQueue => 'Wyczyść listę';

  @override
  String get clear => 'Wyczyść';

  @override
  String get queueEmpty => 'Kolejka konwersji jest pusta';

  @override
  String get emptySubtitle =>
      'Dodaj plik, aby zobaczyć jego typ i zgodne formaty.';

  @override
  String get video => 'WIDEO';

  @override
  String get audio => 'AUDIO';

  @override
  String get image => 'OBRAZ';

  @override
  String get convertAll => 'Konwertuj wszystko';

  @override
  String get stopConversion => 'Zatrzymaj konwersję';

  @override
  String get cancel => 'Anuluj konwersję';

  @override
  String get closeDialog => 'Zamknij';

  @override
  String get removeFile => 'Usuń plik';

  @override
  String get convertingProgress => 'Konwertowanie…';

  @override
  String convertingPercent(int percent) {
    return '$percent% · konwertowanie';
  }

  @override
  String savedOutput(String name) {
    return 'Zapisano jako $name';
  }

  @override
  String get footerAndroid =>
      'Pliki są przetwarzane na urządzeniu · wyniki w dokumentach aplikacji';

  @override
  String get footerDesktop =>
      'Pliki są przetwarzane na urządzeniu · bez wysyłania';

  @override
  String get appearance => 'Wygląd';

  @override
  String get dark => 'Ciemny';

  @override
  String get light => 'Jasny';

  @override
  String get system => 'Systemowy';

  @override
  String get accentColor => 'Kolor akcentu';

  @override
  String get customHexColor => 'Własny kolor HEX';

  @override
  String get apply => 'Zastosuj';

  @override
  String get invalidHexColor => 'Wpisz prawidłowy 6-cyfrowy kolor HEX.';

  @override
  String get language => 'Język';

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
  String get chooseFolder => 'Wybierz folder docelowy';

  @override
  String get dropFoldersUnsupported => 'Upuszczaj pliki, nie foldery.';

  @override
  String inspectFailed(String name, String error) {
    return 'Nie można odczytać „$name”: $error';
  }

  @override
  String get unsupportedFile =>
      'Plik nie zawiera obsługiwanego strumienia audio, wideo ani obrazu.';

  @override
  String get outputFolderNotReady => 'Folder docelowy nie jest jeszcze gotowy.';

  @override
  String get ffmpegNoOutput =>
      'FFmpeg zgłosił powodzenie, ale plik wynikowy nie został utworzony.';

  @override
  String convertStopped(int count) {
    return 'Zatrzymano konwersję. Ukończono plików: $count.';
  }

  @override
  String convertPartial(int completed, int failed) {
    return 'Ukończono: $completed, błędy: $failed. Szczegóły przy plikach.';
  }

  @override
  String convertSuccess(int count) {
    return 'Pomyślnie skonwertowano plików: $count.';
  }

  @override
  String get aboutVersion =>
      'Lokalny konwerter multimediów wykorzystujący FFmpeg.';
}
