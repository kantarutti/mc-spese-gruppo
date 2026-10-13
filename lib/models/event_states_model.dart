import 'package:easy_localization/easy_localization.dart';

enum EventState {
  preparazione,
  inCorso,
  concluso,
  chiuso,
}

extension EventStateParser on EventState {
  static EventState fromString(String value) {
    switch (value) {
      case 'Preparazione':
        return EventState.preparazione;
      case 'In Corso':
        return EventState.inCorso;
      case 'Concluso':
        return EventState.concluso;
      case 'Chiuso':
        return EventState.chiuso;
      default:
        return EventState.preparazione;
    }
  }

  // Restituisce la CHIAVE pura per la traduzione
  String get translationKey {
    switch (this) {
      case EventState.preparazione:
        return 'state_preparazione';
      case EventState.inCorso:
        return 'state_in_corso';
      case EventState.concluso:
        return 'state_concluso';
      case EventState.chiuso:
        return 'state_chiuso';
    }
  }
}