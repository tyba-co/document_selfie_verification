part of document_selfie_verification.widgets;

abstract class DocumentSelfieVerificationState
    extends State<DocumentSelfieVerification> {
  DocumentSelfieVerificationState();
  factory DocumentSelfieVerificationState.fromPlatform() =>
      kIsWeb ? Web() : Mobile();

  CameraController? controller;
  int imageCounter = 0;
  int attempsToSkipValidationCounter = 0;
  bool showFocusCircle = false;
  bool showButton = false;
  double x = 0;
  double y = 0;
  late Logger logger;
  late Timer timer;
  late CameraDescription cameraDescription;

  bool get isSelfie => widget.side == SideType.selfie;
  bool get skipValidation =>
      attempsToSkipValidationCounter >= widget.attempsToSkipValidation;

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

      // unawaited(
      //   SystemChrome.setEnabledSystemUIMode(
      //     SystemUiMode.manual,
      //     overlays: <SystemUiOverlay>[],
      //   ),
      // );
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
            widget.onException(DocumentSelfieException(
                DocumentSelfieExceptionType.cameraAccessDenied));
            break;
          default:
            widget.onError(error);
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
        await handleSelfieStream(
            documentSelfieVerificationStream, availableImage);
      } else {
        await handleDocumentStream(
            documentSelfieVerificationStream, availableImage);
      }
    });
  }

  Future<void> switchAutomaticToOnDemand() async {
    controller?.stopImageStream();
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
    DocumentVerification documentSelfieVerification,
  ) async {
    attempsToSkipValidationCounter++;

    Uint8List castToUin8List =
        (await documentSelfieVerification.file?.readAsBytes()) ??
            documentSelfieVerification.imageData!;

    if (skipValidation) {
      widget.imageSuccessCallback(castToUin8List);
      return;
    }

    bool checkMLText =
        await documentSelfieVerification.validateKeyWordsInFile();
    bool hasFaces = await documentSelfieVerification.validateFaces();

    if (checkMLText && hasFaces) {
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]);

      widget.imageSuccessCallback(castToUin8List);
      setState(() {});
      return;
    }

    widget.onException(DocumentSelfieException(
        DocumentSelfieExceptionType.notRecognizeAnything));
  }

  Future<void> handleDocumentStream(
    DocumentSelfieVerificationStream documentSelfieVerificationStream,
    CameraImage availableImage,
  ) async {
    MLTextResponse checkMLText =
        await documentSelfieVerificationStream.checkMLText(
      inputImage: documentSelfieVerificationStream.inputImage,
    );
    bool hasFaces = await documentSelfieVerificationStream.validateFaces(
      inputImage: documentSelfieVerificationStream.inputImage,
    );

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
      logger.i(DocumentSelfieExceptionType.notRecognizeAnything.message);
      return;
    }

    if (checkMLText.almostOneIsSuccess) {
      logger.i(DocumentSelfieExceptionType.almostOneIsSuccess.message);
      return;
    }
  }

  Future<void> handleSelfieStream(
    DocumentSelfieVerificationStream documentSelfieVerificationStream,
    CameraImage availableImage,
  ) async {
    bool isValid = await documentSelfieVerificationStream.validateFaces(
      maxFaces: 1,
      inputImage: documentSelfieVerificationStream.inputImage,
    );

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
    logger.i(DocumentSelfieExceptionType.notRecognizeSelfie.message);
    return;
  }

  Future<void> handleSelfie(
    DocumentVerification documentSelfieVerification,
  ) async {
    attempsToSkipValidationCounter++;
    Uint8List castToUin8List =
        (await documentSelfieVerification.file?.readAsBytes()) ??
            documentSelfieVerification.imageData!;
    if (skipValidation) {
      widget.imageSuccessCallback(castToUin8List);
      return;
    }

    bool isValid =
        await documentSelfieVerification.validateOneFace(maxFaces: 1);

    if (isValid) {
      widget.imageSuccessCallback(castToUin8List);
      return;
    }

    widget.onException(DocumentSelfieException(
        DocumentSelfieExceptionType.notRecognizeSelfie));
  }

  @override
  void dispose() {
    controller?.dispose();
    timer.cancel();
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

  Future<void> takePhoto() async {
    showLoading();
    XFile? xFile = await getFile();

    if (xFile == null) {
      throw 'Unread File';
    }

    File file = File(xFile.path);

    DocumentVerification document = DocumentVerification(
      file: file,
      side: widget.side,
      country: widget.country,
      keyWords: widget.keyWords,
      numberOfTextMatches: widget.numberOfTextMatches,
    );

    if (isSelfie) {
      await handleSelfie(document);
    } else {
      await handleDocument(document);
    }
    closeLoading();
  }

  void showLoading() {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      useSafeArea: false,
      builder: (BuildContext _) =>
          widget.loadingWidget ??
          SizedBox(
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
      useRootNavigator: false,
    );
  }

  void closeLoading() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
