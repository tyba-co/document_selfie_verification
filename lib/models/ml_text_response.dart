part of document_verification.models;

class MLTextResponse {
  MLTextResponse({
    required this.blocks,
    required this.keyWords,
  });

  List<TextBlock> blocks;
  List<String> keyWords;

  Map<String, dynamic> get blocksAndKeyword => keyWords.fold(
        {},
        (previousValue, element) {
          bool test(TextBlock value) {
            String textValue = value.text.withoutDiacriticalMarks;
            return textValue.toLowerCase().contains(element.toLowerCase());
          }

          bool match = blocks.any(test);

          previousValue[element] = match;

          return previousValue;
        },
      );

  bool get success => blocksAndKeyword.keys.every(
        (element) => blocksAndKeyword[element],
      );
}
