void main() {
  String text1 = "lemak 1 g";
  String text2 = "2,5 sajian";
  String text3 = "2.5sajian";
  String text4 = "2,5";

  RegExp numRegex1 = RegExp(r'(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\b');
  RegExp numRegex2 = RegExp(r'(?<=[\s:(/]|^)([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)(?=\s|$)');

  for (var text in [text1, text2, text3, text4]) {
    print("Text: '$text'");
    var m1 = numRegex1.firstMatch(text);
    print(" Regex1 (\\b): ${m1?.group(1)}");
    var m2 = numRegex2.firstMatch(text);
    print(" Regex2 (?=\\s|\$): ${m2?.group(1)}");
  }
}
