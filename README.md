# DocumentSelfieVerification Widget

This widget provides a comprehensive solution for capturing and verifying both documents and selfies within a Flutter application. It seamlessly integrates camera access, image processing, and validation features to ensure a smooth user experience.

## Key Features:

* **Document and Selfie Capture**: Captures both document and selfie images using the device's camera.
* **Automatic Image Processing**: Processes images in real-time to detect text, faces, and validate their quality.
* **Customizable Validation**: Offers parameters to adjust validation criteria for text and faces.
* **Guidance for Users**: Displays clear instructions and feedback to guide users during the capture process.
* **Image Success Callback**: Provides a callback function to handle successful image captures.

## Usage:

* **Add Dependency**: Include the document_verification package in your pubspec.yaml file.
* **Import Widget**: Import the DocumentSelfieVerification widget in your Dart file.
* **Instantiate Widget**: Create an instance of the widget, providing necessary parameters:



<?code-excerpt "main.dart (DocumentSelfieVerification)"?>
``` dart
DocumentSelfieVerification(
  imageSuccessCallback: (imageBytes) {
    // Handle successful image capture here
  },
  side: SideType.frontSide,
  country: CountryType.colombia,
  imageSkip: 50,
  // Other optional parameters
)
```

### Attributes:

| Attribute                  | Type                     | Description                                                                                                                               |
|----------------------------|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| side                       | Side                     | Specifies the side of the document or selfie to be captured. Possible values:<br>Side.selfie,<br>Side.frontSide,<br>Side.backSide.        |
| country                    | CountryType              | Specifies the country for text validation. Possible values: <br>CountryType.colombia,<br>CountryType.peru,<br>CountryType.chile.          |
| imageSkip                  | int                      | Determines how many frames to skip between processing images. Default value: 50.                                                          |
| imageSuccessCallback       | void Function(Uint8List) | A callback function that is invoked when a successful image capture occurs. The function receives the captured image data as a Uint8List. |
| loadingWidget              | Widget?                  | An optional widget to display while the camera is initializing. If not provided, a default progress indicator will be displayed.          |
| dontRecognizeAnythingLabel | String                   | The text to display when no text or faces are recognized in the image.                                                                    |
| almostOneIsSuccessLabel    | String                   | The text to display when text is recognized but needs improvement (e.g., better focus or lighting).                                       |
| dontRecognizeSelfieLabel   | String                   | The text to display when a selfie is not recognized.                                                                                      |
| keyWords                   | List<String>?            | An optional list of keywords to validate in the text recognized from the document image. 

## External Dependencies:

**camera: This library is essential for camera access and image capture. Ensure it's included in your project's dependencies. Installation instructions can be found at https://pub.dev/packages/camera.**

## Additional Notes:

* **Orientation**: The widget automatically adjusts screen orientation to optimize capture for documents and selfies.
Feedback: The widget provides visual feedback to guide users during capture, including focus indicators and instructional labels.
* **Error Handling**: The widget includes error handling for camera access issues.
