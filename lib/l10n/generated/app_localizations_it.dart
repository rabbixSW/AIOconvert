// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get settings => 'Impostazioni';

  @override
  String get helpMenu => 'Aiuto';

  @override
  String get about => 'Informazioni su AIOconvert';

  @override
  String get heroTitle => 'Trascina i file qui per convertirli';

  @override
  String get heroSubtitle =>
      'Converti video, audio e immagini direttamente sul tuo dispositivo.';

  @override
  String get dropPrompt => 'Trascina qui i tuoi file';

  @override
  String get dropHover => 'Rilascia i file per aggiungerli';

  @override
  String get dropMoreFiles => 'Rilascia altri file qui o selezionali';

  @override
  String get mediaKinds => 'Video · Audio · Immagini';

  @override
  String get browseFiles => 'Sfoglia file';

  @override
  String get saveTo => 'SALVA IN';

  @override
  String get saveFolderSelection => 'Seleziona cartella di destinazione';

  @override
  String get saveNextToOriginal => 'Salva accanto all’originale';

  @override
  String get saveNextToOriginalAndroidUnavailable =>
      'Android limita l’accesso alla cartella originale. I file vengono salvati nello spazio dell’app.';

  @override
  String get loadingFolder => 'Caricamento cartella…';

  @override
  String get appStorage => 'Memoria dell’app';

  @override
  String get chooseFormat => 'Scegli un formato';

  @override
  String get setEachFile => 'Scegli un formato per ogni file';

  @override
  String get mixedMediaWarning =>
      'Rilevati tipi di contenuti diversi — scegli un formato compatibile per ogni file.';

  @override
  String get filesTitle => 'I tuoi file';

  @override
  String get clearQueue => 'Svuota elenco';

  @override
  String get clear => 'Svuota';

  @override
  String get queueEmpty => 'La coda di conversione è vuota';

  @override
  String get emptySubtitle =>
      'Aggiungi un file per visualizzare il tipo e i formati compatibili.';

  @override
  String get video => 'VIDEO';

  @override
  String get audio => 'AUDIO';

  @override
  String get image => 'IMMAGINE';

  @override
  String get convertAll => 'Converti tutto';

  @override
  String get stopConversion => 'Interrompi conversione';

  @override
  String get cancel => 'Annulla conversione';

  @override
  String get closeDialog => 'Chiudi';

  @override
  String get removeFile => 'Rimuovi file';

  @override
  String get convertingProgress => 'Conversione in corso…';

  @override
  String convertingPercent(int percent) {
    return '$percent % · conversione';
  }

  @override
  String savedOutput(String name) {
    return 'Salvato come $name';
  }

  @override
  String get footerAndroid =>
      'File elaborati sul dispositivo · risultati nei documenti dell’app';

  @override
  String get footerDesktop =>
      'File elaborati sul dispositivo · nessun caricamento';

  @override
  String get appearance => 'Aspetto';

  @override
  String get dark => 'Scuro';

  @override
  String get light => 'Chiaro';

  @override
  String get system => 'Sistema';

  @override
  String get accentColor => 'Colore principale';

  @override
  String get customHexColor => 'Colore esadecimale personalizzato';

  @override
  String get apply => 'Applica';

  @override
  String get invalidHexColor =>
      'Inserisci un colore esadecimale valido di 6 cifre.';

  @override
  String get language => 'Lingua';

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
  String get chooseFolder => 'Scegli la cartella di destinazione';

  @override
  String get dropFoldersUnsupported => 'Trascina i file, non le cartelle.';

  @override
  String inspectFailed(String name, String error) {
    return 'Impossibile leggere “$name”: $error';
  }

  @override
  String get unsupportedFile =>
      'Il file non contiene uno stream audio, video o immagine supportato.';

  @override
  String get outputFolderNotReady =>
      'La cartella di destinazione non è ancora pronta.';

  @override
  String get ffmpegNoOutput =>
      'FFmpeg ha segnalato il successo, ma non è stato creato alcun file.';

  @override
  String convertStopped(int count) {
    return 'Conversione interrotta. File completati: $count.';
  }

  @override
  String convertPartial(int completed, int failed) {
    return '$completed completati, $failed non riusciti. Consulta i dettagli di ogni file.';
  }

  @override
  String convertSuccess(int count) {
    return '$count file convertiti correttamente.';
  }

  @override
  String get aboutVersion =>
      'Un convertitore multimediale locale basato su FFmpeg.';
}
