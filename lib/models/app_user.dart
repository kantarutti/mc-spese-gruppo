class AppUser {
  final String id;
  final String nome;
  final String cellulare;
  final String ruolo;
  final String? email;
  final String codicePersonale;
  final String titolareId;
  final bool primoAccesso;
  final String? nazione;
  final String? localita;
  final String? valutaBase;
  final String? gruppo;
  final DateTime? dataScadenza;

  AppUser({
    required this.id,
    required this.nome,
    required this.cellulare,
    required this.ruolo,
    this.email,
    required this.codicePersonale,
    required this.titolareId,
    required this.primoAccesso,
    this.nazione,
    this.localita,
    this.valutaBase,
    this.gruppo,
    this.dataScadenza,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      cellulare: map['cellulare'] ?? '',
      ruolo: map['ruolo'] ?? 'Ospite',
      email: map['email'],
      codicePersonale: map['codice_personale'] ?? '',
      titolareId: map['titolare_id'] ?? '',
      primoAccesso: map['primo_accesso'] ?? true,
      nazione: map['nazione'],
      localita: map['localita'],
      valutaBase: map['valuta_base'],
      gruppo: map['gruppo'],
      dataScadenza: map['data_scadenza'] != null
          ? DateTime.parse(map['data_scadenza'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cellulare': cellulare,
      'ruolo': ruolo,
      'email': email,
      'codice_personale': codicePersonale,
      'titolare_id': titolareId,
      'primo_accesso': primoAccesso,
      'nazione': nazione,
      'localita': localita,
      'valuta_base': valutaBase,
      'gruppo': gruppo,
      'data_scadenza': dataScadenza?.toIso8601String(),
    };
  }
}
