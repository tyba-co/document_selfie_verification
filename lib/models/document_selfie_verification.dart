part of document_selfie_verification.models;

class DocumentVerification extends DocumentVerificationBase {
  DocumentVerification({
    this.file,
    this.imageData,
    int numberOfTextMatches = 2,
    CountryType? country = CountryType.colombia,
    SideType? side = SideType.frontSide,
    List<String>? keyWords,
  })  : assert(
          (kIsWeb && imageData != null && file == null) ||
              (!kIsWeb && imageData == null && file != null),
          'Only use File for App and Unit8List for Web',
        ),
        super(
          country: country!,
          side: side!,
          keyWords: keyWords,
          numberOfTextMatches: numberOfTextMatches,
        );

  File? file;
  Uint8List? imageData;

  Future<bool> validateOneFace({int maxFaces = 2}) async {
    if (kIsWeb) {
      return await TextImageProcessingForWeb.instance
          .recognizePersonInPhoto(imageData!);
    }

    return await validateFaces(
      maxFaces: maxFaces,
      file: Platform.isIOS ? await compressFile(file!) : file,
    );
  }

  Future<bool> validateKeyWordsInFile() async {
    bool hasText = false;
    if (kIsWeb) {
      String ocrText = await TextImageProcessingForWeb.instance
          .recognizeTextInImage(imageData!);
      for (String palabra in keyWordsToValidate) {
        if (ocrText.toLowerCase().contains(palabra)) {
          hasText = true;
        }
      }
    } else {
      MLTextResponse response = await checkMLText(file: file);
      return response.success;
    }
    return hasText;
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
