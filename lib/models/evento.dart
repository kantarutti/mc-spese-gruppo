class Evento {
  final String id;
  final String gruppoId;
  final String nome;
  final String? descrizione;
  final String tipo; // viaggio, cena, vacanza, altro
  final String stato; // creazione, in corso, concluso, archiviato
  final DateTime dataInizio;
  final DateTime? dataFine;
  final String? localitaId;
  final String valuta;
  final DateTime createdAt;
  final DateTime updatedAt;

  Evento({
    required this.id,
    required this.gruppoId,
    required this.nome,
    this.descrizione,
    required this.tipo,
    required this.stato,
    required this.dataInizio,
    this.dataFine,
    this.localitaId,
    required this.valuta,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converte da JSON
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] as String,
      gruppoId: json['gruppo_id'] as String,
      nome: json['nome'] as String,
      descrizione: json['descrizione'] as String?,
      tipo: json['tipo'] as String,
      stato: json['stato'] as String,
      dataInizio: DateTime.parse(json['data_inizio'] as String),
      dataFine: json['data_fine'] != null
          ? DateTime.parse(json['data_fine'] as String)
          : null,
      localitaId: json['localita_id'] as String?,
      valuta: json['valuta'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gruppo_id': gruppoId,
      'nome': nome,
      'descrizione': descrizione,
      'tipo': tipo,
      'stato': stato,
      'data_inizio': dataInizio.toIso8601String(),
      'data_fine': dataFine?.toIso8601String(),
      'localita_id': localitaId,
      'valuta': valuta,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copia con modifiche
  Evento copyWith({
    String? id,
    String? gruppoId,
    String? nome,
    String? descrizione,
    String? tipo,
    String? stato,
    DateTime? dataInizio,
    DateTime? dataFine,
    String? localitaId,
    String? valuta,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Evento(
      id: id ?? this.id,
      gruppoId: gruppoId ?? this.gruppoId,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      tipo: tipo ?? this.tipo,
      stato: stato ?? this.stato,
      dataInizio: dataInizio ?? this.dataInizio,
      dataFine: dataFine ?? this.dataFine,
      localitaId: localitaId ?? this.localitaId,
      valuta: valuta ?? this.valuta,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Evento(id: $id, nome: $nome, tipo: $tipo, stato: $stato)';
  }
}