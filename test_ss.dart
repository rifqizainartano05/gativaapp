void main() {
  String text = "takaran saji 30 g";

  RegExp servingSizeRegex = RegExp(
    r'(?:takaran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram)',
    caseSensitive: false,
  );
  RegExp servingSizeBeforeRegex = RegExp(
    r'([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram).{0,20}?(?:takaran\s*saji|serving\s*size|jumlah\s*persajian)',
    caseSensitive: false,
  );
  var ssMatch = servingSizeRegex.firstMatch(text) ?? servingSizeBeforeRegex.firstMatch(text);
  if (ssMatch != null) {
    print("${ssMatch.group(1)} ${ssMatch.group(2)}");
  } else {
    print("No match");
  }
}
