import 'package:document_selfie_verification/document_verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setPortrait();
  runApp(const MaterialApp(
    showPerformanceOverlay: true,
    home: ExampleWidget(),
  ));
}

Future<void> setPortrait() async {
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  Image? imageToShow;
  DocumentSelfieException? exception;
  late Logger logger;
  int counter = 0;
  bool imageLoading = false;

  bool get hasImage => imageToShow != null;
  bool get skipValidation => counter >= 3;

  @override
  void initState() {
    logger = Logger();
    super.initState();
  }

  void reset() {
    exception = null;
    imageToShow = null;
    imageLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (imageLoading) {
      return Scaffold(
        appBar: AppBar(
            leading: IconButton(
          key: const Key('back_button'),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.green,
            size: 24,
          ),
          onPressed: () {},
        )),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 300,
                child: InteractiveViewer(
                  maxScale: 5,
                  minScale: 1,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: imageToShow ?? const SizedBox.shrink(),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Text(
                exception != null
                    ? 'Vuelve a tomar tu Foto'
                    : '¿Tu documento es legible?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                exception != null
                    ? exception!.type.messageTranslate
                    : 'Antes de avanzar, confirma que el documento se encuentre centrado, sin recortes y que todos los datos del se puedan leer correctamente.',
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: exception != null
              ? SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green)),
                    onPressed: reset,
                    child: const Text(
                      'Repetir foto',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  width: 2.0, color: Colors.green),
                            ),
                            onPressed: reset,
                            child: const Text('Repetir foto',
                                style: TextStyle(color: Colors.green)))),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                        child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green)),
                      onPressed: () {},
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                  ],
                ),
        ),
      );
    }

    return DocumentSelfieVerification(
      side: SideType.frontSide,
      country: CountryType.colombia,
      skipValidation: skipValidation,
      timeToStartImageProcess: 5,
      onImageCallback: (
        Uint8List imageConvert, {
        EmojiType? emoji,
        DocumentSelfieException? exception,
      }) {
        imageLoading = true;
        setState(() {});
        counter++;
        if (exception != null && !skipValidation) {
          this.exception = exception;
        }

        Future.delayed(const Duration(milliseconds: 500), () {
          imageToShow = Image.memory(
            imageConvert,
            scale: 0.5,
          );
          setState(() {});
        });
      },
      onException: (DocumentSelfieException e) {
        logger.i('onException $e');
      },
      onError: (Object e) {
        logger.e('onError $e');
      },
    );
  }
}
