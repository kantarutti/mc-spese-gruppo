import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider per l'autenticazione
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Classe che rappresenta lo stato dell'autenticazione
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

/// Notifier per gestire lo stato dell'autenticazione
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  final _supabase = Supabase.instance.client;

  void _init() {
    // Controlla se l'utente è già loggato
    final user = _supabase.auth.currentUser;
    if (user != null) {
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
      );
    }
  }

  /// Login con email e password
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Registrazione con email e password
  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.auth.signOut();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Pulisci l'errore
  void clearError() {
    state = state.copyWith(error: null);
  }
}
