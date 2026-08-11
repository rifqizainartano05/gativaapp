void main() {
  String fullText = 'takaran saji 20 g 3 sajian per kemasan jumlah per sajian energi total 110 kkal';
  
  RegExp sppBeforeRegex = RegExp(
    r'([0-9]+(?:\s*[., ]\s*[0-9]+)?)\s*(?:±|~|\+|-)?\s*[^0-9]{0,10}?(?:sajian\s*(?:per|tiap)\s*(?:kemasan|bungkus|wadah)|servings\s*per\s*container|jumlah\s*sajian|sajian\s*perkemasan)',
    caseSensitive: false,
  );
  RegExp sppAfterRegex = RegExp(
    r'(?:sajian\s*(?:per|tiap)\s*(?:kemasan|bungkus|wadah)|servings\s*per\s*container|jumlah\s*sajian|sajian\s*perkemasan)\s*(?:±|~|\+|-|:)?\s*[^0-9]{0,15}?([0-9]+(?:\s*[., ]\s*[0-9]+)?)',
    caseSensitive: false,
  );
  RegExp sppShortRegex = RegExp(
    r'([0-9]+(?:\s*[., ]\s*[0-9]+)?)\s*(?:±|~|\+|-)?\s*[^0-9]{0,10}?(?:sajian|porsi|servings)(?!\s*per)',
    caseSensitive: false,
  );
  
  var sppMatchBefore = sppBeforeRegex.firstMatch(fullText);
  var sppMatchAfter = sppAfterRegex.firstMatch(fullText);
  var sppMatchShort = sppShortRegex.firstMatch(fullText);
  
  print('After: ${sppMatchAfter?.group(1)}');
  print('Before: ${sppMatchBefore?.group(1)}');
  print('Short: ${sppMatchShort?.group(1)}');
}
