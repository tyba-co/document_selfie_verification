part of document_selfie_verification.models;

class DocumentVerification extends DocumentVerificationBase {
  DocumentVerification({
    this.file,
    this.imageData,
    this.validateOneFaceExist = true,
    List<String>? keyWords,
    CountryType? country = CountryType.colombia,
    SideType? side = SideType.frontSide,
  })  : assert(
          (kIsWeb && imageData != null && file == null) ||
              (!kIsWeb && imageData == null && file != null),
          'Only use File for App and Unit8List for Web',
        ),
        super(
          country: country!,
          side: side!,
          keyWords: keyWords,
        );

  bool validateOneFaceExist;
  File? file;
  Uint8List? imageData;

  Future<bool> validate() async {
    if (SideType.frontSide.isSelfie) {
      return await validateOneFace();
    }

    bool hasOnlyOneFace = validateOneFaceExist ? await validateOneFace() : true;
    bool hasText = await validateKeyWordsInFile(keyWordsToValidate);

    return hasText && hasOnlyOneFace;
  }

  Future<bool> validateOneFace() async {
    if (kIsWeb) {
      return await TextImageProcessingForWeb.instance
          .recognizePersonInPhoto(imageData!);
    }
    return await hasOnlyOneFace(file!);
  }

  Future<bool> validateKeyWordsInFile(List<String> keyWords) async {
    bool hasText = false;
    if (kIsWeb) {
      String ocrText = await TextImageProcessingForWeb.instance
          .recognizeTextInImage(imageData!);
      for (String palabra in keyWords) {
        if (ocrText.toLowerCase().contains(palabra)) {
          hasText = true;
        }
      }
    } else {
      hasText = await checkMLText(file, keyWords);
    }
    return hasText;
  }

  Future<bool> checkMLText(File? file, List<String> match) async {
    TextRecognizer textRecognizer = TextRecognizer();

    InputImage inputImage = InputImage.fromFile(file!);
    RecognizedText recognisedText =
        await textRecognizer.processImage(inputImage);
    String text = recognisedText.text;
    bool test(String value) => text.toLowerCase().contains(value.toLowerCase());
    return match.any(test);
  }

  Future<bool> hasOnlyOneFace(File file) async {
    File fileToProcess = file;

    if (Platform.isIOS) {
      fileToProcess = await compressFile(file);
    }

    InputImage inputImage = InputImage.fromFile(fileToProcess);

    List<Face> faces = <Face>[];
    try {
      faces = await faceDetector.processImage(inputImage);
      return faces.length == 1;
    } on Exception catch (_) {
      return false;
    }
  }

  String decodeImage(CompressObject object) {
    img.Image? image = img.decodeImage(object.imageFile.readAsBytesSync());
    img.Image smallerImage = img.copyResize(
      image!,
      width: 200,
      height: 200,
    );
    File decodedImageFile = File('${object.path}/img_${object.rand}.jpg')
      ..writeAsBytesSync(img.encodeJpg(smallerImage, quality: 85));

    return decodedImageFile.path;
  }

  Future<File> compressFile(File file) async {
    Directory tempDir = await getTemporaryDirectory();
    int rand = math.Random().nextInt(10000);
    CompressObject compressObject =
        CompressObject(File(file.path), tempDir.path, rand);
    String filePath = decodeImage(compressObject);
    return File(filePath);
  }
}
