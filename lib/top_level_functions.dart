import 'dart:io';

import 'package:camera/camera.dart';
import 'package:convert_native_img_stream/convert_native_img_stream.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as mlkit;
import 'package:image/image.dart' as imglib;

Future<Uint8List?> streamSelfieImageConverter(
    CameraImage availableImage) async {
  Uint8List? imageConvert;
  if (Platform.isAndroid) {
    imageConvert = await ConvertNativeImgStream().convertImgToBytes(
      availableImage.planes.first.bytes,
      availableImage.width,
      availableImage.height,
      rotationFix: -90,
    );
  } else {
    Plane plane = availableImage.planes.first;
    imglib.Image image = imglib.Image.fromBytes(
      width: availableImage.width,
      height: availableImage.height,
      bytes: plane.bytes.buffer,
      rowStride: plane.bytesPerRow,
      order: imglib.ChannelOrder.bgra,
    );

    imageConvert = imglib.encodeJpg(image);
  }
  return imageConvert;
}

Future<Uint8List?> streamDocumentImageConverter(
    CameraImage availableImage) async {
  return await ConvertNativeImgStream().convertImgToBytes(
    availableImage.planes.first.bytes,
    availableImage.width,
    availableImage.height,
    rotationFix: -360,
  );
}

mlkit.InputImage? inputImageFromCameraImage(
  CameraImage image,
  CameraDescription cameraDescription,
  DeviceOrientation deviceOrientation,
) {
  // get image rotation
  // it is used in android to convert the InputImage from Dart to Java
  // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
  // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas

  final sensorOrientation = cameraDescription.sensorOrientation;
  mlkit.InputImageRotation? rotation;
  if (Platform.isIOS) {
    rotation = mlkit.InputImageRotationValue.fromRawValue(sensorOrientation);
  } else if (Platform.isAndroid) {
    Map<DeviceOrientation, int> orientations = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };

    var rotationCompensation = orientations[deviceOrientation];
    if (rotationCompensation == null) return null;
    if (cameraDescription.lensDirection == CameraLensDirection.front) {
      // front-facing
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      // back-facing
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }
    rotation = mlkit.InputImageRotationValue.fromRawValue(rotationCompensation);
  }
  if (rotation == null) return null;

  // get image format
  final format = mlkit.InputImageFormatValue.fromRawValue(image.format.raw);
  // validate format depending on platform
  // only supported formats:
  // * nv21 for Android
  // * bgra8888 for iOS
  if (format == null ||
      (Platform.isAndroid && format != mlkit.InputImageFormat.nv21) ||
      (Platform.isIOS && format != mlkit.InputImageFormat.bgra8888)) {
    return null;
  }

  // since format is constraint to nv21 or bgra8888, both only have one plane
  if (image.planes.length != 1) return null;
  final plane = image.planes.first;

  // compose InputImage using bytes
  return mlkit.InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: mlkit.InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation, // used only in Android
      format: format, // used only in iOS
      bytesPerRow: plane.bytesPerRow, // used only in iOS
    ),
  );
}
