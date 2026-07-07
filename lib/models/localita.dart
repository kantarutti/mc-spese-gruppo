/// Modello per una Località
class Localita {
  final String id;
  final String eventoId;
  final String nome;
  final DateTime createdAt;
  final DateTime updatedAt;

  Localita({
    required this.id,
    required this.eventoId,
    required this.nome,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una Località da una mappa (da Supabase)
  factory Localita.fromMap(Map<String, dynamic> map) {
    return Localita(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      nome: map['localita'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  /// Converte la Località in una mappa (per Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'localita': nome,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia della Località con valori modificati
  Localita copyWith({
    String? id,
    String? eventoId,
    String? nome,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Localita(
      id: id ?? this.id,
      eventoId: eventoId ?? this.eventoId,
      nome: nome ?? this.nome,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Localita(id: $id, nome: $nome)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Localita &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          eventoId == other.eventoId;

  @override
  int get hashCode => id.hashCode ^ eventoId.hashCode;
}