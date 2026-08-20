void main() {
  String text1 = "takaran saji lemak 1 g";
  String text2 = "takaran saji 3O g lemak 1 g";
  String text3 = "takaran saji / serving size 30 g";

  RegExp oldRegex = RegExp(
    r'(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian).{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*([a-z]{1,7})',
    caseSensitive: false,
  );
  
  RegExp newRegex = RegExp(
    r'(?:takaran\s*saji|takaran\s*sajian|takaran|ukuran\s*saji|serving\s*size|jumlah\s*persajian)[^\d]{0,40}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*([a-z]{1,7})',
    caseSensitive: false,
  );

  for (var text in [text1, text2, text3]) {
    var oldMatch = oldRegex.firstMatch(text);
    var newMatch = newRegex.firstMatch(text);
    print("Text: $text");
    print("Old: ${oldMatch?.group(1)} ${oldMatch?.group(2)}");
    print("New: ${newMatch?.group(1)} ${newMatch?.group(2)}");
    print("---");
  }
}
