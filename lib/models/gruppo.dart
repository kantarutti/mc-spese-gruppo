/// Modello per un Gruppo
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
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea un Gruppo da una mappa (da Supabase)
  factory Gruppo.fromMap(Map<String, dynamic> map) {
    return Gruppo(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      nome: map['gruppo'] ?? '',
      numeroPersone: map['numero_persone'] ?? 0,
      uscite: (map['uscite'] ?? 0).toDouble(),
      giroconti: (map['giroconti'] ?? 0).toDouble(),
      saldo: (map['saldo'] ?? 0).toDouble(),
      costoGruppo: (map['costo_gruppo'] ?? 0).toDouble(),
      conguaglio: (map['conguaglio'] ?? 0).toDouble(),
      valutaTarget: map['valuta_target'] ?? 'EUR',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  /// Converte il Gruppo in una mappa (per Supabase)
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia del Gruppo con valori modificati
  Gruppo copyWith({
    String? id,
    String? eventoId,
    String? nome,
    int? numeroPersone,
    double? uscite,
    double? giroconti,
    double? saldo,
    double? costoGruppo,
    double? conguaglio,
    String? valutaTarget,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Gruppo(
      id: id ?? this.id,
      eventoId: eventoId ?? this.eventoId,
      nome: nome ?? this.nome,
      numeroPersone: numeroPersone ?? this.numeroPersone,
      uscite: uscite ?? this.uscite,
      giroconti: giroconti ?? this.giroconti,
      saldo: saldo ?? this.saldo,
      costoGruppo: costoGruppo ?? this.costoGruppo,
      conguaglio: conguaglio ?? this.conguaglio,
      valutaTarget: valutaTarget ?? this.valutaTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calcola la spesa per persona
  double get costoPerPersona {
    if (numeroPersone == 0) return 0.0;
    return costoGruppo / numeroPersone;
  }

  /// Verifica se il gruppo ha un conguaglio positivo (avere)
  bool get haPositiveSettlement => conguaglio >= 0;

  /// Verifica se il gruppo ha un conguaglio negativo (dare)
  bool get hasNegativeSettlement => conguaglio < 0;

  /// Ritorna il conguaglio come valore assoluto
  double get settlementAbsValue => conguaglio.abs();

  /// Ritorna una descrizione dello stato del conguaglio
  String get settlementDescription {
    if (conguaglio > 0) {
      return 'Avere ${conguaglio.toStringAsFixed(2)} $valutaTarget';
    } else if (conguaglio < 0) {
      return 'Dare ${conguaglio.abs().toStringAsFixed(2)} $valutaTarget';
    } else {
      return 'In pari';
    }
  }

  /// Verifica se il gruppo è in pari
  bool get isSettled => conguaglio == 0;

  @override
  String toString() =>
      'Gruppo(id: $id, nome: $nome, persone: $numeroPersone)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gruppo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          eventoId == other.eventoId;

  @override
  int get hashCode => id.hashCode ^ eventoId.hashCode;
}