void main() {
  String text1 = "takaran saji 30 g";
  String text2 = "30 g takaran saji";
  String text3 = "informasi nilai gizi takaran saji 30 g 100 mg natrium";

  RegExp servingSizeRegex = RegExp(
    r'(?:takaran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram)',
    caseSensitive: false,
  );
  RegExp servingSizeBeforeRegex = RegExp(
    r'([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(g|gr|ml|oz|cup|sdm|sdt|keping|bks|bungkus|porsi|sajian|sejian|gram).{0,20}?(?:takaran\s*saji|serving\s*size|jumlah\s*persajian)',
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
