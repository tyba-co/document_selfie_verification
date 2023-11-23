import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:convert_native_img_stream/convert_native_img_stream.dart';
import 'package:flutter/material.dart';
import 'package:document_verification/document_verification.dart';
import 'package:flutter/services.dart';
import 'custom_paint.dart';

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;
  int contador = 0;
  Image? imageToShow;
  String labelToShow =
      'Todo el documento debe estar dentro del recuadro , información y foto.';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(
        SystemChrome.setPreferredOrientations(<DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
        ]),
      );
      unawaited(
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: <SystemUiOverlay>[],
        ),
      );
      await initCamera();
    });
  }

  Future<void> initCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription cameraDescription = cameras[0];

    controller = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888,
    );

    controller!.initialize().then((_) async {
      if (!mounted) {
        return;
      }

      await controller!.startImageStream((CameraImage availableImage) async {
        contador++;
        if (contador % 50 != 0) {
          return;
        }

        DocumentVerificationStream documentVerificationStream =
            DocumentVerificationStream(
          cameraDescription: cameraDescription,
          controller: controller!,
          image: availableImage,
        );

        MLTextResponse checkMLText =
            await documentVerificationStream.checkMLText();
        bool hasOnlyOneFace = await documentVerificationStream.validateFaces();


        if (checkMLText.dontRecognizeAnything) {
          labelToShow =
              'Todo el documento debe estar dentro del recuadro , información y foto.';
          setState(() {});
          return;
        }

        if (checkMLText.almostOneIsSuccess) {
          labelToShow =
              'Asegurate de que el documento este bien enfocado y no tenga brillos o sombras. ';
          setState(() {});
          return;
        }

        if (checkMLText.success && hasOnlyOneFace && imageToShow == null) {
          Uint8List? imageConvert = await ConvertNativeImgStream()
              .convertImgToBytes(availableImage.planes.first.bytes,
                  availableImage.width, availableImage.height);

          imageToShow = Image.memory(imageConvert!);
          SystemChrome.setPreferredOrientations(<DeviceOrientation>[
            DeviceOrientation.portraitUp,
          ]);

          // Directory tempDir = await getTemporaryDirectory();
          // File decodedImageFile = File('${tempDir.path}/test2.jpeg')
          //   ..writeAsBytesSync(imageConvert!);
          // filePath = decodedImageFile.path;
        }

        setState(() {});
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(controller?.value.isInitialized ?? false)) {
      return Container();
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: imageToShow ?? CameraPreview(controller!),
          ),
          if (imageToShow == null) ...<Widget>[
            CustomPaint(
                painter: MyCustomPaint(Colors.black.withOpacity(0.6)),
                size: Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                )),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    labelToShow,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }
}
