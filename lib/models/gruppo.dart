class Gruppo {
  final String id;
  final String eventoId;
  final String nome;
  final int numeroPersone;
  final double uscite;
  final double giroconti;
  final double saldo;
  final double costoGruppo;
  final double conguaglio;
  final String valutaTarget;

  Gruppo({
    required this.id,
    required this.eventoId,
    required this.nome,
    required this.numeroPersone,
    this.uscite = 0.0,
    this.giroconti = 0.0,
    this.saldo = 0.0,
    this.costoGruppo = 0.0,
    this.conguaglio = 0.0,
    this.valutaTarget = 'EUR',
  });

  factory Gruppo.fromMap(Map<String, dynamic> map) {
    return Gruppo(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      nome: map['gruppo'] ?? '',
      numeroPersone: map['numero_persone'] ?? 0,
      uscite: (map['uscite'] ?? 0.0).toDouble(),
      giroconti: (map['giroconti'] ?? 0.0).toDouble(),
      saldo: (map['saldo'] ?? 0.0).toDouble(),
      costoGruppo: (map['costo_gruppo'] ?? 0.0).toDouble(),
      conguaglio: (map['conguaglio'] ?? 0.0).toDouble(),
      valutaTarget: map['valuta_target'] ?? 'EUR',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'gruppo': nome,
      'numero_persone': numeroPersone,
      'uscite': uscite,
      'giroconti': giroconti,
      'saldo': saldo,
      'costo_gruppo': costoGruppo,
      'conguaglio': conguaglio,
      'valuta_target': valutaTarget,
    };
  }
}
