/// Modello per un Giroconto (trasferimento tra gruppi)
class Giroconto {
  final String id;
  final String eventoId;
  final String daGruppoId;
  final String aGruppoId;
  final DateTime dataGiroconto;
  final double importo; // Importo originale inserito
  final String valutaOrigine;
  final double giroconto; // Importo convertito nella valuta target
  final String valutaTarget;
  final double tassoCambio;
  final DateTime createdAt;
  final DateTime updatedAt;

  Giroconto({
    required this.id,
    required this.eventoId,
    required this.daGruppoId,
    required this.aGruppoId,
    required this.dataGiroconto,
    required this.importo,
    required this.valutaOrigine,
    required this.giroconto,
    required this.valutaTarget,
    required this.tassoCambio,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea un Giroconto da una mappa (da Supabase)
  factory Giroconto.fromMap(Map<String, dynamic> map) {
    return Giroconto(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      daGruppoId: map['da_gruppo_id'] ?? '',
      aGruppoId: map['a_gruppo_id'] ?? '',
      dataGiroconto: map['data_giroconto'] != null
          ? DateTime.parse(map['data_giroconto'])
          : DateTime.now(),
      importo: (map['importo'] ?? 0).toDouble(),
      valutaOrigine: map['valuta_origine'] ?? 'EUR',
      giroconto: (map['giroconto'] ?? 0).toDouble(),
      valutaTarget: map['valuta_target'] ?? 'EUR',
      tassoCambio: (map['tasso_cambio'] ?? 1.0).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  /// Converte il Giroconto in una mappa (per Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'da_gruppo_id': daGruppoId,
      'a_gruppo_id': aGruppoId,
      'data_giroconto': dataGiroconto.toIso8601String(),
      'importo': importo,
      'valuta_origine': valutaOrigine,
      'giroconto': giroconto,
      'valuta_target': valutaTarget,
      'tasso_cambio': tassoCambio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia del Giroconto con valori modificati
  Giroconto copyWith({
    String? id,
    String? eventoId,
    String? daGruppoId,
    String? aGruppoId,
    DateTime? dataGiroconto,
    double? importo,
    String? valutaOrigine,
    double? giroconto,
    String? valutaTarget,
    double? tassoCambio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Giroconto(
      id: id ?? this.id,
      eventoId: eventoId ?? this.eventoId,
      daGruppoId: daGruppoId ?? this.daGruppoId,
      aGruppoId: aGruppoId ?? this.aGruppoId,
      dataGiroconto: dataGiroconto ?? this.dataGiroconto,
      importo: importo ?? this.importo,
      valutaOrigine: valutaOrigine ?? this.valutaOrigine,
      giroconto: giroconto ?? this.giroconto,
      valutaTarget: valutaTarget ?? this.valutaTarget,
      tassoCambio: tassoCambio ?? this.tassoCambio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se il giroconto è stato convertito
  bool get isConverted => valutaOrigine != valutaTarget;

  /// Ritorna il tasso di cambio applicato
  String get exchangeRateDisplay {
    return '1.00 $valutaTarget = ${(1 / tassoCambio).toStringAsFixed(4)} $valutaOrigine';
  }

  /// Verifica se il giroconto è recente (ultimi 7 giorni)
  bool get isRecent {
    return DateTime.now().difference(dataGiroconto).inDays <= 7;
  }

  /// Ritorna il giorno della settimana
  String get dayOfWeek {
    const days = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    return days[dataGiroconto.weekday - 1];
  }

  /// Ritorna la data formattata come stringa
  String get dataFormatted {
    return '${dataGiroconto.day}/${dataGiroconto.month}/${dataGiroconto.year}';
  }

  /// Ritorna una descrizione del movimento
  /// Es: "Da: Gruppo A - A: Gruppo B"
  String getMovementDescription(String daGruppoNome, String aGruppoNome) {
    return 'DA: $daGruppoNome → A: $aGruppoNome';
  }

  /// Verifica se è un giroconto tra gli stessi gruppi (anomalia)
  bool get isSelfTransfer => daGruppoId == aGruppoId;

  @override
  String toString() =>
      'Giroconto(id: $id, importo: $giroconto $valutaTarget, data: $dataFormatted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Giroconto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          eventoId == other.eventoId;

  @override
  int get hashCode => id.hashCode ^ eventoId.hashCode;
}