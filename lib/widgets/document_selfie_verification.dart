part of document_selfie_verification.widgets;

class DocumentSelfieVerification extends StatefulWidget {
  const DocumentSelfieVerification({
    required this.imageSuccessCallback,
    required this.side,
    required this.country,
    this.imageSkip = 50,
    this.dontRecognizeAnythingLabel =
        'Todo el documento debe estar dentro del recuadro , información y foto.',
    this.almostOneIsSuccessLabel =
        'Asegurate de que el documento este bien enfocado y no tenga brillos o sombras.',
    this.dontRecognizeSelfieLabel =
        'Asegurate de que tu rostro salga completo. Solo se admite un solo rostro.',
    this.loadingWidget,
    this.keyWords,
    super.key,
  });
  final SideType side;
  final CountryType country;
  final int imageSkip;
  final void Function(Uint8List) imageSuccessCallback;
  final Widget? loadingWidget;
  final String dontRecognizeAnythingLabel;
  final String almostOneIsSuccessLabel;
  final String dontRecognizeSelfieLabel;
  final List<String>? keyWords;

  @override
  State<DocumentSelfieVerification> createState() =>
      _DocumentSelfieVerificationState();
}

class _DocumentSelfieVerificationState
    extends State<DocumentSelfieVerification> {
  CameraController? controller;
  int imageCounter = 0;
  bool showFocusCircle = false;
  double x = 0;
  double y = 0;
  late String labelToShow;

  bool get isSelfie => widget.side == SideType.frontSide;

  @override
  void initState() {
    super.initState();
    labelToShow = isSelfie
        ? widget.dontRecognizeSelfieLabel
        : widget.dontRecognizeAnythingLabel;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!isSelfie) {
        unawaited(
          SystemChrome.setPreferredOrientations(<DeviceOrientation>[
            DeviceOrientation.landscapeLeft,
          ]),
        );
      }

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
    int cameraIndex = isSelfie ? 1 : 0;
    if (Platform.isIOS && cameras.length > 3 && !isSelfie) {
      cameraIndex = cameras.length - 1;
    }
    CameraDescription cameraDescription = cameras[cameraIndex];

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
        imageCounter++;
        if (imageCounter % widget.imageSkip != 0) {
          return;
        }

        DocumentSelfieVerificationStream documentSelfieVerificationStream =
            DocumentSelfieVerificationStream(
          cameraDescription: cameraDescription,
          controller: controller!,
          image: availableImage,
          side: widget.side,
          country: widget.country,
          keyWords: widget.keyWords,
        );

        if (isSelfie) {
          await handleSelfie(documentSelfieVerificationStream, availableImage);
        } else {
          await handleDocument(
              documentSelfieVerificationStream, availableImage);
        }
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

  Future<void> handleDocument(
    DocumentSelfieVerificationStream documentSelfieVerificationStream,
    CameraImage availableImage,
  ) async {
    MLTextResponse checkMLText =
        await documentSelfieVerificationStream.checkMLText();
    bool hasOnlyOneFace =
        await documentSelfieVerificationStream.validateFaces();

    if (checkMLText.success && hasOnlyOneFace) {
      Uint8List? imageConvert = await ConvertNativeImgStream()
          .convertImgToBytes(availableImage.planes.first.bytes,
              availableImage.width, availableImage.height);
      widget.imageSuccessCallback(imageConvert!);
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]);
      setState(() {});
      return;
    }

    if (checkMLText.dontRecognizeAnything) {
      labelToShow = widget.dontRecognizeAnythingLabel;

      setState(() {});
      return;
    }

    if (checkMLText.almostOneIsSuccess) {
      labelToShow = widget.almostOneIsSuccessLabel;
      setState(() {});
      return;
    }
  }

  Future<void> handleSelfie(
    DocumentSelfieVerificationStream documentSelfieVerificationStream,
    CameraImage availableImage,
  ) async {
    bool isValid = await documentSelfieVerificationStream.validateFaces();

    if (isValid) {
      Uint8List? imageConvert =
          await ConvertNativeImgStream().convertImgToBytes(
        availableImage.planes.first.bytes,
        availableImage.width,
        availableImage.height,
        rotationFix: -90,
      );

      widget.imageSuccessCallback(imageConvert!);
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]);
      setState(() {});
      return;
    }
    labelToShow = widget.dontRecognizeSelfieLabel;
    setState(() {});
    return;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> onTapUp(TapUpDetails details) async {
    showFocusCircle = true;
    x = details.localPosition.dx;
    y = details.localPosition.dy;

    double fullWidth = MediaQuery.of(context).size.width;
    double cameraHeight = fullWidth * controller!.value.aspectRatio;

    double xp = x / fullWidth;
    double yp = y / cameraHeight;

    Offset point = Offset(xp, yp);

    await controller!.setFocusPoint(point);

    controller!.setExposurePoint(point);

    setState(() {
      Future.delayed(const Duration(seconds: 1)).whenComplete(() {
        setState(() {
          showFocusCircle = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!(controller?.value.isInitialized ?? false)) {
      return widget.loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTapUp: onTapUp,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CameraPreview(controller!),
            ),
            CustomPaint(
                painter: isSelfie
                    ? SelfiePainter(Colors.black.withOpacity(0.6))
                    : DocumentPainter(Colors.black.withOpacity(0.6)),
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
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if (showFocusCircle)
              Positioned(
                top: y - 20,
                left: x - 20,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
