// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get settings => 'Definições';

  @override
  String get helpMenu => 'Ajuda';

  @override
  String get about => 'Sobre o AIOconvert';

  @override
  String get heroTitle => 'Arraste e largue ficheiros para os converter';

  @override
  String get selectFilesToConvert => 'Selecione ficheiros para converter';

  @override
  String get selectMoreFiles => 'Selecione mais ficheiros';

  @override
  String get selectFiles => 'Selecionar ficheiros';

  @override
  String get heroSubtitle =>
      'Converta vídeo, áudio e imagens diretamente no seu dispositivo.';

  @override
  String get dropPrompt => 'Solte os ficheiros aqui';

  @override
  String get dropHover => 'Solte ficheiros para os adicionar';

  @override
  String get dropMoreFiles => 'Largue mais ficheiros aqui ou procure-os';

  @override
  String get mediaKinds => 'Vídeo · Áudio · Imagens';

  @override
  String get browseFiles => 'Procurar ficheiros';

  @override
  String get saveTo => 'GUARDAR EM';

  @override
  String get saveFolderSelection => 'Selecionar pasta de destino';

  @override
  String get androidOutputFolderTitle =>
      'Selecione a pasta de destino das conversões';

  @override
  String get androidOutputFolderMessage =>
      'Escolha onde guardar os ficheiros convertidos. Pode alterar a pasta mais tarde nas definições da pasta de destino.';

  @override
  String get androidOutputFolderButton => 'Selecionar pasta';

  @override
  String get androidOutputFolderLater => 'Agora não';

  @override
  String get androidOutputFolderNotGranted =>
      'Não foi selecionada nenhuma pasta de destino. Os ficheiros convertidos serão guardados no armazenamento da aplicação. Pode selecionar uma pasta mais tarde nas definições da pasta de destino.';

  @override
  String get saveNextToOriginal => 'Guardar junto ao original';

  @override
  String get saveNextToOriginalAndroidUnavailable =>
      'O Android restringe o acesso à pasta original. Os ficheiros são guardados no armazenamento da aplicação.';

  @override
  String get loadingFolder => 'A carregar pasta…';

  @override
  String get appStorage => 'Armazenamento da aplicação';

  @override
  String get chooseFormat => 'Escolher formato';

  @override
  String get setEachFile => 'Escolha um formato para cada ficheiro';

  @override
  String get mixedMediaWarning =>
      'Foram detetados tipos de multimédia diferentes — escolha um formato compatível para cada ficheiro.';

  @override
  String get filesTitle => 'Os seus ficheiros';

  @override
  String get clearQueue => 'Limpar lista';

  @override
  String get clear => 'Limpar';

  @override
  String get queueEmpty => 'A fila de conversão está vazia';

  @override
  String get emptySubtitle =>
      'Adicione um ficheiro para ver o tipo e os formatos compatíveis.';

  @override
  String get video => 'VÍDEO';

  @override
  String get audio => 'ÁUDIO';

  @override
  String get image => 'IMAGEM';

  @override
  String get convertAll => 'Converter tudo';

  @override
  String get stopConversion => 'Parar conversão';

  @override
  String get cancel => 'Cancelar conversão';

  @override
  String get closeDialog => 'Fechar';

  @override
  String get removeFile => 'Remover ficheiro';

  @override
  String get convertingProgress => 'A converter…';

  @override
  String convertingPercent(int percent) {
    return '$percent% · a converter';
  }

  @override
  String savedOutput(String name) {
    return 'Guardado como $name';
  }

  @override
  String get footerAndroid =>
      'Os ficheiros são processados no dispositivo · resultados na pasta selecionada';

  @override
  String get footerDesktop =>
      'Os ficheiros são processados no dispositivo · sem carregamentos';

  @override
  String get appearance => 'Aspeto';

  @override
  String get dark => 'Escuro';

  @override
  String get light => 'Claro';

  @override
  String get system => 'Sistema';

  @override
  String get accentColor => 'Cor de destaque';

  @override
  String get customHexColor => 'Cor hexadecimal personalizada';

  @override
  String get apply => 'Aplicar';

  @override
  String get invalidHexColor =>
      'Introduza uma cor hexadecimal válida de 6 dígitos.';

  @override
  String get language => 'Idioma';

  @override
  String get defaultEnglish => 'Predefinição (inglês)';

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
  String get chooseFolder => 'Escolher pasta de destino';

  @override
  String get dropFoldersUnsupported => 'Solte ficheiros, não pastas.';

  @override
  String inspectFailed(String name, String error) {
    return 'Não foi possível ler “$name”: $error';
  }

  @override
  String get unsupportedFile =>
      'O ficheiro não contém uma sequência de áudio, vídeo ou imagem compatível.';

  @override
  String get outputFolderNotReady =>
      'A pasta de destino ainda não está pronta.';

  @override
  String get ffmpegNoOutput =>
      'O FFmpeg indicou sucesso, mas não criou nenhum ficheiro de saída.';

  @override
  String convertStopped(int count) {
    return 'Conversão parada. $count ficheiro(s) concluído(s).';
  }

  @override
  String convertPartial(int completed, int failed) {
    return '$completed concluídos, $failed falharam. Consulte os detalhes de cada ficheiro.';
  }

  @override
  String convertSuccess(int count) {
    return '$count ficheiro(s) convertido(s) com sucesso.';
  }

  @override
  String get gifAudioLossTitle => 'O áudio será perdido';

  @override
  String get gifAudioLossMessage =>
      'GIF não suporta áudio. O GIF resultante ficará sem som. Continuar?';

  @override
  String get keepVideo => 'Manter vídeo';

  @override
  String get convertWithoutAudio => 'Converter sem áudio';

  @override
  String get aboutVersion =>
      'Um conversor multimédia local com tecnologia FFmpeg.';
}
