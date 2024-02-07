part of document_selfie_verification.enums;

enum EmojiType {
  happy('happiness', 'Felicidad 🙂'),
  unger('anger', 'Enfado 😤'),
  surprise('surprise', 'Sorpresa 😲'),
  sad('sadness', 'Tristeza 😞');

  const EmojiType(this.value, this.label);

  final String value;
  final String label;

  factory EmojiType.randomEmoji() {
    List<EmojiType> elements = <EmojiType>[
      EmojiType.happy,
      EmojiType.sad,
      EmojiType.surprise,
      EmojiType.unger,
    ]..shuffle();

    return elements.first;
  }
}
