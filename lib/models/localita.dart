class Localita {
  final String id;
  final String eventoId;
  final String nome;

  Localita({
    required this.id,
    required this.eventoId,
    required this.nome,
  });

  factory Localita.fromMap(Map<String, dynamic> map) {
    return Localita(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      nome: map['localita'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'localita': nome,
    };
  }
}
