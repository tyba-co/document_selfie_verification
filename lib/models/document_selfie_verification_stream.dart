part of document_selfie_verification.models;

class DocumentSelfieVerificationStream extends DocumentVerificationBase {
  DocumentSelfieVerificationStream({
    required this.image,
    required this.cameraDescription,
    required this.controller,
    CountryType? country = CountryType.colombia,
    SideType? side = SideType.frontSide,
    List<String>? keyWords,
    int numberOfTextMatches = 2,
  }) : super(
          country: country!,
          side: side!,
          keyWords: keyWords,
          numberOfTextMatches: numberOfTextMatches,
        );

  late CameraImage image;
  late CameraDescription cameraDescription;
  late CameraController controller;
}
