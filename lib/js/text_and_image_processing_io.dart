// Este archivo importa la implementación específica para la web de
// procesamiento de texto e imágenes.
import 'text_and_image_processing_web.dart';

// La siguiente función arroja un error si se intenta crear en la
// plataforma móvil.
TextImageProcessingForWeb getManager() =>
    throw UnsupportedError('Cannot create for mobile');
