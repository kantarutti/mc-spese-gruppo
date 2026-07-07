class Evento {
  final String id;
  final String nome;
  final String tipoEvento;
  final String? organizzatore;
  final String? localita;
  final DateTime? dataInizio;
  final DateTime? dataFine;
  final String? valutaOrigine;
  final String? valutaTarget;
  final String stato;
  final int persone;
  final double totaleSpesa;

  Evento({
    required this.id,
    required this.nome,
    required this.tipoEvento,
    this.organizzatore,
    this.localita,
    this.dataInizio,
    this.dataFine,
    this.valutaOrigine,
    this.valutaTarget,
    this.stato = 'Creazione',
    this.persone = 0,
    this.totaleSpesa = 0.0,
  });

  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      tipoEvento: map['tipo_evento'] ?? 'Viaggio',
      organizzatore: map['organizzatore'],
      localita: map['localita'],
      dataInizio: map['data_inizio'] != null
          ? DateTime.parse(map['data_inizio'])
          : null,
      dataFine: map['data_fine'] != null ? DateTime.parse(map['data_fine']) : null,
      valutaOrigine: map['valuta_origine'],
      valutaTarget: map['valuta_target'],
      stato: map['stato'] ?? 'Creazione',
      persone: map['persone'] ?? 0,
      totaleSpesa: (map['totale_spesa'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo_evento': tipoEvento,
      'organizzatore': organizzatore,
      'localita': localita,
      'data_inizio': dataInizio?.toIso8601String(),
      'data_fine': dataFine?.toIso8601String(),
      'valuta_origine': valutaOrigine,
      'valuta_target': valutaTarget,
      'stato': stato,
      'persone': persone,
      'totale_spesa': totaleSpesa,
    };
  }
}
