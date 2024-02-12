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

  InputImage get inputImage =>
      inputImageFromCameraImage(image, cameraDescription, controller)!;

  Map<DeviceOrientation, int> orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? inputImageFromCameraImage(
    CameraImage image,
    CameraDescription cameraDescription,
    CameraController controller,
  ) {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to
    //convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection`
    //can be used to compensate `x` and `y` coordinates on a canvas

    int sensorOrientation = cameraDescription.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      int? rotationCompensation =
          orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (cameraDescription.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    InputImageFormat? format =
        InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    Plane plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}
