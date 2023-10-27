// Importaciones necesarias para el procesamiento de texto e imágenes en la web.
@JS()
library text_image_processing_js;

import 'dart:async';
import 'dart:html' as html;
import 'dart:io';
import 'dart:js_util';
import 'dart:typed_data';

import 'package:js/js.dart';

import 'text_and_image_processing_web.dart';

// Esta función crea una instancia de TextImageProcessingForWeb específica
// para la web.
TextImageProcessingForWeb getManager() => TextImageProcessingForWebJs();

// Clase que implementa las operaciones específicas de la web.
class TextImageProcessingForWebJs extends TextImageProcessingForWeb {
  TextImageProcessingForWeb getManager() => TextImageProcessingForWebJs();

  // Implementación para reconocer personas en una imagen en la web.
  @override
  Future<bool> recognizePersonInPhoto(Uint8List imageData) async {
    html.Blob blob = html.Blob(<Uint8List>[imageData], 'image/png');
    return promiseToFuture(recognizeFileForPersons(blob));
  }

  // Implementación para reconocer texto en una imagen en la web.
  @override
  Future<String> recognizeTextInImage(Uint8List imageData) async =>
      promiseToFuture(recognizeFileForText(imageData));

  // Implementación para convertir Uint8List a File en la web.
  @override
  File convertUnit8ListToFile(Uint8List imageData) {
    html.Blob blob = html.Blob(<Uint8List>[imageData], 'image/png');
    String blobUrl = html.Url.createObjectUrlFromBlob(blob);
    return File(blobUrl);
  }
}

// Funciones externas en JavaScript para el procesamiento de texto e imágenes
// en la web.
@JS()
external String recognizeFileForText(Uint8List imageData);

@JS()
external bool recognizeFileForPersons(html.Blob imageData);
