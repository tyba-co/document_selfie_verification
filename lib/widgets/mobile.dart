part of document_selfie_verification.widgets;

class Mobile extends DocumentSelfieVerificationState {
  bool showID = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.side.isSelfie) {
        return;
      }
      if (widget.skipValidation) {
        showID = false;
        setState(() {});
      } else {
        Timer(const Duration(seconds: 4), () {
          showID = false;
          if (mounted) {
            setState(() {});
          }
        });
      }
    });

    super.initState();
  }

  Widget get loadImage {
    String backImage = 'assets/id_ghost_back.svg';
    String frontLeft = 'assets/id_ghost_frontal_left.svg';
    String frontRight = 'assets/id_ghost_frontal_right.svg';

    String imageToRender = switch (widget.side) {
      SideType.frontSide when widget.country == CountryType.colombia =>
        frontRight,
      SideType.backSide => backImage,
      SideType.frontSide => frontLeft,
      _ => frontLeft,
    };

    return SvgPicture.asset(
      imageToRender,
      package: 'document_selfie_verification',
      width: MediaQuery.of(context).size.width * 0.45,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!(controller?.value.isInitialized ?? false)) {
      return widget.loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    EdgeInsets padding = MediaQuery.of(context).padding;

    double appBarHeight = padding.top + kToolbarHeight;
    double bodyHeight = height - appBarHeight;

    double marginBottom = padding.bottom + 42;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: !widget.side.isSelfie
            ? Colors.transparent
            : const Color(0xff28363e),
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
      body: !widget.side.isSelfie
          ? Stack(
              children: [
                SizedBox(
                  width: width,
                  height: height,
                  child: CameraPreview(controller!),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTapUp: onTapUp,
                        child: CustomPaint(
                            painter:
                                DocumentPainter(Colors.black.withOpacity(0.6)),
                            size: Size(
                              double.infinity,
                              height,
                            )),
                      ),
                    ),
                    ColoredBox(
                      color: const Color(0xff28363e),
                      child: SizedBox(
                        width: 100 + marginBottom,
                        height: height,
                        child: Center(
                          child: InkWell(
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
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  bottom: 32,
                  right: 100 + marginBottom + 30,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        showModal ? Colors.white : Colors.transparent,
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.lightBlue,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.help_outline_outlined),
                        color:
                            showModal ? const Color(0xff28363e) : Colors.white,
                        onPressed: () async {
                          showModal = !showModal;
                          setState(() {});

                          showDialog<void>(
                              barrierDismissible: true,
                              useRootNavigator: true,
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (BuildContext context) {
                                return Material(
                                  color: Colors.transparent,
                                  child: Center(
                                      child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: height,
                                      maxWidth: width,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 30, right: 100 + marginBottom),
                                      child: Center(
                                          child: DecoratedBox(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color:
                                                Colors.black.withOpacity(0.6)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    const Icon(
                                                      Icons.info_outline,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                        'Cara ${widget.side == SideType.frontSide ? 'frontal' : 'posterior'} del\ndocumento',
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Colors.white))
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                                const Text(
                                                    '• Ubica tu documento de identidad\n completo dentro del marco.\n• Usa buena iluminación, evita reflejos\n y texturas en el fondo.\n• Asegúrate que el rostro y los datos\n son legibles.',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white)),
                                              ]),
                                        ),
                                      )),
                                    ),
                                  )),
                                );
                              });

                          Timer(
                            const Duration(seconds: 3),
                            closeInfoModal,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: showID,
                  child: Positioned(
                    bottom: 80,
                    left: width * 0.20,
                    child: loadImage,
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
            )
          : Padding(
              padding: EdgeInsets.only(top: appBarHeight),
              child: Stack(
                children: [
                  SizedBox(
                    width: width,
                    height: bodyHeight,
                    child: CameraPreview(controller!),
                  ),
                  GestureDetector(
                    onTapUp: onTapUp,
                    child: CustomPaint(
                        painter: SelfiePainter(
                            const Color(0xff28363E).withOpacity(0.6)),
                        size: Size(
                          width,
                          bodyHeight,
                        )),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Pon cara de ${emoji.label}',
                          style: const TextStyle(
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
                            border:
                                Border.all(color: Colors.white, width: 1.5)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
