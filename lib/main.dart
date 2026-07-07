import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/supabase_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/events/event_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Supabase con le tue credenziali
  await Supabase.initialize(
    url: 'https://cgvpvftfpoxqymqbehzw.supabase.co',
    anonKey: 'sb_publishable_I6XKfOiKxrvyE8XEmMr-jg_Ok948G06',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color azzurroIntenso = Color(0xFF00B2FF);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MC Spese di Gruppo',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: azzurroIntenso,
        colorScheme: ColorScheme.fromSeed(
          seedColor: azzurroIntenso,
          primary: azzurroIntenso,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: azzurroIntenso,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: azzurroIntenso,
              width: 2,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: azzurroIntenso,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper per gestire l'autenticazione
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);

    return session.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Errore: $error')),
      ),
      data: (session) {
        // Se esiste sessione, mostra EventListScreen
        if (session != null) {
          return const EventListScreen();
        }
        // Altrimenti mostra LoginScreen
        return const LoginScreen();
      },
    );
  }
}
