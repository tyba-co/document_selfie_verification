# Document Verification Library

Esta biblioteca proporciona clases para la verificación de documentos usando Google Cloud Vision API.

## Características

* Valida texto usando MLKit TextRecognizer
* Valida caras usando MLKit FaceDetector
* Soporta diferentes orientaciones: retrato, paisaje
* Proporciona métodos para convertir CameraImage a InputImage

## Uso
```
import 'package:document_verification/document_verification.dart';

void main() {
// Create a document verification object
DocumentVerificationStream stream = DocumentVerificationStream(
image: image,
cameraDescription: cameraDescription,
controller: controller,
country: CountryType.colombia,
side: SideType.frontSide,
keyWords: ['cedula', 'pasaporte', 'licencia'],
);

// Validate text
MLTextResponse mlResponse = await stream.checkMLText();
if (mlResponse.keyWordsValidated) {
print('Text validated');
} else {
print('Text not validated');
}

// Validate faces
bool facesValidated = await stream.validateFaces(numFaces: 1);
if (facesValidated) {
print('Faces validated');
} else {
print('Faces not validated');
}
}
```

## Clases
* DocumentVerificationBase: Define la estructura básica de una clase de verificación de documentos.
* DocumentVerificationStream: Clase que proporciona métodos adicionales para validar documentos usando Google Cloud Vision API.
MLTextResponse: Representa la respuesta del proceso de reconocimiento de texto.

## Constantes
* **frontDNIDocumentKeyWordsCO**: Lista de palabras clave predeterminadas para el frente de una cédula de identidad colombiana.
* **backDNIDocumentKeyWordsCO**: Lista de palabras clave predeterminadas para el reverso de una cédula de identidad colombiana.
* **frontDNIDocumentKeyWordsCL**: Lista de palabras clave predeterminadas para el frente de una cédula de identidad chilena.
* **backDNIDocumentKeyWordsCL**: Lista de palabras clave predeterminadas para el reverso de una cédula de identidad chilena.
* **frontDNIDocumentKeyWordsPE**: Lista de palabras clave predeterminadas para el frente de una cédula de identidad peruana.
* **backDNIDocumentKeyWordsPE**: Lista de palabras clave predeterminadas para el reverso de una cédula de identidad peruana.

## Enumeraciones
* CountryType: Representa el país de un documento.
* SideType: Representa el lado de un documento.

## Instalación
Para instalar la biblioteca, ejecute el siguiente comando:

dart pub add document_verification

## Requisitos

La biblioteca requiere las siguientes dependencias:

* Google Mobile Vision
* Google ML Kit

## Licencia

La biblioteca está licenciada bajo la licencia Apache 2.0.
