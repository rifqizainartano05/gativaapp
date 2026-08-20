void main() {
  String badText = "sajian per kemasan plus " * 20;

  RegExp sppAfterRegex = RegExp(
    r'(?:sajian|sejian|serving|takaran|porsi).{0,30}?(?:kemasan|container|bungkus|pack|wadah|amount).{0,15}?(?:\+|-|±|~)?\s*([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)',
    caseSensitive: false,
  );
  
  print("Testing sppAfterRegex...");
  Stopwatch sw = Stopwatch()..start();
  sppAfterRegex.hasMatch(badText);
  print("sppAfterRegex took ${sw.elapsedMilliseconds} ms");
}
