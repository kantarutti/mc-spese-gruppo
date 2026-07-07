class Valuta {
  final String id;
  final String eventoId;
  final String sigla;

  Valuta({
    required this.id,
    required this.eventoId,
    required this.sigla,
  });

  factory Valuta.fromMap(Map<String, dynamic> map) {
    return Valuta(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      sigla: map['valuta'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'valuta': sigla,
    };
  }
}
