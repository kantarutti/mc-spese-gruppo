class GirocontoModel {
  final String id;
  final String? daGruppoId;
  final String? aGruppoId;
  final double importo;
  final DateTime? dataGiroconto;
  final String? valutaOrigine;
  final String? valutaTarget;
  final double? tassoCambio;
  final double? giroconto;
  final String? eventoId;

  GirocontoModel({
    required this.id,
    this.daGruppoId,
    this.aGruppoId,
    required this.importo,
    this.dataGiroconto,
    this.valutaOrigine,
    this.valutaTarget,
    this.tassoCambio,
    this.giroconto,
    this.eventoId,
  });

  factory GirocontoModel.fromMap(Map<String, dynamic> map) {
    return GirocontoModel(
      id: map['id'] ?? '',
      daGruppoId: map['da_gruppo_id'],
      aGruppoId: map['a_gruppo_id'],
      importo: map['importo'] != null ? double.tryParse(map['importo'].toString()) ?? 0.0 : 0.0,
      dataGiroconto: map['data_giroconto'] != null ? DateTime.tryParse(map['data_giroconto'].toString()) : null,
      valutaOrigine: map['valuta_origine'],
      valutaTarget: map['valuta_target'],
      tassoCambio: map['tasso_cambio'] != null ? double.tryParse(map['tasso_cambio'].toString()) : null,
      giroconto: map['giroconto'] != null ? double.tryParse(map['giroconto'].toString()) : null,
      eventoId: map['evento_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'da_gruppo_id': daGruppoId,
      'a_gruppo_id': aGruppoId,
      'importo': importo,
      'data_giroconto': dataGiroconto?.toIso8601String(),
      'valuta_origine': valutaOrigine,
      'valuta_target': valutaTarget,
      'tasso_cambio': tassoCambio,
      'giroconto': giroconto,
      'evento_id': eventoId,
    };
  }
}