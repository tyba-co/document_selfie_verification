part of document_selfie_verification.models;

class DocumentSelfieException implements Exception {
  DocumentSelfieException(this.type);

  final DocumentSelfieExceptionType type;

  @override
  String toString() {
    return '[DocumentSelfieExceptionType]  code:${type.code}, message:${type.message}';
  }
}
