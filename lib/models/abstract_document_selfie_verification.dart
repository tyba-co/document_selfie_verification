part of document_selfie_verification.models;

abstract class DocumentVerificationBase {
  DocumentVerificationBase({
    required this.country,
    required this.side,
    required this.numberOfTextMatches,
    this.keyWords,
  });
  List<String>? keyWords;
  CountryType country;
  SideType side;
  int numberOfTextMatches;

  static EmojiType get emoji => EmojiType.randomEmoji();

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

  Future<MLTextResponse> checkMLText(
      {InputImage? inputImage, File? file}) async {
    assert(inputImage != null || file != null,
        "at least one must be different from null");

    TextRecognizer textRecognizer = TextRecognizer();
    InputImage imageToProcess = inputImage ?? InputImage.fromFile(file!);
    RecognizedText recognisedText =
        await textRecognizer.processImage(imageToProcess);

    List<TextBlock> blocks = recognisedText.blocks;

    MLTextResponse mlResponse = MLTextResponse(
      blocks: blocks,
      keyWords: keyWordsToValidate,
      numberOfTextMatches: numberOfTextMatches,
    );

    return mlResponse;
  }

  Future<bool> validateFaces(
      {int maxFaces = 2, InputImage? inputImage, File? file}) async {
    assert(inputImage != null || file != null,
        "at least one must be different from null");
    try {
      if (side == SideType.backSide) {
        return true;
      }
      InputImage imageToProcess = inputImage ?? InputImage.fromFile(file!);
      List<Face> faces = await faceDetector.processImage(imageToProcess);
      return faces.isNotEmpty && faces.length <= maxFaces;
    } on Exception catch (_) {
      return false;
    }
  }
}
