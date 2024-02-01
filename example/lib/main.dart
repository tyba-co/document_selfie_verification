import 'package:document_selfie_verification/document_verification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      accessPermisionErrorCallback: () {
        print('Me toteo por permisos');
      },
      errorCallback: (Object e) {
        print('Me toteo en el error');
      },
    );
  }
}
