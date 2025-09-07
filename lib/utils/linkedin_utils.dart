class LinkedInUtils {
  /// Returns a LinkedIn embed URL if the input contains a valid LinkedIn UGC/Share URN.
  /// Supports inputs like:
  /// - https://www.linkedin.com/feed/update/urn:li:ugcPost:7370138266773258240/
  /// - https://www.linkedin.com/embed/feed/update/urn:li:ugcPost:7370138266773258240
  /// - https://www.linkedin.com/posts/username_urn%3Ali%3AugcPost%3A7370138266773258240
  /// - urn:li:ugcPost:7370138266773258240
  static String? toEmbedUrl(String anyUrlOrUrn) {
    if (anyUrlOrUrn.isEmpty) return null;
    final decoded = Uri.decodeFull(anyUrlOrUrn.trim());

    // Try to find a URN pattern in the string
    final urnRegex =
        RegExp(r'urn:li:(ugcPost|share):[0-9]+', caseSensitive: false);
    final match = urnRegex.firstMatch(decoded);
    if (match != null) {
      final urn = match.group(0)!;
      return 'https://www.linkedin.com/embed/feed/update/$urn';
    }

    // If the string already looks like an embed URL, return it normalized
    if (decoded.contains('linkedin.com/embed/feed/update/')) {
      return decoded.replaceAll(RegExp(r'[?#].*$'), '');
    }

    // If it is a standard feed URL with a URN after .../update/...
    final feedRegex = RegExp(
        r'linkedin\.com/(?:feed/)?update/(urn:li:(?:ugcPost|share):[0-9]+)',
        caseSensitive: false);
    final feedMatch = feedRegex.firstMatch(decoded);
    if (feedMatch != null) {
      final urn = feedMatch.group(1)!;
      return 'https://www.linkedin.com/embed/feed/update/$urn';
    }

    return null;
  }
}
