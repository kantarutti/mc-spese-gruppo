class Partecipante {
  final String id;
  final String eventoId;
  final String cellulare;
  final String? gruppoId;

  Partecipante({
    required this.id,
    required this.eventoId,
    required this.cellulare,
    this.gruppoId,
  });

  factory Partecipante.fromMap(Map<String, dynamic> map) {
    return Partecipante(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      cellulare: map['cellulare'] ?? '',
      gruppoId: map['gruppo_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'cellulare': cellulare,
      'gruppo_id': gruppoId,
    };
  }
}
