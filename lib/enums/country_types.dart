part of document_verification.enums;

enum CountryType {
  colombia('COLOMBIA'),
  peru('PERU'),
  chile('CHILE');

  const CountryType(this.value);

  factory CountryType.fromString(String type) => switch (type) {
        'COLOMBIA' => colombia,
        'PERU' => peru,
        'CHILE' => chile,
        _ => colombia,
      };

  final String value;
}
