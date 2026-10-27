import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @helpMenu.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpMenu;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About AIOconvert'**
  String get about;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop files to convert them'**
  String get heroTitle;

  /// No description provided for @selectFilesToConvert.
  ///
  /// In en, this message translates to:
  /// **'Select files to convert'**
  String get selectFilesToConvert;

  /// No description provided for @selectMoreFiles.
  ///
  /// In en, this message translates to:
  /// **'Select more files to add'**
  String get selectMoreFiles;

  /// No description provided for @selectFiles.
  ///
  /// In en, this message translates to:
  /// **'Select files'**
  String get selectFiles;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert videos, audio and images privately on your device.'**
  String get heroSubtitle;

  /// No description provided for @dropPrompt.
  ///
  /// In en, this message translates to:
  /// **'Drop your files here'**
  String get dropPrompt;

  /// No description provided for @dropHover.
  ///
  /// In en, this message translates to:
  /// **'Drop files to add them'**
  String get dropHover;

  /// No description provided for @dropMoreFiles.
  ///
  /// In en, this message translates to:
  /// **'Drop more files here, or browse'**
  String get dropMoreFiles;

  /// No description provided for @mediaKinds.
  ///
  /// In en, this message translates to:
  /// **'Video · Audio · Images'**
  String get mediaKinds;

  /// No description provided for @browseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse files'**
  String get browseFiles;

  /// No description provided for @saveTo.
  ///
  /// In en, this message translates to:
  /// **'SAVE TO'**
  String get saveTo;

  /// No description provided for @saveFolderSelection.
  ///
  /// In en, this message translates to:
  /// **'Save folder selection'**
  String get saveFolderSelection;

  /// No description provided for @androidOutputFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Select conversion output folder'**
  String get androidOutputFolderTitle;

  /// No description provided for @androidOutputFolderMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose where converted files should be saved. You can change the folder later in Save folder selection.'**
  String get androidOutputFolderMessage;

  /// No description provided for @androidOutputFolderButton.
  ///
  /// In en, this message translates to:
  /// **'Select folder'**
  String get androidOutputFolderButton;

  /// No description provided for @androidOutputFolderLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get androidOutputFolderLater;

  /// No description provided for @androidOutputFolderNotGranted.
  ///
  /// In en, this message translates to:
  /// **'No output folder was selected. Converted files will be saved in app storage. You can select a folder later in Save folder selection.'**
  String get androidOutputFolderNotGranted;

  /// No description provided for @saveNextToOriginal.
  ///
  /// In en, this message translates to:
  /// **'Save next to original'**
  String get saveNextToOriginal;

  /// No description provided for @saveNextToOriginalAndroidUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Android restricts access to the original folder. Files are saved in app storage.'**
  String get saveNextToOriginalAndroidUnavailable;

  /// No description provided for @loadingFolder.
  ///
  /// In en, this message translates to:
  /// **'Loading folder…'**
  String get loadingFolder;

  /// No description provided for @appStorage.
  ///
  /// In en, this message translates to:
  /// **'App storage'**
  String get appStorage;

  /// No description provided for @chooseFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose a format'**
  String get chooseFormat;

  /// No description provided for @setEachFile.
  ///
  /// In en, this message translates to:
  /// **'Set each file separately'**
  String get setEachFile;

  /// No description provided for @mixedMediaWarning.
  ///
  /// In en, this message translates to:
  /// **'Mixed media detected — choose a compatible output for every file.'**
  String get mixedMediaWarning;

  /// No description provided for @filesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your files'**
  String get filesTitle;

  /// No description provided for @clearQueue.
  ///
  /// In en, this message translates to:
  /// **'Clear list'**
  String get clearQueue;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your conversion queue is empty'**
  String get queueEmpty;

  /// No description provided for @emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a file to see its detected type and compatible formats.'**
  String get emptySubtitle;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'VIDEO'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'AUDIO'**
  String get audio;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'IMAGE'**
  String get image;

  /// No description provided for @convertAll.
  ///
  /// In en, this message translates to:
  /// **'Convert all'**
  String get convertAll;

  /// No description provided for @stopConversion.
  ///
  /// In en, this message translates to:
  /// **'Stop conversion'**
  String get stopConversion;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel conversion'**
  String get cancel;

  /// No description provided for @closeDialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeDialog;

  /// No description provided for @removeFile.
  ///
  /// In en, this message translates to:
  /// **'Remove file'**
  String get removeFile;

  /// No description provided for @convertingProgress.
  ///
  /// In en, this message translates to:
  /// **'Converting…'**
  String get convertingProgress;

  /// No description provided for @convertingPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% · converting'**
  String convertingPercent(int percent);

  /// No description provided for @savedOutput.
  ///
  /// In en, this message translates to:
  /// **'Saved to {name}'**
  String savedOutput(String name);

  /// No description provided for @footerAndroid.
  ///
  /// In en, this message translates to:
  /// **'Files are processed on your device · outputs are saved to the selected folder'**
  String get footerAndroid;

  /// No description provided for @footerDesktop.
  ///
  /// In en, this message translates to:
  /// **'Files are processed on your device · no uploads'**
  String get footerDesktop;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColor;

  /// No description provided for @customHexColor.
  ///
  /// In en, this message translates to:
  /// **'Custom hex color'**
  String get customHexColor;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @invalidHexColor.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit hex color.'**
  String get invalidHexColor;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @defaultEnglish.
  ///
  /// In en, this message translates to:
  /// **'Default (English)'**
  String get defaultEnglish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @czech.
  ///
  /// In en, this message translates to:
  /// **'Čeština'**
  String get czech;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// No description provided for @polish.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get polish;

  /// No description provided for @dutch.
  ///
  /// In en, this message translates to:
  /// **'Nederlands'**
  String get dutch;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder'**
  String get chooseFolder;

  /// No description provided for @dropFoldersUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Please drop files, not folders.'**
  String get dropFoldersUnsupported;

  /// No description provided for @inspectFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not inspect \"{name}\": {error}'**
  String inspectFailed(String name, String error);

  /// No description provided for @unsupportedFile.
  ///
  /// In en, this message translates to:
  /// **'The selected file does not contain a supported audio, video, or image stream.'**
  String get unsupportedFile;

  /// No description provided for @outputFolderNotReady.
  ///
  /// In en, this message translates to:
  /// **'The output folder is not ready yet.'**
  String get outputFolderNotReady;

  /// No description provided for @ffmpegNoOutput.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg reported success but no output file was created.'**
  String get ffmpegNoOutput;

  /// No description provided for @convertStopped.
  ///
  /// In en, this message translates to:
  /// **'Conversion stopped. {count} file(s) completed.'**
  String convertStopped(int count);

  /// No description provided for @convertPartial.
  ///
  /// In en, this message translates to:
  /// **'{completed} completed, {failed} failed. See each file for details.'**
  String convertPartial(int completed, int failed);

  /// No description provided for @convertSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) converted successfully.'**
  String convertSuccess(int count);

  /// No description provided for @gifAudioLossTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio will be lost'**
  String get gifAudioLossTitle;

  /// No description provided for @gifAudioLossMessage.
  ///
  /// In en, this message translates to:
  /// **'GIF does not support audio. The GIF output will be silent. Continue?'**
  String get gifAudioLossMessage;

  /// No description provided for @keepVideo.
  ///
  /// In en, this message translates to:
  /// **'Keep video'**
  String get keepVideo;

  /// No description provided for @convertWithoutAudio.
  ///
  /// In en, this message translates to:
  /// **'Convert without audio'**
  String get convertWithoutAudio;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'A local-first multimedia converter powered by FFmpeg.'**
  String get aboutVersion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'cs',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'nl',
    'pl',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
