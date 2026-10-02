class GruppoModel {
  final String id;
  final String? eventoId;
  final String gruppo;
  final int numeroPersone;
  final double? conguaglio;
  final double? giroconti;
  final double? uscite;
  final double? costoGruppo;
  final double? saldo;
  final bool protected;

  GruppoModel({
    required this.id,
    this.eventoId,
    required this.gruppo,
    required this.numeroPersone,
    this.conguaglio,
    this.giroconti,
    this.uscite,
    this.costoGruppo,
    this.saldo,
    required this.protected,
  });

  // Converte una riga JSON/Map proveniente da Supabase in un oggetto GruppoModel
  factory GruppoModel.fromMap(Map<String, dynamic> map) {
    return GruppoModel(
      id: map['id'] ?? '',
      eventoId: map['evento_id'],
      gruppo: map['gruppo'] ?? '',
      numeroPersone: map['numero_persone'] ?? 1,
      conguaglio: map['conguaglio'] != null ? double.tryParse(map['conguaglio'].toString()) : null,
      giroconti: map['giroconti'] != null ? double.tryParse(map['giroconti'].toString()) : null,
      uscite: map['uscite'] != null ? double.tryParse(map['uscite'].toString()) : null,
      costoGruppo: map['costo_gruppo'] != null ? double.tryParse(map['costo_gruppo'].toString()) : null,
      saldo: map['saldo'] != null ? double.tryParse(map['saldo'].toString()) : null,
      protected: map['protected'] ?? false,
    );
  }

  // Converte l'oggetto in una mappa (utile per insert o update su Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'gruppo': gruppo,
      'numero_persone': numeroPersone,
      'conguaglio': conguaglio,
      'giroconti': giroconti,
      'uscite': uscite,
      'costo_gruppo': costoGruppo,
      'saldo': saldo,
      'protected': protected,
    };
  }
}