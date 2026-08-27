class PhoneService {
  /// Normalizza un numero di telefono in formato internazionale.
  /// Regole:
  /// - rimuove spazi, simboli, parentesi, trattini, punti
  /// - accetta solo cifre e il simbolo +
  /// - converte prefissi tipo 0039 → +39
  /// - SE NON inizia con + → ERRORE (prefisso mancante)
  /// - restituisce il numero nel formato: +<prefisso><numero>
  static String normalize(String raw) {
    if (raw.isEmpty) {
      throw FormatException("Numero di telefono vuoto");
    }

    // 1️⃣ Rimuove tutto tranne cifre e +
    String n = raw.replaceAll(RegExp(r'[^0-9+]'), '');

    // 2️⃣ Se inizia con 00 → converte in +
    if (n.startsWith("00")) {
      n = "+${n.substring(2)}";
    }

    // 3️⃣ Se NON inizia con + → errore
    if (!n.startsWith("+")) {
      throw FormatException("Manca il prefisso internazionale (+)");
    }

    // 4️⃣ Controllo che dopo il + ci siano solo cifre
    final afterPlus = n.substring(1);
    if (!RegExp(r'^[0-9]+$').hasMatch(afterPlus)) {
      throw FormatException("Il numero contiene caratteri non validi");
    }

    return n;
  }
}
