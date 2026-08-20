void main() {
  String text1 = "takaran saji 3 butir energi total";
  String text2 = "takaran saji 50 g lemak total";
  String text3 = "takaran saji 2 lembar";

  RegExp servingSizeRegex = RegExp(
    r'(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*([a-z]{1,7})',
    caseSensitive: false,
  );

  for (var text in [text1, text2, text3]) {
    var ssMatch = servingSizeRegex.firstMatch(text);
    if (ssMatch != null) {
      print("Match for '$text': ${ssMatch.group(1)} ${ssMatch.group(2)}");
    } else {
      print("No match for '$text'");
    }
  }
}
