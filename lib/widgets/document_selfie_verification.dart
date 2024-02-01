part of document_selfie_verification.widgets;

class DocumentSelfieVerification extends StatefulWidget {
  const DocumentSelfieVerification({
    required this.imageSuccessCallback,
    required this.side,
    required this.country,
    required this.accessPermisionErrorCallback,
    this.errorCallback,
    this.streamFramesToSkipValidation = 50,
    this.secondsToShowButton = 10,
    this.attempsToSkipValidation = 3,
    this.numberOfTextMatches = 2,
    this.dontRecognizeAnythingLabel =
        'Todo el documento debe estar dentro del recuadro , información y foto.',
    this.almostOneIsSuccessLabel =
        'Asegurate de que el documento este bien enfocado y no tenga brillos o sombras.',
    this.dontRecognizeSelfieLabel =
        'Asegurate de que tu rostro salga completo. Solo se admite un solo rostro.',
    this.loadingWidget,
    this.keyWords,
    this.onPressBackButton,
    super.key,
  });
  final SideType side;
  final CountryType country;
  final int streamFramesToSkipValidation;
  final int secondsToShowButton;
  final int attempsToSkipValidation;
  final int numberOfTextMatches;
  final void Function(Uint8List) imageSuccessCallback;
  final void Function(Object)? errorCallback;
  final void Function() accessPermisionErrorCallback;
  final void Function()? onPressBackButton;
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
  bool showButton = false;
  double x = 0;
  double y = 0;
  late Logger logger;
  late Timer timer;
  late CameraDescription cameraDescription;

  bool get isSelfie => widget.side == SideType.selfie;

  @override
  void initState() {
    super.initState();
    logger = Logger();
    timer = Timer(
      Duration(seconds: widget.secondsToShowButton),
      switchAutomaticToOnDemand,
    );

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
    cameraDescription = cameras[cameraIndex];

    controller = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    controller!.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      await controller!.setFlashMode(FlashMode.off);

      await startStream(cameraDescription);
      setState(() {});
    }).catchError((Object error) {
      if (error is CameraException) {
        switch (error.code) {
          case 'CameraAccessDenied':
            widget.accessPermisionErrorCallback();
            break;
          default:
            widget.errorCallback?.call(error);
            break;
        }
      }
    });
  }

  Future<void> startStream(CameraDescription cameraDescription) async {
    await controller!.startImageStream((CameraImage availableImage) async {
      imageCounter++;
      if (imageCounter % widget.streamFramesToSkipValidation != 0) {
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
        numberOfTextMatches: widget.numberOfTextMatches,
      );

      if (isSelfie) {
        await handleSelfie(documentSelfieVerificationStream, availableImage);
      } else {
        await handleDocument(documentSelfieVerificationStream, availableImage);
      }
    });
  }

  Future<void> switchAutomaticToOnDemand() async {
    controller!.stopImageStream();
    showButton = true;
    setState(() {});
  }

  Future<XFile?> getFile() async {
    if (controller!.value.isTakingPicture) {
      return null;
    }
    XFile file = await controller!.takePicture();
    return file;
  }

  Future<void> handleDocument(
    DocumentSelfieVerificationStream documentSelfieVerificationStream,
    CameraImage availableImage,
  ) async {
    MLTextResponse checkMLText =
        await documentSelfieVerificationStream.checkMLText(
      inputImage: documentSelfieVerificationStream.inputImage,
    );
    bool hasFaces = await documentSelfieVerificationStream.validateFaces();

    if (checkMLText.success && hasFaces) {
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
      logger.i(widget.dontRecognizeAnythingLabel);
      return;
    }

    if (checkMLText.almostOneIsSuccess) {
      logger.i(widget.almostOneIsSuccessLabel);
      return;
    }
  }

  Future<void> handleSelfie(
    DocumentSelfieVerificationStream documentSelfieVerificationStream,
    CameraImage availableImage,
  ) async {
    bool isValid =
        await documentSelfieVerificationStream.validateFaces(maxFaces: 1);

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
    logger.i(widget.dontRecognizeSelfieLabel);
    return;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> onTapUp(TapUpDetails details) async {
    print('onTapUp');
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

  Future<void> takePhoto() async {
    // XFile? xFile = await getFile();

    // if (xFile == null) {
    //   throw 'Unread File';
    // }

    // File file = File(xFile.path);

    // DocumentVerification document = DocumentVerification(
    //   file: file,
    //   side: widget.side,
    //   country: widget.country,
    //   keyWords: widget.keyWords,
    //   numberOfTextMatches: widget.numberOfTextMatches,
    // );

    //     DocumentSelfieVerificationStream(
    //   cameraDescription: cameraDescription,
    //   controller: controller!,
    //   image: availableImage,
    //   side: widget.side,
    //   country: widget.country,
    //   keyWords: widget.keyWords,
    //   numberOfTextMatches: widget.numberOfTextMatches,
    // );
    // widget.imageSuccessCallback(await file.readAsBytes());
  }

  @override
  Widget build(BuildContext context) {
    if (!(controller?.value.isInitialized ?? false)) {
      return widget.loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
    double bodyHeight = MediaQuery.of(context).size.height - appBarHeight;

    double marginBottom = MediaQuery.of(context).padding.bottom + 42;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff28363e),
        leading: IconButton(
          key: const Key('back_button'),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: widget.onPressBackButton,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: EdgeInsets.only(top: appBarHeight),
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: bodyHeight,
              child: CameraPreview(controller!),
            ),
            GestureDetector(
              onTapUp: onTapUp,
              child: CustomPaint(
                  painter: isSelfie
                      ? SelfiePainter(Color(0xff28363E).withOpacity(0.6))
                      : DocumentPainter(Colors.black.withOpacity(0.6)),
                  size: Size(
                    MediaQuery.of(context).size.width,
                    bodyHeight,
                  )),
            ),
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Mantén tu rostro centrado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 24 / 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  InkWell(
                    onTap: takePhoto,
                    child: Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: showButton,
                      child: CustomPaint(
                        painter: CicularButtonPainter(Colors.white),
                        size: const Size(
                          64,
                          64,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: marginBottom,
                  ),
                ],
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
