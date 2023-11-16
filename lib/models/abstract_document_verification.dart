part of document_verification.models;

abstract class DocumentVerificationBase {
  DocumentVerificationBase({
    required this.country,
    required this.side,
    this.keyWords,
  });
  List<String>? keyWords;
  CountryType country;
  SideType side;

  List<String> get defaultKeyWords => switch (country) {
        CountryType.chile when side.isFrontSide => frontDNIDocumentKeyWordsCL,
        CountryType.chile when side.isBackSide => backDNIDocumentKeyWordsCL,
        CountryType.colombia when side.isFrontSide =>
          frontDNIDocumentKeyWordsCO,
        CountryType.colombia when side.isBackSide => backDNIDocumentKeyWordsCO,
        CountryType.peru when side.isFrontSide => frontDNIDocumentKeyWordsPE,
        CountryType.peru when side.isBackSide => backDNIDocumentKeyWordsPE,
        _ => frontDNIDocumentKeyWordsCO
      };

  List<String> get keyWordsToValidate => keyWords ?? defaultKeyWords;

  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
}
