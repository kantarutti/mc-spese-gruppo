class LocalitaModel {
  final String id; // Modificato da int a String per supportare l'UUID di Supabase
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
      id: json['id'].toString(), // Converte l'UUID in String in modo sicuro
      localita: json['localita'] as String,
      eventoId: json['evento_id'].toString(), // Converte in String per sicurezza
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