void main() {
  String text1 = "takaran saji lemak 1 g";
  String text2 = "takaran saji 3O g lemak 1 g";
  String text3 = "takaran saji / serving size 30 g";
  String text4 = "takaran saji (10 g)";
  String text5 = "takaran saji : lO g";
  String text6 = "takaran saji 30gram";
  String text7 = "takaran saji 2butir"; // Might fail, but rare.
  String text8 = "takaran saji 2 butir";

  RegExp servingSizeRegex = RegExp(
    r'(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)(?:\s*(bungkus|keping|sajian|sejian|porsi|gram|cup|sdm|sdt|bks|gr|ml|oz|g|q|9)|\s+([a-z]{1,7}))\b',
    caseSensitive: false,
  );

  for (var text in [text1, text2, text3, text4, text5, text6, text7, text8]) {
    var ssMatch = servingSizeRegex.firstMatch(text);
    if (ssMatch != null) {
      String unit = ssMatch.group(2) ?? ssMatch.group(3) ?? "";
      print("Match for '$text': ${ssMatch.group(1)} $unit");
    } else {
      print("No match for '$text'");
    }
  }
}
