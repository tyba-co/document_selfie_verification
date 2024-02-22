# DocumentSelfieVerification Widget

This widget provides a comprehensive solution for capturing and verifying both documents and selfies within a Flutter application. It seamlessly integrates camera access, image processing, and validation features to ensure a smooth user experience.

## How Works:

It starts using the camera stream which allows validating in real time if the selfie document meets the basic validations.
If after 10 seconds the Stream has not been able to validate the image, a button will immediately be displayed so that the user can capture it manually.

## Validations:

- **Selfie** : Valid that a face exists.
- **DNI** : It validates that a face exists and also validates that the texts that MLKit finds in the document match the keywords. The number of matches to validate the document is configurable through the numberOfTextMatches parameter.

## Key Features:

- **Document and Selfie Capture**: Captures both document and selfie images using the device's camera.
- **Automatic Image Processing**: Processes images in real-time to detect text, faces, and validate their quality.
- **Customizable Validation**: Offers parameters to adjust validation criteria for text and faces.
- **Guidance for Users**: Displays clear instructions and feedback to guide users during the capture process.
- **Image Callback**: Provides a callback function to handle successful image captures.

## Usage:

- **Add Dependency**: Include the document_selfie_verification package in your pubspec.yaml file.
- **Import Widget**: Import the DocumentSelfieVerification widget in your Dart file.
- **Instantiate Widget**: Create an instance of the widget, providing necessary parameters:

<?code-excerpt "main.dart (DocumentSelfieVerification)"?>

```dart
DocumentSelfieVerification(
      side: SideType.selfie,
      country: CountryType.colombia,
      skipValidation: skipValidation,
      onImageCallback: (
        Uint8List imageConvert, {
        DocumentSelfieException? exception,
      }) {
        counter++;
        if (exception != null && !skipValidation) {
          this.exception = exception;
        }
        imageToShow = Image.memory(imageConvert);
        setState(() {});
      },
      onException: (DocumentSelfieException e) {
        logger.i('onException $e');
      },
      onError: (Object e) {
        logger.e('onError $e');
      },
    )
```

### Attributes:

| Attribute               | Type                                                                            | Description                                                                                                                                                                                                                   |
| ----------------------- | ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| side                    | Side                                                                            | Specifies the side of the document or selfie to be captured. Possible values:<br>Side.selfie,<br>Side.frontSide,<br>Side.backSide.                                                                                            |
| country                 | CountryType                                                                     | Specifies the country for text validation. Possible values: <br>CountryType.colombia,<br>CountryType.peru,<br>CountryType.chile.                                                                                              |
| skipValidation          | bool                                                                            | It determines whether to validate the image with MlKit and also does not take into account the time in which the button is displayed and only allows consumption on demand, that is, through the button. Default value: false |
| numberOfTextMatches     | int                                                                             | Determines how many matches it finds between MLKit texts and keywords to validate an image. Default value : 2                                                                                                                 |
| secondsToShowButton     | int                                                                             | Determines how many seconds to show button. Default value : 10.                                                                                                                                                               |
| onImageCallback         | void Function(Uint8List, {EmojiType? emoji,DocumentSelfieException? exception}) | A callback function that is invoked when image capture occurs. The function receives the captured image data as a Uint8List, exception as DocumentSelfieException? and emoji EmojiType?                                       |
| onError                 | void Function(Object)                                                           | A callback function that is invoked when error occurs                                                                                                                                                                         |
| onException             | void Function(DocumentSelfieException) onException                              | A callback function that is invoked when exception occurs                                                                                                                                                                     |
| onPressBackButton       | void Function()?                                                                | A callback function when tap ui back button                                                                                                                                                                                   |
| secondsToShowButton | int > 0                                                                         | In order to improve the experience, a delay is added that allows the time to initialize image processing to be delayed.                                                                                                       |

|
| minPhysicalMemory | int > 0                                                                         | Min physical memory for Stream validation.                                                                                                       |

|
| loadingWidget | Widget? | An optional widget to display while the camera is initializing. If not provided, a default progress indicator will be displayed. |

| keyWords | List<String>? | An optional list of keywords to validate in the text recognized from the document image. |

## External Dependencies:

**camera: This library is essential for camera access and image capture. Ensure it's included in your project's dependencies. Installation instructions can be found at https://pub.dev/packages/camera.**

## Additional Notes:

- **Orientation**: The widget automatically adjusts screen orientation to optimize capture for documents and selfies.
  Feedback: The widget provides visual feedback to guide users during capture, including focus indicators and instructional labels.
- **Error Handling**: The widget includes error handling for camera access issues.
