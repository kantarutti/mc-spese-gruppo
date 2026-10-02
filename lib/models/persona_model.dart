class PersonaModel {
  final int id;
  final String eventoId;
  final String cellulare;
  final String? gruppoId;
  final DateTime creatoIl;
  final String? persona;
  final String? userId;
  final bool protected;

  PersonaModel({
    required this.id,
    required this.eventoId,
    required this.cellulare,
    this.gruppoId,
    required this.creatoIl,
    this.persona,
    this.userId,
    required this.protected,
  });

  factory PersonaModel.fromMap(Map<String, dynamic> map) {
    return PersonaModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      eventoId: map['evento_id'] ?? '',
      cellulare: map['cellulare'] ?? '',
      gruppoId: map['gruppo_id'],
      creatoIl: map['creato_il'] != null 
          ? DateTime.tryParse(map['creato_il'].toString()) ?? DateTime.now() 
          : DateTime.now(),
      persona: map['persona'],
      userId: map['user_id'],
      protected: map['protected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'evento_id': eventoId,
      'cellulare': cellulare,
      'gruppo_id': gruppoId,
      'creato_il': creatoIl.toIso8601String(),
      'persona': persona,
      'user_id': userId,
      'protected': protected,
    };
  }
}