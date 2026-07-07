class Giroconto {
  final String id;
  final String eventoId;
  final String daGruppoId;
  final String aGruppoId;
  final DateTime dataGiroconto;
  final String valutaOrigine;
  final double importo;
  final String valutaTarget;
  final double tassoCambio;
  final double giroconto;

  Giroconto({
    required this.id,
    required this.eventoId,
    required this.daGruppoId,
    required this.aGruppoId,
    required this.dataGiroconto,
    required this.valutaOrigine,
    required this.importo,
    required this.valutaTarget,
    required this.tassoCambio,
    required this.giroconto,
  });

  factory Giroconto.fromMap(Map<String, dynamic> map) {
    return Giroconto(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      daGruppoId: map['da_gruppo_id'] ?? '',
      aGruppoId: map['a_gruppo_id'] ?? '',
      dataGiroconto: map['data_giroconto'] != null
          ? DateTime.parse(map['data_giroconto'])
          : DateTime.now(),
      valutaOrigine: map['valuta_origine'] ?? 'EUR',
      importo: (map['importo'] ?? 0.0).toDouble(),
      valutaTarget: map['valuta_target'] ?? 'EUR',
      tassoCambio: (map['tasso_cambio'] ?? 1.0).toDouble(),
      giroconto: (map['giroconto'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'da_gruppo_id': daGruppoId,
      'a_gruppo_id': aGruppoId,
      'data_giroconto': dataGiroconto.toIso8601String(),
      'valuta_origine': valutaOrigine,
      'importo': importo,
      'valuta_target': valutaTarget,
      'tasso_cambio': tassoCambio,
      'giroconto': giroconto,
    };
  }
}
