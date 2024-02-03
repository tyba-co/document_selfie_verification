part of document_selfie_verification.enums;

enum DocumentSelfieExceptionType {
  cameraAccessDenied('CAMERA_ACCESS_DENIED',
      'Thrown when user denies the camera access permission.'),
  notRecognizeSelfie('NOT_RECOGNIZE_SELFIE',
      'Make sure your face comes out full. Only one face is allowed.'),
  notRecognizeAnything('NOT_RECOGNIZE_ANYTHING',
      'The entire document must be within the box, information and photo.'),
  almostOneIsSuccess('ALMOST_ONE_IS_SUCCESS',
      'Make sure the document is well focused and has no highlights or shadows.');

  const DocumentSelfieExceptionType(this.code, this.message);

  final String code;
  final String message;
}
