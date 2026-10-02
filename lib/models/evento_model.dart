class EventoModel {
  final String id;
  final String nome;
  final String? tipoEvento;
  final String? localita;
  final DateTime? dataInizio;
  final DateTime? dataFine;
  final String? valutaOrigine;
  final String? valutaTarget;
  final int numeroPersone;
  final double totaleSpesa;
  final double? proCapite;
  final String? stato;
  final String? amministratore;
//  final String? amministratoreCellulare;
  final String? amministratoreId;
  final double tassoCambio;
//  final String? dataTasso;
  final double? fusoOffset;
  final DateTime? inseritoIl;
  final DateTime? ultimaVerificaStato;
  final bool emailSend;

  EventoModel({
    required this.id,
    required this.nome,
    this.stato,
    this.inseritoIl,
    this.dataInizio,
    this.dataFine,
    this.valutaOrigine,
    this.valutaTarget,
    this.amministratore,
    this.localita,
    required this.numeroPersone,
    required this.totaleSpesa,
    required this.tassoCambio,
//    this.amministratoreCellulare,
    this.tipoEvento,
//    this.dataTasso,
    this.fusoOffset,
    this.proCapite,
    this.amministratoreId,
    this.ultimaVerificaStato,
    this.emailSend = false,
  });

  factory EventoModel.fromMap(Map<String, dynamic> map) {
    return EventoModel(
      id: map['id']?.toString() ?? '',
      nome: map['nome'] ?? '',
      stato: map['stato'],
      inseritoIl: map['inserito_il'] != null ? DateTime.tryParse(map['inserito_il'].toString()) : null,
      dataInizio: map['data_inizio'] != null ? DateTime.tryParse(map['data_inizio'].toString()) : null,
      dataFine: map['data_fine'] != null ? DateTime.tryParse(map['data_fine'].toString()) : null,
      valutaOrigine: map['valuta_origine'],
      valutaTarget: map['valuta_target'],
      amministratore: map['amministratore'],
      localita: map['localita'],
      numeroPersone: map['numero_persone'] ?? 0,
      totaleSpesa: map['totale_spesa'] != null ? double.tryParse(map['totale_spesa'].toString()) ?? 0.0 : 0.0,
      tassoCambio: map['tasso_cambio'] != null ? double.tryParse(map['tasso_cambio'].toString()) ?? 1.0 : 1.0,
      tipoEvento: map['tipo_evento'],
      fusoOffset: map['fuso_offset'] != null ? double.tryParse(map['fuso_offset'].toString()) : null,
      proCapite: map['pro_capite'] != null ? double.tryParse(map['pro_capite'].toString()) : null,
      amministratoreId: map['amministratore_id'],
      ultimaVerificaStato: map['ultima_verifica_stato'] != null ? DateTime.tryParse(map['ultima_verifica_stato'].toString()) : null,
      emailSend: map['email_send'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'stato': stato,
      'inserito_il': inseritoIl?.toIso8601String(),
      'data_inizio': dataInizio?.toIso8601String(),
      'data_fine': dataFine?.toIso8601String(),
      'valuta_origine': valutaOrigine,
      'valuta_target': valutaTarget,
      'amministratore': amministratore,
      'localita': localita,
      'numero_persone': numeroPersone,
      'totale_spesa': totaleSpesa,
      'tasso_cambio': tassoCambio,
      'tipo_evento': tipoEvento,
      'fuso_offset': fusoOffset,
      'pro_capite': proCapite,
      'amministratore_id': amministratoreId,
      'ultima_verifica_stato': ultimaVerificaStato?.toIso8601String(),
      'email_send': emailSend,
    };
  }
}