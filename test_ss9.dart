void main() {
  String text1 = "takaran saji lemak 1 g";
  String text2 = "takaran saji 3O g lemak 1 g";
  String text3 = "takaran saji / serving size 30 g";
  String text4 = "takaran saji (10 g)";
  String text5 = "takaran saji : lO g";

  RegExp servingSizeRegex = RegExp(
    r'(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*([a-z]{1,7})',
    caseSensitive: false,
  );

  for (var text in [text1, text2, text3, text4, text5]) {
    var ssMatch = servingSizeRegex.firstMatch(text);
    if (ssMatch != null) {
      print("Match for '$text': ${ssMatch.group(1)} ${ssMatch.group(2)}");
    } else {
      print("No match for '$text'");
    }
  }
}
