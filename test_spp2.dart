void main() {
  String text1 = "10 sajian perkemasan";
  String text2 = "10 perkemasan";
  String text3 = "perkemasan 10";

  RegExp sppFallbackRegex = RegExp(
    r'([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)\s*(?:sajian|sejian|serving|perkemasan|kemasan)',
    caseSensitive: false,
  );
  RegExp sppFallbackAfterRegex = RegExp(
    r'(?:jumlah\s*sajian|jumlah\s*sejian|sajian|sejian|serving|perkemasan|kemasan).{0,10}?([0-9oOlI]+(?:\s*[.,]\s*[0-9oOlI]+)?)',
    caseSensitive: false,
  );
  
  for (var text in [text1, text2, text3]) {
    var sppMatch = sppFallbackRegex.firstMatch(text) ?? sppFallbackAfterRegex.firstMatch(text);
    if (sppMatch != null) {
      print("Match for '$text': ${sppMatch.group(1)}");
    } else {
      print("No match for '$text'");
    }
  }
}
