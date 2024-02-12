part of document_selfie_verification.extensions;

extension DiacriticsAwareString on String {
  static const String diacritics =
      '''ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËĚèéêëěðČÇçčÐĎďÌÍÎÏìíîïĽľÙÚÛÜŮùúûüůŇÑñňŘřŠšŤťŸÝÿýŽž''';
  static const String nonDiacritics =
      '''AAAAAAaaaaaaOOOOOOOooooooEEEEEeeeeeeCCccDDdIIIIiiiiLlUUUUUuuuuuNNnnRrSsTtYYyyZz''';

  String get withoutDiacriticalMarks => splitMapJoin(
        '',
        onNonMatch: (String char) =>
            char.isNotEmpty && diacritics.contains(char)
                ? nonDiacritics[diacritics.indexOf(char)]
                : char,
      );
}
