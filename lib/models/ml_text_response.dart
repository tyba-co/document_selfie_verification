part of document_selfie_verification.models;

class MLTextResponse {
  MLTextResponse({
    required this.blocks,
    required this.keyWords,
    required this.numberOfTextMatches,
    required this.country,
  });

  List<TextBlock> blocks;
  List<String> keyWords;
  int numberOfTextMatches;
  CountryType country;

  bool get isPe => country == CountryType.peru;

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

  bool isValidMRZCode() {
    if (blocks.isEmpty) {
      return false;
    }
    if (!isPe) {
      return true;
    }

    TextBlock lastBlock = blocks.last;
    bool hasMRZCode = lastBlock.text.contains('<');
    if (!hasMRZCode) {
      return true;
    }

    int blockLength = blocks.length;
    List<TextBlock> mrzBlocks = blocks.sublist(blockLength - 3);
    bool isTD1 = mrzBlocks.length == 3;
    bool allLinesHave20Char =
        mrzBlocks.every((element) => element.text.length == 30);
    return isTD1 && allLinesHave20Char;
  }

  bool get success {
    List<String> response = blocksAndKeyword.keys
        .where(
          (element) => blocksAndKeyword[element],
        )
        .toList();

    bool isValidMRZ = isValidMRZCode();

    return (response.length >= numberOfTextMatches) && isValidMRZ;
  }

  bool get almostOneIsSuccess => blocksAndKeyword.keys.any(
        (element) => blocksAndKeyword[element],
      );

  bool get dontRecognizeAnything => blocksAndKeyword.keys.every(
        (element) => blocksAndKeyword[element] == false,
      );
}
