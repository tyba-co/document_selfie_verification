part of document_selfie_verification.enums;

enum SideType {
  selfie('SELFIE'),
  frontSide('FRONT_SIDE'),
  backSide('BACK_SIDE');

  const SideType(this.value);

  factory SideType.fromString(String type) => switch (type) {
        'GESTURE' => selfie,
        'FRONT' => frontSide,
        'BACK' => backSide,
        _ => selfie,
      };

  bool get isFrontSide => this == frontSide;
  bool get isBackSide => this == backSide;
  bool get isSelfie => this == selfie;

  final String value;
}
