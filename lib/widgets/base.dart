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
  bool showModal = false;
  bool isDispose = false;
  bool isProcessing = false;
  double x = 0;
  double y = 0;
  late Logger logger;
  late Timer timer;
  late CameraDescription cameraDescription;
  late EmojiType emoji;
  late RootIsolateToken? rootIsolateToken;

  @override
  void initState() {
    rootIsolateToken = ServicesBinding.rootIsolateToken;
    logger = Logger();
    emoji = EmojiType.randomEmoji();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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

    int cameraIndex = widget.side.isSelfie ? 1 : 0;
    if (Platform.isIOS && cameras.length > 3 && !widget.side.isSelfie) {
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
      await controller!.setFocusMode(FocusMode.auto);
      await rotateCamera(controller!);

      if (!widget.skipValidation) {
        /* TODO: Ricardo  When the camera starts up it starts dark, 
         after a few frames it converts to a color image
        */
        Future.delayed(Duration(seconds: widget.timeToStartImageProcess), () {
          timer = Timer(
            Duration(
                seconds:
                    widget.skipValidation ? 0 : widget.secondsToShowButton),
            switchAutomaticToOnDemand,
          );
          startStream(cameraDescription);
        });
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

  void startStream(CameraDescription cameraDescription) {
    controller!.startImageStream((CameraImage availableImage) async {
      if (isProcessing) {
        return;
      }
      isProcessing = true;

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

      (Uint8List, DocumentSelfieException?) response = widget.side.isSelfie
          ? await handleSelfieStream(
              documentSelfieVerificationStream,
              availableImage,
            )
          : await handleDocumentStream(
              documentSelfieVerificationStream,
              availableImage,
            );

      if (response.$2 == null) {
        closeInfoModal();
        if (!widget.side.isSelfie) {
          await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
            DeviceOrientation.portraitUp,
          ]);
        }

        widget.onImageCallback(
          response.$1,
          exception: response.$2,
          emoji: emoji,
        );
      }
      isProcessing = false;
    });
  }

  void closeInfoModal() {
    if (showModal && mounted) {
      showModal = !showModal;
      setState(() {});
      Navigator.of(context).pop();
    }
  }

  Future<void> switchAutomaticToOnDemand() async {
    bool isStreamingImages = controller?.value.isStreamingImages ?? false;
    if (!widget.skipValidation && isStreamingImages) {
      controller!.stopImageStream();
    }
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

  Future<(Uint8List, DocumentSelfieException?)> handleDocumentStream(
    DocumentSelfieVerificationStream documentSelfieVerificationStream,
    CameraImage availableImage,
  ) async {
    mlkit.InputImage? inputImage = await compute(unifyThread, <dynamic>[
      'inputImageFromCameraImage',
      availableImage,
      cameraDescription,
      controller!.value.deviceOrientation,
      rootIsolateToken,
    ]) as mlkit.InputImage?;

    MLTextResponse checkMLText =
        await documentSelfieVerificationStream.checkMLText(
      inputImage: inputImage,
    );
    bool hasFaces = await documentSelfieVerificationStream.validateFaces(
      inputImage: inputImage,
    );

    Uint8List? imageConvert = await compute(unifyThread, <dynamic>[
      'streamDocumentImageConverter',
      availableImage,
      rootIsolateToken,
    ]) as Uint8List?;

    if (checkMLText.success && hasFaces) {
      return (imageConvert!, null);
    }

    if (checkMLText.almostOneIsSuccess) {
      return (
        imageConvert!,
        DocumentSelfieException(DocumentSelfieExceptionType.almostOneIsSuccess)
      );
    }

    return (
      imageConvert!,
      DocumentSelfieException(DocumentSelfieExceptionType.notRecognizeAnything)
    );
  }

  Future<(Uint8List, DocumentSelfieException?)> handleSelfieStream(
    DocumentSelfieVerificationStream documentSelfieVerificationStream,
    CameraImage availableImage,
  ) async {
    mlkit.InputImage? inputImage = await compute(unifyThread, <dynamic>[
      'inputImageFromCameraImage',
      availableImage,
      cameraDescription,
      controller!.value.deviceOrientation,
      rootIsolateToken,
    ]) as mlkit.InputImage?;

    bool isValid = await documentSelfieVerificationStream.validateFaces(
      maxFaces: 1,
      inputImage: inputImage,
    );

    Uint8List? imageConvert = await compute(unifyThread, [
      'streamSelfieImageConverter',
      availableImage,
      rootIsolateToken
    ]) as Uint8List?;

    if (isValid) {
      return (imageConvert!, null);
    }

    return (
      imageConvert!,
      DocumentSelfieException(DocumentSelfieExceptionType.notRecognizeSelfie)
    );
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

  void close() {
    if (controller?.value.isStreamingImages ?? false) {
      controller!.stopImageStream();
    }
    controller?.dispose();
    timer.cancel();
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }

  Future<void> onTapUp(TapUpDetails details) async {
    try {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * controller!.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp, yp);

      await controller?.setExposurePoint(point);
      await controller?.setFocusPoint(point);
      setState(() {
        Future.delayed(const Duration(seconds: 1)).whenComplete(() {
          setState(() {
            showFocusCircle = false;
          });
        });
      });
    } on Exception catch (_, __) {
      showFocusCircle = false;
      setState(() {});
    }
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
    (Uint8List, DocumentSelfieException?) response = widget.side.isSelfie
        ? await handleSelfie(document)
        : await handleDocument(document);

    closeLoading();
    if (!widget.side.isSelfie) {
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]);
    }
    widget.onImageCallback(
      response.$1,
      exception: response.$2,
      emoji: widget.side.isSelfie ? emoji : null,
    );
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

  Future<void> rotateCamera(CameraController controller) async {
    if (!widget.side.isSelfie) {
      if (Platform.isIOS) {
        await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
          DeviceOrientation.landscapeRight,
        ]);
        await controller
            .lockCaptureOrientation(DeviceOrientation.landscapeLeft);
      } else {
        await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
          DeviceOrientation.landscapeLeft,
        ]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
