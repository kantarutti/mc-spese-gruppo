/// Modello per un Partecipante
class Partecipante {
  final String id;
  final String eventoId;
  final String cellulare;
  final String gruppoId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Partecipante({
    required this.id,
    required this.eventoId,
    required this.cellulare,
    required this.gruppoId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea un Partecipante da una mappa (da Supabase)
  factory Partecipante.fromMap(Map<String, dynamic> map) {
    return Partecipante(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      cellulare: map['cellulare'] ?? '',
      gruppoId: map['gruppo_id'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  /// Converte il Partecipante in una mappa (per Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'cellulare': cellulare,
      'gruppo_id': gruppoId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia del Partecipante con valori modificati
  Partecipante copyWith({
    String? id,
    String? eventoId,
    String? cellulare,
    String? gruppoId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Partecipante(
      id: id ?? this.id,
      eventoId: eventoId ?? this.eventoId,
      cellulare: cellulare ?? this.cellulare,
      gruppoId: gruppoId ?? this.gruppoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Ritorna il cellulare formattato
  String get cellulareFormattato {
    // Rimuove spazi e formatta
    String cleaned = cellulare.replaceAll(' ', '');
    if (cleaned.length > 10) {
      return cleaned.substring(0, 3) +
          ' ' +
          cleaned.substring(3, 6) +
          ' ' +
          cleaned.substring(6);
    }
    return cellulare;
  }

  /// Verifica se il cellulare è valido
  bool get isCellulareValido {
    final cleaned = cellulare.replaceAll(RegExp(r'\D'), '');
    return cleaned.length >= 10;
  }

  @override
  String toString() =>
      'Partecipante(id: $id, cellulare: $cellulareFormattato, gruppo: $gruppoId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Partecipante &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          eventoId == other.eventoId;

  @override
  int get hashCode => id.hashCode ^ eventoId.hashCode;
}