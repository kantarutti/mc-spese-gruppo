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
  final String? valuta_base; 
  final String? gruppo; // AGGIUNTO: Nuovo campo allineato al DB
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
    this.valuta_base,
    this.gruppo, // AGGIUNTO
    this.dataScadenza,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      nome: map['nome'] ?? '',
      cellulare: map['cellulare'] ?? '',
      ruolo: map['ruolo'] ?? 'Ospite',
      email: map['email'],
      codicePersonale: map['codice_personale'] ?? '',
      titolareId: map['titolare_id'] ?? '',
      primoAccesso: map['primo_accesso'] ?? true,
      nazione: map['nazione'],
      localita: map['localita'],
      valuta_base: map['valuta_base'],
      gruppo: map['gruppo'], // AGGIUNTO: legge il campo 'gruppo' dal database
      dataScadenza: map['data_scadenza'] != null ? DateTime.parse(map['data_scadenza']) : null,
    );
  }
}