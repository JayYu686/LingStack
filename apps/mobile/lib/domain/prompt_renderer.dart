String renderPromptTemplate(String body, Map<String, String> values) {
  return body.replaceAllMapped(RegExp(r'{{\s*([^}]+)\s*}}'), (match) {
    final key = match.group(1)?.trim() ?? '';
    final replacement = values[key];
    if (replacement == null || replacement.trim().isEmpty) {
      return match.group(0) ?? '';
    }
    return replacement;
  });
}

String sanitizeRenderedPrompt(String text) {
  final withoutPlaceholders = text.replaceAll(RegExp(r'{{\s*[^}]+\s*}}'), '');
  return withoutPlaceholders
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .trim();
}
