/// Classe centralizzata per le validazioni
class AppValidators {
  /// Valida che il campo non sia vuoto
  static String? validateRequired(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName è obbligatorio';
    }
    return null;
  }

  /// Valida una email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email è obbligatoria';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Inserisci un\'email valida';
    }

    return null;
  }

  /// Valida un numero di telefono
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefono è obbligatorio';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Inserisci un numero di telefono valido (minimo 10 cifre)';
    }

    return null;
  }

  /// Valida un numero (intero o decimale)
  static String? validateNumber(String? value, {String fieldName = 'Numero'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName è obbligatorio';
    }

    final number = double.tryParse(value.replaceAll(',', '.'));

    if (number == null) {
      return 'Inserisci un $fieldName valido';
    }

    return null;
  }

  /// Valida un importo (numero positivo)
  static String? validateAmount(String? value) {
    final numValidation = validateNumber(value, fieldName: 'Importo');
    if (numValidation != null) return numValidation;

    final amount = double.parse(value!.replaceAll(',', '.'));

    if (amount <= 0) {
      return 'L\'importo deve essere maggiore di 0';
    }

    return null;
  }

  /// Valida una lunghezza minima
  static String? validateMinLength(
    String? value, {
    required int minLength,
    String fieldName = 'Campo',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName è obbligatorio';
    }

    if (value.length < minLength) {
      return '$fieldName deve avere almeno $minLength caratteri';
    }

    return null;
  }

  /// Valida una lunghezza massima
  static String? validateMaxLength(
    String? value, {
    required int maxLength,
    String fieldName = 'Campo',
  }) {
    if (value == null) return null;

    if (value.length > maxLength) {
      return '$fieldName non può superare $maxLength caratteri';
    }

    return null;
  }

  /// Valida una password (min 6 caratteri)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password è obbligatoria';
    }

    if (value.length < 6) {
      return 'Password deve avere almeno 6 caratteri';
    }

    return null;
  }

  /// Valida che due campi corrispondano
  static String? validateMatch(
    String? value,
    String? otherValue, {
    String fieldName = 'Campo',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName è obbligatorio';
    }

    if (value != otherValue) {
      return 'I campi non corrispondono';
    }

    return null;
  }

  /// Valida una valuta (formato: EUR, USD, JPY, ecc.)
  static String? validateCurrency(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Seleziona una valuta';
    }

    if (value.length != 3 || !RegExp(r'^[A-Z]{3}$').hasMatch(value)) {
      return 'Valuta deve essere in formato ISO (es. EUR, USD)';
    }

    return null;
  }

  /// Valida un nome (non vuoto, no numeri)
  static String? validateName(String? value, {String fieldName = 'Nome'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName è obbligatorio';
    }

    if (value.length < 2) {
      return '$fieldName deve avere almeno 2 caratteri';
    }

    if (RegExp(r'\d').hasMatch(value)) {
      return '$fieldName non può contenere numeri';
    }

    return null;
  }

  /// Valida una data (deve essere nel futuro)
  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return 'Data è obbligatoria';
    }

    if (value.isBefore(DateTime.now())) {
      return 'La data deve essere nel futuro';
    }

    return null;
  }

  /// Valida una data (deve essere nel passato)
  static String? validatePastDate(DateTime? value) {
    if (value == null) {
      return 'Data è obbligatoria';
    }

    if (value.isAfter(DateTime.now())) {
      return 'La data deve essere nel passato';
    }

    return null;
  }

  /// Valida un range di date
  static String? validateDateRange(
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null || endDate == null) {
      return 'Entrambe le date sono obbligatorie';
    }

    if (endDate.isBefore(startDate)) {
      return 'La data finale deve essere dopo la data iniziale';
    }

    return null;
  }

  /// Valida un numero di persone
  static String? validateNumberOfPeople(String? value) {
    final numValidation = validateNumber(value, fieldName: 'Numero persone');
    if (numValidation != null) return numValidation;

    final number = int.parse(value!);

    if (number <= 0) {
      return 'Il numero di persone deve essere almeno 1';
    }

    if (number > 1000) {
      return 'Il numero di persone non può superare 1000';
    }

    return null;
  }

  /// Valida una selezione da dropdown
  static String? validateSelection(
    dynamic value, {
    String fieldName = 'Campo',
  }) {
    if (value == null) {
      return 'Seleziona un $fieldName';
    }

    return null;
  }

  /// Valida che almeno un elemento sia selezionato da una lista
  static String? validateAtLeastOneSelected(
    List<dynamic> selectedItems, {
    String fieldName = 'elemento',
  }) {
    if (selectedItems.isEmpty) {
      return 'Seleziona almeno un $fieldName';
    }

    return null;
  }

  /// Combina più validazioni
  static String? validateMultiple(List<String?> validations) {
    for (final validation in validations) {
      if (validation != null) {
        return validation;
      }
    }
    return null;
  }
}