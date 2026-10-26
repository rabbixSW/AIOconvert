// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get settings => 'Nastavení';

  @override
  String get fileMenu => 'Soubor';

  @override
  String get helpMenu => 'Nápověda';

  @override
  String get about => 'O aplikaci AIOconvert';

  @override
  String get quit => 'Ukončit';

  @override
  String get heroTitle => 'Přetáhněte soubory sem a převeďte je';

  @override
  String get heroSubtitle =>
      'Převádějte videa, zvuk i obrázky přímo ve svém zařízení.';

  @override
  String get dropPrompt => 'Přetáhněte soubory sem';

  @override
  String get dropHover => 'Pusťte soubory a přidejte je';

  @override
  String get dropMoreFiles => 'Přetáhněte další soubory nebo je vyberte';

  @override
  String get mediaKinds => 'Video · zvuk · obrázky';

  @override
  String get browseFiles => 'Procházet soubory';

  @override
  String get formatAll => 'FORMÁT PRO VŠECHNY';

  @override
  String get saveTo => 'ULOŽIT DO';

  @override
  String get saveSettings => 'Nastavení ukládání';

  @override
  String get saveNextToOriginal => 'Uložit vedle originálu';

  @override
  String get saveNextToOriginalAndroidUnavailable =>
      'Android omezuje přístup k původní složce. Soubory se ukládají do úložiště aplikace.';

  @override
  String get loadingFolder => 'Načítání složky…';

  @override
  String get appStorage => 'Úložiště aplikace';

  @override
  String get chooseFormat => 'Vyberte formát';

  @override
  String get setEachFile => 'Nastavte formát u každého souboru';

  @override
  String get mixedMediaWarning =>
      'Byly rozpoznány různé typy médií — vyberte výstupní formát pro každý soubor.';

  @override
  String get filesTitle => 'Vaše soubory';

  @override
  String get clearQueue => 'Vymazat seznam';

  @override
  String get clear => 'Vymazat';

  @override
  String get queueEmpty => 'Fronta převodu je prázdná';

  @override
  String get emptySubtitle =>
      'Přidejte soubor a zobrazí se jeho typ a kompatibilní formáty.';

  @override
  String get video => 'VIDEO';

  @override
  String get audio => 'ZVUK';

  @override
  String get image => 'OBRÁZEK';

  @override
  String get converting => 'Převádění…';

  @override
  String get convertAll => 'Převést vše';

  @override
  String get stopConversion => 'Zastavit převod';

  @override
  String get cancel => 'Zrušit převod';

  @override
  String get closeDialog => 'Zavřít';

  @override
  String get removeFile => 'Odebrat soubor';

  @override
  String get convertingProgress => 'Převádění…';

  @override
  String convertingPercent(int percent) {
    return '$percent % · převádění';
  }

  @override
  String savedOutput(String name) {
    return 'Uloženo jako $name';
  }

  @override
  String get footerAndroid =>
      'Soubory se zpracovávají v zařízení · výstup se ukládá do dokumentů aplikace';

  @override
  String get footerDesktop =>
      'Soubory se zpracovávají v zařízení · bez nahrávání';

  @override
  String get appearance => 'Vzhled';

  @override
  String get dark => 'Tmavý';

  @override
  String get light => 'Světlý';

  @override
  String get system => 'Podle systému';

  @override
  String get accentColor => 'Barva zvýraznění';

  @override
  String get customHexColor => 'Vlastní barva v hex formátu';

  @override
  String get apply => 'Použít';

  @override
  String get invalidHexColor => 'Zadejte platnou 6místnou hex barvu.';

  @override
  String get language => 'Jazyk';

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
  String get chooseFolder => 'Vyberte výstupní složku';

  @override
  String get dropFoldersUnsupported =>
      'Přetahujte prosím soubory, nikoli složky.';

  @override
  String inspectFailed(String name, String error) {
    return 'Soubor „$name“ nelze načíst: $error';
  }

  @override
  String get unsupportedFile =>
      'Vybraný soubor neobsahuje podporovaný zvukový, video ani obrazový stream.';

  @override
  String get probeFailed => 'FFprobe nedokázal přečíst tento mediální soubor.';

  @override
  String get outputFolderNotReady => 'Výstupní složka ještě není připravena.';

  @override
  String get ffmpegNoOutput =>
      'FFmpeg oznámil úspěch, ale výstupní soubor nebyl vytvořen.';

  @override
  String convertStopped(int count) {
    return 'Převod zastaven. Dokončeno souborů: $count.';
  }

  @override
  String convertPartial(int completed, int failed) {
    return 'Dokončeno: $completed, selhalo: $failed. Podrobnosti jsou u jednotlivých souborů.';
  }

  @override
  String convertSuccess(int count) {
    return 'Úspěšně převedeno souborů: $count.';
  }

  @override
  String get aboutVersion => 'Offline převodník multimédií využívající FFmpeg.';
}
