class ValutaModel {
  final int id;
  final String valuta;
  final String eventoId;
  final double? tassoCambio;
  final DateTime? dataCambio;

  ValutaModel({
    required this.id,
    required this.valuta,
    required this.eventoId,
    this.tassoCambio,
    this.dataCambio,
  });

  factory ValutaModel.fromJson(Map<String, dynamic> json) {
    return ValutaModel(
      id: json['id'] as int,
      valuta: json['valuta'] as String,
      eventoId: json['evento_id'] as String,
      tassoCambio: json['tasso_cambio'] != null 
          ? double.tryParse(json['tasso_cambio'].toString()) 
          : null,
      dataCambio: json['data_cambio'] != null 
          ? DateTime.parse(json['data_cambio'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'valuta': valuta,
      'evento_id': eventoId,
      'tasso_cambio': tassoCambio,
      'data_cambio': dataCambio?.toIso8601String().split('T')[0],
    };
  }
}