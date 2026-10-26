// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settings => 'Ajustes';

  @override
  String get fileMenu => 'Archivo';

  @override
  String get helpMenu => 'Ayuda';

  @override
  String get about => 'Acerca de AIOconvert';

  @override
  String get quit => 'Salir';

  @override
  String get heroTitle => 'Convierte cualquier formato fácilmente.';

  @override
  String get heroSubtitle =>
      'Convierte vídeos, audio e imágenes directamente en tu dispositivo.';

  @override
  String get dropPrompt => 'Suelta tus archivos aquí';

  @override
  String get dropHover => 'Suelta los archivos para añadirlos';

  @override
  String get mediaKinds => 'Vídeo · audio · imágenes';

  @override
  String get browseFiles => 'Buscar archivos';

  @override
  String get formatAll => 'FORMATO PARA TODOS';

  @override
  String get saveTo => 'GUARDAR EN';

  @override
  String get loadingFolder => 'Cargando carpeta…';

  @override
  String get appStorage => 'Almacenamiento de la aplicación';

  @override
  String get chooseFormat => 'Elegir formato';

  @override
  String get setEachFile => 'Elige un formato para cada archivo';

  @override
  String get mixedMediaWarning =>
      'Se detectaron distintos tipos de contenido — elige un formato compatible para cada archivo.';

  @override
  String get filesTitle => 'Tus archivos';

  @override
  String get clearQueue => 'Vaciar lista';

  @override
  String get clear => 'Vaciar';

  @override
  String get queueEmpty => 'La cola de conversión está vacía';

  @override
  String get emptySubtitle =>
      'Añade un archivo para ver su tipo y los formatos compatibles.';

  @override
  String get video => 'VÍDEO';

  @override
  String get audio => 'AUDIO';

  @override
  String get image => 'IMAGEN';

  @override
  String get converting => 'Convirtiendo…';

  @override
  String get convertAll => 'Convertir todo';

  @override
  String get stopConversion => 'Detener conversión';

  @override
  String get cancel => 'Cancelar conversión';

  @override
  String get removeFile => 'Quitar archivo';

  @override
  String get convertingProgress => 'Convirtiendo…';

  @override
  String convertingPercent(int percent) {
    return '$percent % · convirtiendo';
  }

  @override
  String savedOutput(String name) {
    return 'Guardado como $name';
  }

  @override
  String get footerAndroid =>
      'Los archivos se procesan en tu dispositivo · resultados en los documentos de la aplicación';

  @override
  String get footerDesktop =>
      'Los archivos se procesan en tu dispositivo · sin subirlos';

  @override
  String get appearance => 'Apariencia';

  @override
  String get dark => 'Oscuro';

  @override
  String get light => 'Claro';

  @override
  String get system => 'Sistema';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get customHexColor => 'Color hexadecimal personalizado';

  @override
  String get apply => 'Aplicar';

  @override
  String get invalidHexColor =>
      'Introduce un color hexadecimal válido de 6 dígitos.';

  @override
  String get language => 'Idioma';

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
  String get chooseFolder => 'Elegir carpeta de destino';

  @override
  String get dropFoldersUnsupported => 'Suelta archivos, no carpetas.';

  @override
  String inspectFailed(String name, String error) {
    return 'No se pudo leer «$name»: $error';
  }

  @override
  String get unsupportedFile =>
      'El archivo no contiene una pista de audio, vídeo o imagen compatible.';

  @override
  String get probeFailed =>
      'FFprobe no ha podido leer este archivo multimedia.';

  @override
  String get outputFolderNotReady => 'La carpeta de destino aún no está lista.';

  @override
  String get ffmpegNoOutput =>
      'FFmpeg indicó que terminó correctamente, pero no se creó ningún archivo.';

  @override
  String convertStopped(int count) {
    return 'Conversión detenida. $count archivo(s) completado(s).';
  }

  @override
  String convertPartial(int completed, int failed) {
    return '$completed completados, $failed fallidos. Consulta cada archivo para ver los detalles.';
  }

  @override
  String convertSuccess(int count) {
    return '$count archivo(s) convertido(s) correctamente.';
  }

  @override
  String get aboutVersion =>
      'Un conversor multimedia local con tecnología FFmpeg.';
}
