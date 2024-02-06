part of document_selfie_verification.models;

class MLTextResponse {
  MLTextResponse({
    required this.blocks,
    required this.keyWords,
    required this.numberOfTextMatches,
  });

  List<TextBlock> blocks;
  List<String> keyWords;
  int numberOfTextMatches;

  Map<String, dynamic> get blocksAndKeyword => keyWords.fold(
        {},
        (previousValue, element) {
          bool test(TextBlock value) {
            String textValue = value.text.withoutDiacriticalMarks;
            bool isContain =
                textValue.toLowerCase().contains(element.toLowerCase());
            return isContain;
          }

          bool match = blocks.any(test);

          previousValue[element] = match;

          return previousValue;
        },
      );

  bool get success {
    List<String> response = blocksAndKeyword.keys
        .where(
          (element) => blocksAndKeyword[element],
        )
        .toList();
    return response.length >= numberOfTextMatches;
  }

  bool get almostOneIsSuccess => blocksAndKeyword.keys.any(
        (element) => blocksAndKeyword[element],
      );

  bool get dontRecognizeAnything => blocksAndKeyword.keys.every(
        (element) => blocksAndKeyword[element] == false,
      );
}
