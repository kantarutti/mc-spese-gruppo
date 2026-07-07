/// Modello per una Spesa
class Spesa {
  final String id;
  final String eventoId;
  final String gruppoId;
  final DateTime data;
  final String? localita;
  final String? tipologia;
  final String? causale;
  final double spesa; // Importo originale inserito
  final String valutaOrigine;
  final double importo; // Importo convertito nella valuta target
  final String valutaTarget;
  final double tassoCambio;
  final DateTime createdAt;
  final DateTime updatedAt;

  Spesa({
    required this.id,
    required this.eventoId,
    required this.gruppoId,
    required this.data,
    this.localita,
    this.tipologia,
    this.causale,
    required this.spesa,
    required this.valutaOrigine,
    required this.importo,
    required this.valutaTarget,
    required this.tassoCambio,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una Spesa da una mappa (da Supabase)
  factory Spesa.fromMap(Map<String, dynamic> map) {
    return Spesa(
      id: map['id'] ?? '',
      eventoId: map['evento_id'] ?? '',
      gruppoId: map['gruppo_id'] ?? '',
      data: map['data'] != null ? DateTime.parse(map['data']) : DateTime.now(),
      localita: map['localita'],
      tipologia: map['tipologia'],
      causale: map['causale'],
      spesa: (map['spesa'] ?? 0).toDouble(),
      valutaOrigine: map['valuta_origine'] ?? 'EUR',
      importo: (map['importo'] ?? 0).toDouble(),
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

  /// Converte la Spesa in una mappa (per Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'gruppo_id': gruppoId,
      'data': data.toIso8601String(),
      'localita': localita,
      'tipologia': tipologia,
      'causale': causale,
      'spesa': spesa,
      'valuta_origine': valutaOrigine,
      'importo': importo,
      'valuta_target': valutaTarget,
      'tasso_cambio': tassoCambio,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Crea una copia della Spesa con valori modificati
  Spesa copyWith({
    String? id,
    String? eventoId,
    String? gruppoId,
    DateTime? data,
    String? localita,
    String? tipologia,
    String? causale,
    double? spesa,
    String? valutaOrigine,
    double? importo,
    String? valutaTarget,
    double? tassoCambio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Spesa(
      id: id ?? this.id,
      eventoId: eventoId ?? this.eventoId,
      gruppoId: gruppoId ?? this.gruppoId,
      data: data ?? this.data,
      localita: localita ?? this.localita,
      tipologia: tipologia ?? this.tipologia,
      causale: causale ?? this.causale,
      spesa: spesa ?? this.spesa,
      valutaOrigine: valutaOrigine ?? this.valutaOrigine,
      importo: importo ?? this.importo,
      valutaTarget: valutaTarget ?? this.valutaTarget,
      tassoCambio: tassoCambio ?? this.tassoCambio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se la spesa è stata convertita
  bool get isConverted => valutaOrigine != valutaTarget;

  /// Ritorna il tasso di cambio applicato
  String get exchangeRateDisplay {
    return '1.00 $valutaTarget = ${(1 / tassoCambio).toStringAsFixed(4)} $valutaOrigine';
  }

  /// Verifica se la spesa è recente (ultimi 7 giorni)
  bool get isRecent {
    return DateTime.now().difference(data).inDays <= 7;
  }

  /// Ritorna il giorno della settimana
  String get dayOfWeek {
    const days = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    return days[data.weekday - 1];
  }

  /// Ritorna la data formattata come stringa
  String get dataFormatted {
    return '${data.day}/${data.month}/${data.year}';
  }

  @override
  String toString() =>
      'Spesa(id: $id, importo: $importo $valutaTarget, data: $dataFormatted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Spesa &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          eventoId == other.eventoId;

  @override
  int get hashCode => id.hashCode ^ eventoId.hashCode;
}