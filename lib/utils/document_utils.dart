class DocumentUtils {
  // Limpia el número de documento dejando solo números (y k si fuese necesario, aunque doc number suele ser numérico)
  static String clean(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // Formatea: 123456789 -> 123.456.789
  static String format(String documentNumber) {
    String cleaned = clean(documentNumber);
    if (cleaned.isEmpty) return documentNumber;

    String formatted = '';
    int count = 0;

    // Recorremos de atrás para adelante
    for (int i = cleaned.length - 1; i >= 0; i--) {
      formatted = cleaned[i] + formatted;
      count++;
      if (count % 3 == 0 && i > 0) {
        formatted = '.$formatted';
      }
    }

    return formatted;
  }
}
