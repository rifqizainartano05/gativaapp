void main() {
  String text1 = "takaran saji 50 gram";
  String text2 = "takaran saji : 15 g";
  String text3 = "takeran saji 15 g";

  RegExp servingSizeRegex = RegExp(
    r'(?:takar\w*\s*saj\w*|serving\s*size|jumlah\s*persajian|takaran).{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(bungkus|keping|sajian|sejian|porsi|gram|cup|sdm|sdt|bks|gr|ml|oz|g|q|9)',
    caseSensitive: false,
  );
  RegExp servingSizeBeforeRegex = RegExp(
    r'([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(bungkus|keping|sajian|sejian|porsi|gram|cup|sdm|sdt|bks|gr|ml|oz|g|q|9).{0,20}?(?:takar\w*\s*saj\w*|serving\s*size|jumlah\s*persajian|takaran)',
    caseSensitive: false,
  );

  for (var text in [text1, text2, text3]) {
    var ssMatch = servingSizeRegex.firstMatch(text) ?? servingSizeBeforeRegex.firstMatch(text);
    if (ssMatch != null) {
      print("Match for '$text': ${ssMatch.group(1)} ${ssMatch.group(2)}");
    } else {
      print("No match for '$text'");
    }
  }
}
