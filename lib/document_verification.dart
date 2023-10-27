library document_verification;

import 'dart:io';
import 'dart:math' as math;

import 'constants/constants.dart';
import 'js/text_and_image_processing_web.dart';
import 'enums/enums.dart';
import 'models/models.dart';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';

class DocumentVerification {
  DocumentVerification({
    this.file,
    this.imageData,
    this.keyWords,
    this.country = CountryType.colombia,
    this.side = SideType.frontSide,
    this.validateOneFaceExist = true,
  }) : assert(
          (kIsWeb && imageData != null && file == null) ||
              (!kIsWeb && imageData == null && file != null),
          'Only use File for App and Unit8List for Web',
        );

  bool validateOneFaceExist;
  File? file;
  Uint8List? imageData;
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

  Future<bool> validate() async {
    bool hasOnlyOneFace = validateOneFaceExist ? await validateOneFace() : true;
    bool hasText = await validateKeyWordsInFile(keyWords ?? defaultKeyWords);

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

    FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
      ),
    );

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
