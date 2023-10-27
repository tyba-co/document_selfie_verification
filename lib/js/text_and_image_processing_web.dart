// Importaciones para plataformas web y móviles.
import 'dart:io';
import 'dart:typed_data';

import 'text_and_image_processing_io.dart'
    if (dart.library.js) 'text_and_image_processing_js.dart';

// Interfaz que especifica las operaciones de procesamiento de texto e
// imágenes para la web.
abstract class TextImageProcessingForWeb {
  // Obtener una instancia específica para la web.
  static TextImageProcessingForWeb get instance => getManager();

  // Función para reconocer texto en una imagen.
  Future<String> recognizeTextInImage(Uint8List imageData);

  // Función para reconocer personas en una imagen.
  Future<bool> recognizePersonInPhoto(Uint8List imageData);

  // Función para convertir Uint8List a File.
  File convertUnit8ListToFile(Uint8List imageData);
}
