class Spesa {
  final String id;
  final String gruppoId;
  final String eventoId;
  final DateTime data;
  final String? localita;
  final String valutaOrigine;
  final double importo;
  final String? tipologia;
  final String? causale;
  final String valutaTarget;
  final double tassoCambio;
  final double spesa;

  Spesa({
    required this.id,
    required this.gruppoId,
    required this.eventoId,
    required this.data,
    this.localita,
    required this.valutaOrigine,
    required this.importo,
    this.tipologia,
    this.causale,
    required this.valutaTarget,
    required this.tassoCambio,
    required this.spesa,
  });

  factory Spesa.fromMap(Map<String, dynamic> map) {
    return Spesa(
      id: map['id'] ?? '',
      gruppoId: map['gruppo_id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      data: map['data'] != null ? DateTime.parse(map['data']) : DateTime.now(),
      localita: map['localita'],
      valutaOrigine: map['valuta_origine'] ?? 'EUR',
      importo: (map['importo'] ?? 0.0).toDouble(),
      tipologia: map['tipologia'],
      causale: map['causale'],
      valutaTarget: map['valuta_target'] ?? 'EUR',
      tassoCambio: (map['tasso_cambio'] ?? 1.0).toDouble(),
      spesa: (map['spesa'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gruppo_id': gruppoId,
      'evento_id': eventoId,
      'data': data.toIso8601String(),
      'localita': localita,
      'valuta_origine': valutaOrigine,
      'importo': importo,
      'tipologia': tipologia,
      'causale': causale,
      'valuta_target': valutaTarget,
      'tasso_cambio': tassoCambio,
      'spesa': spesa,
    };
  }
}
