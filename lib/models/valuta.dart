/// Modello per una Valuta
class Valuta {
  final String id;
  final String eventoId;
  final String codice; // Es: EUR, USD, JPY
  final DateTime createdAt;
  final DateTime updatedAt;

  Valuta({
    required this.id,
    required this.eventoId,
    required this.codice,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una Valuta da una mappa (da Supabase)
  factory Valuta.fromMap(Map<String, dynamic> map) {
    return Valuta(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      codice: map['valuta'] ?? 'EUR',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  /// Converte la Valuta in una mappa (per Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'valuta': codice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia della Valuta con valori modificati
  Valuta copyWith({
    String? id,
    String? eventoId,
    String? codice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Valuta(
      id: id ?? this.id,
      eventoId: eventoId ?? this.eventoId,
      codice: codice ?? this.codice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Ritorna il simbolo della valuta (semplice mappatura)
  String get simbolo {
    switch (codice.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CHF':
        return 'CHF';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      default:
        return codice;
    }
  }

  /// Ritorna il nome completo della valuta
  String get nomeLungo {
    switch (codice.toUpperCase()) {
      case 'EUR':
        return 'Euro';
      case 'USD':
        return 'Dollaro Americano';
      case 'GBP':
        return 'Sterlina Britannica';
      case 'JPY':
        return 'Yen Giapponese';
      case 'CHF':
        return 'Franco Svizzero';
      case 'CAD':
        return 'Dollaro Canadese';
      case 'AUD':
        return 'Dollaro Australiano';
      default:
        return codice;
    }
  }

  @override
  String toString() => 'Valuta(id: $id, codice: $codice)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Valuta &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          codice == other.codice;

  @override
  int get hashCode => id.hashCode ^ codice.hashCode;
}