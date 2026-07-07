/// Classe base per tutte le eccezioni dell'app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Eccezione per errori di autenticazione
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  factory AuthException.fromException(dynamic e) {
    if (e is AuthException) return e;
    return AuthException(
      message: 'Errore di autenticazione: ${e.toString()}',
      code: 'AUTH_ERROR',
      originalException: e,
    );
  }
}

/// Eccezione per errori di rete
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  factory NetworkException.fromException(dynamic e) {
    if (e is NetworkException) return e;
    return NetworkException(
      message: 'Errore di connessione: ${e.toString()}',
      code: 'NETWORK_ERROR',
      originalException: e,
    );
  }
}

/// Eccezione per errori nel database
class DatabaseException extends AppException {
  DatabaseException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  factory DatabaseException.fromException(dynamic e) {
    if (e is DatabaseException) return e;
    return DatabaseException(
      message: 'Errore nel database: ${e.toString()}',
      code: 'DATABASE_ERROR',
      originalException: e,
    );
  }
}

/// Eccezione per errori di validazione
class ValidationException extends AppException {
  final List<String> errors;

  ValidationException({
    required String message,
    this.errors = const [],
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  factory ValidationException.fromException(dynamic e) {
    if (e is ValidationException) return e;
    return ValidationException(
      message: 'Errore di validazione: ${e.toString()}',
      code: 'VALIDATION_ERROR',
      originalException: e,
    );
  }
}

/// Eccezione per errori di API
class ApiException extends AppException {
  final int? statusCode;

  ApiException({
    required String message,
    this.statusCode,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  factory ApiException.fromException(dynamic e, {int? statusCode}) {
    if (e is ApiException) return e;
    return ApiException(
      message: 'Errore API: ${e.toString()}',
      statusCode: statusCode,
      code: 'API_ERROR',
      originalException: e,
    );
  }
}

/// Eccezione per errori generici
class GeneralException extends AppException {
  GeneralException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
    message: message,
    code: code ?? 'GENERAL_ERROR',
    originalException: originalException,
  );

  factory GeneralException.fromException(dynamic e) {
    if (e is GeneralException) return e;
    return GeneralException(
      message: e.toString(),
      code: 'GENERAL_ERROR',
      originalException: e,
    );
  }
}

/// Classe helper per gestire le eccezioni
class ExceptionHandler {
  /// Converte un'eccezione generica in AppException
  static AppException handle(dynamic exception) {
    if (exception is AppException) {
      return exception;
    }

    final message = exception.toString();

    if (message.contains('auth') || message.contains('Auth')) {
      return AuthException.fromException(exception);
    } else if (message.contains('network') ||
        message.contains('Network') ||
        message.contains('SocketException')) {
      return NetworkException.fromException(exception);
    } else if (message.contains('database') ||
        message.contains('Database') ||
        message.contains('postgres')) {
      return DatabaseException.fromException(exception);
    } else if (message.contains('validation') ||
        message.contains('Validation')) {
      return ValidationException.fromException(exception);
    } else if (message.contains('http') || message.contains('HTTP')) {
      return ApiException.fromException(exception);
    }

    return GeneralException.fromException(exception);
  }

  /// Ritorna un messaggio utente amichevole
  static String getUserMessage(AppException exception) {
    if (exception is AuthException) {
      return 'Errore di autenticazione. Verifica le tue credenziali.';
    } else if (exception is NetworkException) {
      return 'Errore di connessione. Verifica la tua connessione internet.';
    } else if (exception is DatabaseException) {
      return 'Errore nel salvataggio dei dati. Riprova più tardi.';
    } else if (exception is ValidationException) {
      return 'Dati non validi. ${exception.errors.join(', ')}';
    } else if (exception is ApiException) {
      if (exception.statusCode == 404) {
        return 'Risorsa non trovata.';
      } else if (exception.statusCode == 500) {
        return 'Errore del server. Riprova più tardi.';
      }
      return 'Errore nella comunicazione con il server.';
    }

    return exception.message;
  }
}