part of document_selfie_verification.widgets;

class DocumentSelfieVerification extends StatefulWidget {
  const DocumentSelfieVerification({
    required this.onImageCallback,
    required this.side,
    required this.country,
    required this.onException,
    required this.onError,
    this.secondsToShowButton = 10,
    this.skipValidation = false,
    this.numberOfTextMatches = 2,
    this.seconsToStartImageProcess = 3,
    this.minPhysicalMemory = 3000,
    this.loadingWidget,
    this.keyWords,
    this.onPressBackButton,
    super.key,
  });
  final SideType side;
  final CountryType country;
  final int secondsToShowButton;
  final bool skipValidation;
  final int numberOfTextMatches;
  final int seconsToStartImageProcess;
  final int minPhysicalMemory;
  final void Function(
    Uint8List, {
    EmojiType? emoji,
    DocumentSelfieException? exception,
  }) onImageCallback;
  final void Function(Object) onError;
  final void Function(DocumentSelfieException) onException;
  final void Function()? onPressBackButton;
  final Widget? loadingWidget;
  final List<String>? keyWords;

  @override
  State<DocumentSelfieVerification> createState() =>
      DocumentSelfieVerificationState.fromPlatform();
}
