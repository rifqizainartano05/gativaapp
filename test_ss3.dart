void main() {
  String text1 = "takaran saji 50 gram";
  String text2 = "takaran saji : 15 g";
  String text3 = "takaran saji: 15 g";
  String text4 = "takaran saji 50gram";

  RegExp servingSizeRegex = RegExp(
    r'(?:takaran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram|q|9)',
    caseSensitive: false,
  );
  RegExp servingSizeBeforeRegex = RegExp(
    r'([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram|q|9).{0,20}?(?:takaran\s*saji|serving\s*size|jumlah\s*persajian)',
    caseSensitive: false,
  );

  for (var text in [text1, text2, text3, text4]) {
    var ssMatch = servingSizeRegex.firstMatch(text) ?? servingSizeBeforeRegex.firstMatch(text);
    if (ssMatch != null) {
      print("Match for '$text': ${ssMatch.group(1)} ${ssMatch.group(2)}");
    } else {
      print("No match for '$text'");
    }
  }
}
