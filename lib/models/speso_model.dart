class SpesaModel {
  final String id;
  final String? gruppoId;
  final String? tipologia;
  final double? importo;
  final String? valutaOrigine;
  final String? causale;
  final DateTime? data;
  final String? valutaTarget;
  final double? tassoCambio;
  final double? spesa;
  final String? localita;
  final String? eventoId;

  SpesaModel({
    required this.id,
    this.gruppoId,
    this.tipologia,
    this.importo,
    this.valutaOrigine,
    this.causale,
    this.data,
    this.valutaTarget,
    this.tassoCambio,
    this.spesa,
    this.localita,
    this.eventoId,
  });

  factory SpesaModel.fromMap(Map<String, dynamic> map) {
    return SpesaModel(
      id: map['id'] ?? '',
      gruppoId: map['gruppo_id'],
      tipologia: map['tipologia'],
      importo: map['importo'] != null ? double.tryParse(map['importo'].toString()) : null,
      valutaOrigine: map['valuta_origine'],
      causale: map['causale'],
      data: map['data'] != null ? DateTime.tryParse(map['data'].toString()) : null,
      valutaTarget: map['valuta_target'],
      tassoCambio: map['tasso_cambio'] != null ? double.tryParse(map['tasso_cambio'].toString()) : null,
      spesa: map['spesa'] != null ? double.tryParse(map['spesa'].toString()) : null,
      localita: map['localita'],
      eventoId: map['evento_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gruppo_id': gruppoId,
      'tipologia': tipologia,
      'importo': importo,
      'valuta_origine': valutaOrigine,
      'causale': causale,
      'data': data?.toIso8601String(),
      'valuta_target': valutaTarget,
      'tasso_cambio': tassoCambio,
      'spesa': spesa,
      'localita': localita,
      'evento_id': eventoId,
    };
  }
}