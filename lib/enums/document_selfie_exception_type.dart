part of document_selfie_verification.enums;

enum DocumentSelfieExceptionType {
  cameraAccessDenied('CAMERA_ACCESS_DENIED',
      'Thrown when user denies the camera access permission.', ''),
  notRecognizeSelfie(
      'NOT_RECOGNIZE_SELFIE',
      'Make sure your face comes out full. Only one face is allowed.',
      'Asegúrate de que tu cara salga completa. Sólo se permite una cara.'),
  notRecognizeAnything(
      'NOT_RECOGNIZE_ANYTHING',
      'The entire document must be within the box, information and photo.',
      'Por favor, verifica que la foto del documento muestre tus datos y tu rostro de manera legible.'),
  almostOneIsSuccess(
      'ALMOST_ONE_IS_SUCCESS',
      'Make sure the document is well focused and has no highlights or shadows.',
      '');

  const DocumentSelfieExceptionType(
      this.code, this.message, this.messageTranslate);

  final String code;
  final String message;
  final String messageTranslate;
}
