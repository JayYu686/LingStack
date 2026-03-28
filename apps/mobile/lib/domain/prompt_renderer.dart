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
