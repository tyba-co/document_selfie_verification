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

  @override
  void initState() {
    logger = Logger();
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
    super.initState();
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
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    controller!.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      timer = Timer(
        Duration(
            seconds: widget.skipValidation ? 0 : widget.secondsToShowButton),
        switchAutomaticToOnDemand,
      );

      await controller!.setFlashMode(FlashMode.off);
      await controller!.setFocusMode(FocusMode.auto);

      if (!widget.skipValidation) {
        await startStream(cameraDescription);
      }

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

  Future<(Uint8List, DocumentSelfieException?)> handleDocument(
    DocumentVerification documentSelfieVerification,
  ) async {
    Uint8List castToUin8List =
        (await documentSelfieVerification.file?.readAsBytes()) ??
            documentSelfieVerification.imageData!;

    if (widget.skipValidation) {
      return (castToUin8List, null);
    }

    bool checkMLText =
        await documentSelfieVerification.validateKeyWordsInFile();
    bool hasFaces = await documentSelfieVerification.validateFaces(
        file: documentSelfieVerification.file);

    if (checkMLText && hasFaces) {
      return (castToUin8List, null);
    }

    return (
      castToUin8List,
      DocumentSelfieException(DocumentSelfieExceptionType.notRecognizeAnything)
    );
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
      Uint8List? imageConvert =
          await ConvertNativeImgStream().convertImgToBytes(
        availableImage.planes.first.bytes,
        availableImage.width,
        availableImage.height,
        rotationFix: -360,
      );

      widget.onImageCallback(imageConvert!);
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

      widget.onImageCallback(imageConvert!);
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]);
      setState(() {});
      return;
    }
    logger.i(DocumentSelfieExceptionType.notRecognizeSelfie.message);
    return;
  }

  Future<(Uint8List, DocumentSelfieException?)> handleSelfie(
    DocumentVerification documentSelfieVerification,
  ) async {
    Uint8List castToUin8List =
        (await documentSelfieVerification.file?.readAsBytes()) ??
            documentSelfieVerification.imageData!;
    if (widget.skipValidation) {
      return (castToUin8List, null);
    }

    bool isValid =
        await documentSelfieVerification.validateOneFace(maxFaces: 1);

    if (isValid) {
      return (castToUin8List, null);
    }

    return (
      castToUin8List,
      DocumentSelfieException(DocumentSelfieExceptionType.notRecognizeSelfie)
    );
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

    await controller!.setExposurePoint(point);
    await controller!.setFocusPoint(point);

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
    attempsToSkipValidationCounter++;
    (Uint8List, DocumentSelfieException?) response;
    if (isSelfie) {
      response = await handleSelfie(document);
    } else {
      response = await handleDocument(document);
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]);
    }

    closeLoading();
    widget.onImageCallback(response.$1, exception: response.$2);
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
