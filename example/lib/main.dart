import 'package:document_selfie_verification/document_verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(
    home: ExampleWidget(),
  ));
}

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  Image? imageToShow;
  late Logger logger;

  @override
  void initState() {
    logger = Logger();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (imageToShow != null) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: imageToShow,
      );
    }

    return DocumentSelfieVerification(
      side: SideType.selfie,
      country: CountryType.peru,
      imageSuccessCallback: (Uint8List imageConvert) {
        imageToShow = Image.memory(imageConvert);
        setState(() {});
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
