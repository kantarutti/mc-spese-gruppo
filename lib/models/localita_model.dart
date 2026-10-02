class LocalitaModel {
  final int id;
  final String localita;
  final String eventoId;
  final int? ordine;

  LocalitaModel({
    required this.id,
    required this.localita,
    required this.eventoId,
    this.ordine,
  });

  factory LocalitaModel.fromJson(Map<String, dynamic> json) {
    return LocalitaModel(
      id: json['id'] as int,
      localita: json['localita'] as String,
      eventoId: json['evento_id'] as String,
      ordine: json['ordine'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localita': localita,
      'evento_id': eventoId,
      'ordine': ordine,
    };
  }
}