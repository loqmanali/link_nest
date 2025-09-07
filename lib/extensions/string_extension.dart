extension StringCasingExtension on String {
  /// Capitalize the first character of the string safely.
  /// Returns the original string if it is empty.
  String capitalize() {
    if (isEmpty) return this;
    final first = this[0].toUpperCase();
    if (length == 1) return first;
    return '$first${substring(1)}';
  }

  /// Capitalize the first letter of each word (space-delimited)
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ') // simple split by space, adjust if you need punctuation handling
        .map((word) {
          if (word.isEmpty) return word;
          final first = word[0].toUpperCase();
          return word.length == 1 ? first : '$first${word.substring(1)}';
        })
        .join(' ');
  }
}
