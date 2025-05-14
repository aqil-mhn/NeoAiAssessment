extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

String formatHtmlString(String string) {
  return string
      .replaceAll("<p>", "\n") // Paragraphs
      // .replaceAll("</p>", "\n") // Paragraphs
      .replaceAll("<br/>", "\n") // Line Breaks
      // .replaceAll("\"", "&quot;") // Quote Marks
      // .replaceAll("'", "&apos;") // Apostrophe
      // .replaceAll(">", "&lt;") // Less-than Comparator (Strip Tags)
      // .replaceAll("<", "&gt;") // Greater-than Comparator (Strip Tags)
      .trim(); // Whitespace
}
