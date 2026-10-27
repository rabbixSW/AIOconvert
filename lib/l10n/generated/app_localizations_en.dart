// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get helpMenu => 'Help';

  @override
  String get about => 'About AIOconvert';

  @override
  String get heroTitle => 'Drag and drop files to convert them';

  @override
  String get selectFilesToConvert => 'Select files to convert';

  @override
  String get selectMoreFiles => 'Select more files to add';

  @override
  String get selectFiles => 'Select files';

  @override
  String get heroSubtitle =>
      'Convert videos, audio and images privately on your device.';

  @override
  String get dropPrompt => 'Drop your files here';

  @override
  String get dropHover => 'Drop files to add them';

  @override
  String get dropMoreFiles => 'Drop more files here, or browse';

  @override
  String get mediaKinds => 'Video · Audio · Images';

  @override
  String get browseFiles => 'Browse files';

  @override
  String get saveTo => 'SAVE TO';

  @override
  String get saveFolderSelection => 'Save folder selection';

  @override
  String get androidOutputFolderTitle => 'Select conversion output folder';

  @override
  String get androidOutputFolderMessage =>
      'Choose where converted files should be saved. You can change the folder later in Save folder selection.';

  @override
  String get androidOutputFolderButton => 'Select folder';

  @override
  String get androidOutputFolderLater => 'Not now';

  @override
  String get androidOutputFolderNotGranted =>
      'No output folder was selected. Converted files will be saved in app storage. You can select a folder later in Save folder selection.';

  @override
  String get saveNextToOriginal => 'Save next to original';

  @override
  String get saveNextToOriginalAndroidUnavailable =>
      'Android restricts access to the original folder. Files are saved in app storage.';

  @override
  String get loadingFolder => 'Loading folder…';

  @override
  String get appStorage => 'App storage';

  @override
  String get chooseFormat => 'Choose a format';

  @override
  String get setEachFile => 'Set each file separately';

  @override
  String get mixedMediaWarning =>
      'Mixed media detected — choose a compatible output for every file.';

  @override
  String get filesTitle => 'Your files';

  @override
  String get clearQueue => 'Clear list';

  @override
  String get clear => 'Clear';

  @override
  String get queueEmpty => 'Your conversion queue is empty';

  @override
  String get emptySubtitle =>
      'Add a file to see its detected type and compatible formats.';

  @override
  String get video => 'VIDEO';

  @override
  String get audio => 'AUDIO';

  @override
  String get image => 'IMAGE';

  @override
  String get convertAll => 'Convert all';

  @override
  String get stopConversion => 'Stop conversion';

  @override
  String get cancel => 'Cancel conversion';

  @override
  String get closeDialog => 'Close';

  @override
  String get removeFile => 'Remove file';

  @override
  String get convertingProgress => 'Converting…';

  @override
  String convertingPercent(int percent) {
    return '$percent% · converting';
  }

  @override
  String savedOutput(String name) {
    return 'Saved to $name';
  }

  @override
  String get footerAndroid =>
      'Files are processed on your device · outputs are saved to the selected folder';

  @override
  String get footerDesktop => 'Files are processed on your device · no uploads';

  @override
  String get appearance => 'Appearance';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get system => 'System';

  @override
  String get accentColor => 'Accent color';

  @override
  String get customHexColor => 'Custom hex color';

  @override
  String get apply => 'Apply';

  @override
  String get invalidHexColor => 'Enter a valid 6-digit hex color.';

  @override
  String get language => 'Language';

  @override
  String get defaultEnglish => 'Default (English)';

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
  String get chooseFolder => 'Choose an output folder';

  @override
  String get dropFoldersUnsupported => 'Please drop files, not folders.';

  @override
  String inspectFailed(String name, String error) {
    return 'Could not inspect \"$name\": $error';
  }

  @override
  String get unsupportedFile =>
      'The selected file does not contain a supported audio, video, or image stream.';

  @override
  String get outputFolderNotReady => 'The output folder is not ready yet.';

  @override
  String get ffmpegNoOutput =>
      'FFmpeg reported success but no output file was created.';

  @override
  String convertStopped(int count) {
    return 'Conversion stopped. $count file(s) completed.';
  }

  @override
  String convertPartial(int completed, int failed) {
    return '$completed completed, $failed failed. See each file for details.';
  }

  @override
  String convertSuccess(int count) {
    return '$count file(s) converted successfully.';
  }

  @override
  String get gifAudioLossTitle => 'Audio will be lost';

  @override
  String get gifAudioLossMessage =>
      'GIF does not support audio. The GIF output will be silent. Continue?';

  @override
  String get keepVideo => 'Keep video';

  @override
  String get convertWithoutAudio => 'Convert without audio';

  @override
  String get aboutVersion =>
      'A local-first multimedia converter powered by FFmpeg.';
}
