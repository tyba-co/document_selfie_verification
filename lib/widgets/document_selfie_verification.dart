part of document_selfie_verification.widgets;

class DocumentSelfieVerification extends StatefulWidget {
  const DocumentSelfieVerification({
    required this.side,
    required this.country,
    required this.onTakePhoto,
    this.loadingWidget,
    this.onPressBackButton,
    this.onError,
    super.key,
  });
  final SideType side;
  final void Function()? onPressBackButton;
  final Widget? loadingWidget;
  final CountryType country;
  final void Function(File response) onTakePhoto;
  final void Function(dynamic error)? onError;

  @override
  State<DocumentSelfieVerification> createState() =>
      DocumentSelfieVerificationState.fromPlatform();
}
