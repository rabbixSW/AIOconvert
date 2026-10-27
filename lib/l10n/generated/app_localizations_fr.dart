// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settings => 'Paramètres';

  @override
  String get helpMenu => 'Aide';

  @override
  String get about => 'À propos d’AIOconvert';

  @override
  String get heroTitle => 'Glissez-déposez des fichiers pour les convertir';

  @override
  String get selectFilesToConvert => 'Sélectionnez les fichiers à convertir';

  @override
  String get selectMoreFiles => 'Sélectionnez d’autres fichiers';

  @override
  String get selectFiles => 'Sélectionner des fichiers';

  @override
  String get heroSubtitle =>
      'Convertissez vidéos, audio et images directement sur votre appareil.';

  @override
  String get dropPrompt => 'Déposez vos fichiers ici';

  @override
  String get dropHover => 'Déposez les fichiers pour les ajouter';

  @override
  String get dropMoreFiles =>
      'Déposez d’autres fichiers ici ou sélectionnez-les';

  @override
  String get mediaKinds => 'Vidéo · Audio · Images';

  @override
  String get browseFiles => 'Parcourir les fichiers';

  @override
  String get saveTo => 'ENREGISTRER DANS';

  @override
  String get saveFolderSelection => 'Choisir le dossier d’enregistrement';

  @override
  String get androidOutputFolderTitle => 'Sélectionner le dossier de sortie';

  @override
  String get androidOutputFolderMessage =>
      'Choisissez le dossier où enregistrer les fichiers convertis. Vous pourrez le modifier plus tard dans les paramètres du dossier d’enregistrement.';

  @override
  String get androidOutputFolderButton => 'Sélectionner le dossier';

  @override
  String get androidOutputFolderLater => 'Plus tard';

  @override
  String get androidOutputFolderNotGranted =>
      'Aucun dossier de sortie n’a été sélectionné. Les fichiers seront enregistrés dans le stockage de l’application. Vous pourrez sélectionner un dossier plus tard dans les paramètres d’enregistrement.';

  @override
  String get saveNextToOriginal => 'Enregistrer à côté de l’original';

  @override
  String get saveNextToOriginalAndroidUnavailable =>
      'Android limite l’accès au dossier d’origine. Les fichiers sont enregistrés dans le stockage de l’application.';

  @override
  String get loadingFolder => 'Chargement du dossier…';

  @override
  String get appStorage => 'Stockage de l’application';

  @override
  String get chooseFormat => 'Choisir un format';

  @override
  String get setEachFile => 'Choisir le format pour chaque fichier';

  @override
  String get mixedMediaWarning =>
      'Plusieurs types de médias détectés — choisissez un format adapté pour chaque fichier.';

  @override
  String get filesTitle => 'Vos fichiers';

  @override
  String get clearQueue => 'Vider la liste';

  @override
  String get clear => 'Vider';

  @override
  String get queueEmpty => 'La file de conversion est vide';

  @override
  String get emptySubtitle =>
      'Ajoutez un fichier pour voir son type et les formats compatibles.';

  @override
  String get video => 'VIDÉO';

  @override
  String get audio => 'AUDIO';

  @override
  String get image => 'IMAGE';

  @override
  String get convertAll => 'Tout convertir';

  @override
  String get stopConversion => 'Arrêter la conversion';

  @override
  String get cancel => 'Annuler la conversion';

  @override
  String get closeDialog => 'Fermer';

  @override
  String get removeFile => 'Supprimer le fichier';

  @override
  String get convertingProgress => 'Conversion en cours…';

  @override
  String convertingPercent(int percent) {
    return '$percent % · conversion';
  }

  @override
  String savedOutput(String name) {
    return 'Enregistré sous $name';
  }

  @override
  String get footerAndroid =>
      'Traitement sur votre appareil · fichiers dans le dossier sélectionné';

  @override
  String get footerDesktop => 'Traitement sur votre appareil · aucun envoi';

  @override
  String get appearance => 'Apparence';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get system => 'Système';

  @override
  String get accentColor => 'Couleur d’accentuation';

  @override
  String get customHexColor => 'Couleur hexadécimale personnalisée';

  @override
  String get apply => 'Appliquer';

  @override
  String get invalidHexColor =>
      'Saisissez une couleur hexadécimale valide à 6 chiffres.';

  @override
  String get language => 'Langue';

  @override
  String get defaultEnglish => 'Par défaut (anglais)';

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
  String get chooseFolder => 'Choisir le dossier de sortie';

  @override
  String get dropFoldersUnsupported =>
      'Déposez des fichiers, pas des dossiers.';

  @override
  String inspectFailed(String name, String error) {
    return 'Impossible de lire « $name » : $error';
  }

  @override
  String get unsupportedFile =>
      'Le fichier ne contient aucun flux audio, vidéo ou image pris en charge.';

  @override
  String get outputFolderNotReady =>
      'Le dossier de sortie n’est pas encore prêt.';

  @override
  String get ffmpegNoOutput =>
      'FFmpeg a indiqué une réussite, mais aucun fichier de sortie n’a été créé.';

  @override
  String convertStopped(int count) {
    return 'Conversion arrêtée. $count fichier(s) terminé(s).';
  }

  @override
  String convertPartial(int completed, int failed) {
    return '$completed terminé(s), $failed en échec. Consultez chaque fichier pour les détails.';
  }

  @override
  String convertSuccess(int count) {
    return '$count fichier(s) converti(s) avec succès.';
  }

  @override
  String get gifAudioLossTitle => 'Le son sera perdu';

  @override
  String get gifAudioLossMessage =>
      'Le format GIF ne prend pas en charge l’audio. Le GIF sera silencieux. Continuer ?';

  @override
  String get keepVideo => 'Garder la vidéo';

  @override
  String get convertWithoutAudio => 'Convertir sans audio';

  @override
  String get aboutVersion =>
      'Un convertisseur multimédia local propulsé par FFmpeg.';
}
