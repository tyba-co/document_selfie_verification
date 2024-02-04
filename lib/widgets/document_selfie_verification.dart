part of document_selfie_verification.widgets;

class DocumentSelfieVerification extends StatefulWidget {
  const DocumentSelfieVerification({
    required this.imageSuccessCallback,
    required this.side,
    required this.country,
    required this.onException,
    required this.onError,
    this.streamFramesToSkipValidation = 50,
    this.secondsToShowButton = 10,
    this.attempsToSkipValidation = 3,
    this.numberOfTextMatches = 2,
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
  final void Function(Object) onError;
  final void Function(DocumentSelfieException) onException;
  final void Function()? onPressBackButton;
  final Widget? loadingWidget;
  final List<String>? keyWords;

  @override
  State<DocumentSelfieVerification> createState() =>
      DocumentSelfieVerificationState.fromPlatform();
}
