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

  String get label {
    switch (this) {
      case EventState.preparazione:
        return 'Preparazione';
      case EventState.inCorso:
        return 'In Corso';
      case EventState.concluso:
        return 'Concluso';
      case EventState.chiuso:
        return 'Chiuso';
    }
  }
}
