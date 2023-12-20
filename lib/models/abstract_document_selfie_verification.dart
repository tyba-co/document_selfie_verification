part of document_selfie_verification.models;

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
        CountryType.chile when side.isFrontSide => frontDNICL,
        CountryType.chile when side.isBackSide => backDNICL,
        CountryType.colombia when side.isFrontSide => frontDNICO,
        CountryType.colombia when side.isBackSide => backDNICO,
        CountryType.peru when side.isFrontSide => frontDNIPE,
        CountryType.peru when side.isBackSide => backDNIPE,
        _ => throw UnimplementedError('country not found'),
      };

  List<String> get keyWordsToValidate => keyWords ?? defaultKeyWords;

  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );
}
