part of document_selfie_verification.widgets;

abstract class DocumentSelfieVerificationState
    extends State<DocumentSelfieVerification> {
  DocumentSelfieVerificationState();
  factory DocumentSelfieVerificationState.fromPlatform() =>
      kIsWeb ? Web() : Mobile();

  CameraController? controller;
  double x = 0;
  double y = 0;
  double _currentScale = 1.5;
  int attempsToRotation = 0;
  bool showModal = false;
  bool showFocusCircle = false;
  late Logger logger;
  EmojiType? emoji;
  Timer? timer;

  @override
  void initState() {
    logger = Logger();
    if (widget.side.isSelfie) {
      emoji = EmojiType.randomEmoji();
    }

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
    try {
      List<CameraDescription> cameras = await availableCameras();
      bool isSelfie = widget.side.isSelfie;
      int cameraIndex = isSelfie ? 1 : 0;
      CameraDescription cameraDescription = cameras[cameraIndex];
      controller = CameraController(
        cameraDescription,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller!.initialize();
      if (!mounted) {
        return;
      }
      await rotateCamera(controller!);

      unawaited(controller?.setFlashMode(FlashMode.off));
      unawaited(controller?.setFocusMode(FocusMode.auto));
      if (!isSelfie) {
        unawaited(controller?.setZoomLevel(_currentScale));
      }

      setState(() {});
    } catch (error) {
      widget.onError?.call(error);
    }
  }

  void closeInfoModal() {
    if (showModal && mounted) {
      showModal = !showModal;
      setState(() {});
      Navigator.of(context).pop();
    }
  }

  Future<XFile?> getFile() async {
    if (controller!.value.isTakingPicture) {
      return null;
    }
    XFile file = await controller!.takePicture();
    return file;
  }

  void close() {
    if (controller?.value.isStreamingImages ?? false) {
      controller!.stopImageStream();
    }
    controller?.dispose();
    timer?.cancel();
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  Future<void> takePhoto() async {
    try {
      showLoading();
      XFile? xFile = await getFile();

      if (xFile == null) {
        throw 'Unread File';
      }

      File file = File(xFile.path);

      if (mounted) {
        closeLoading();
      }
      if (!widget.side.isSelfie) {
        await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
          DeviceOrientation.portraitUp,
        ]);
      }
      widget.onTakePhoto(
        file,
        emoji,
      );
    } catch (error) {
      widget.onError?.call(error);
    }
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
    try {
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
    } catch (error) {
      if (attempsToRotation <= 3) {
        await rotateCamera(controller);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
