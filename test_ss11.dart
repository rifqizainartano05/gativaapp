void main() {
  String text1 = "takaran saji 30 g";
  String text2 = "1 bungkus takaran saji";
  
  RegExp servingSizeRegex = RegExp(
    r'(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)(?:\s*(bungkus|keping|sajian|sejian|porsi|gram|cup|sdm|sdt|bks|gr|ml|oz|g|q|9)|\s+([a-z]{1,7}))\b',
    caseSensitive: false,
  );
  RegExp servingSizeBeforeRegex = RegExp(
    r'(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)(?:\s*(bungkus|keping|sajian|sejian|porsi|gram|cup|sdm|sdt|bks|gr|ml|oz|g|q|9)|\s+([a-z]{1,7}))\b.{0,20}?(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian)',
    caseSensitive: false,
  );

  for (var text in [text1, text2]) {
    var ssMatch = servingSizeRegex.firstMatch(text) ?? servingSizeBeforeRegex.firstMatch(text);
    if (ssMatch != null) {
      String unit = ssMatch.groupCount >= 3 ? (ssMatch.group(2) ?? ssMatch.group(3) ?? "") : (ssMatch.group(2) ?? "");
      print("Match for '$text': ${ssMatch.group(1)} $unit");
    } else {
      print("No match for '$text'");
    }
  }
}
