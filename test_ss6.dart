void main() {
  String text = "informasi nilai gizi takaran saji 30 g";

  RegExp servingSizeRegex = RegExp(
    r'(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(bungkus|keping|sajian|sejian|porsi|gram|cup|sdm|sdt|bks|gr|ml|oz|g|q|9|[a-z]{1,7})',
    caseSensitive: false,
  );
  RegExp servingSizeBeforeRegex = RegExp(
    r'([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(bungkus|keping|sajian|sejian|porsi|gram|cup|sdm|sdt|bks|gr|ml|oz|g|q|9|[a-z]{1,7}).{0,20}?(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian)',
    caseSensitive: false,
  );

  var ssMatch = servingSizeRegex.firstMatch(text) ?? servingSizeBeforeRegex.firstMatch(text);
  if (ssMatch != null) {
    print("Match: ${ssMatch.group(1)} ${ssMatch.group(2)}");
  } else {
    print("No match");
  }
}
