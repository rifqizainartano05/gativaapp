void main() {
  String fullText = 'sajian per kemasan +2 5';
  RegExp sppAfterRegex = RegExp(
    r'(?:sajian\s*per\s*kemasan|servings\s*per\s*container|jumlah\s*sajian\s*per\s*kemasan|sajian\s*per\s*bungkus|sajian\s*perkemasan)\s*(?:±|~|\+|-|:)?\s*.{0,30}?([0-9oOlI]+(?:\s*[.,\s]\s*[0-9oOlI]+)?)',
    caseSensitive: false,
  );
  var match = sppAfterRegex.firstMatch(fullText);
  String captured = match?.group(1) ?? '';
  print("Captured: '$captured'");
  
  if (captured.contains(RegExp(r'\s')) && !captured.contains('.') && !captured.contains(',')) {
     captured = captured.replaceAll(RegExp(r'\s+'), '.');
  } else {
     captured = captured.replaceAll(' ', '');
  }
  
  print("Result: $captured");
}
