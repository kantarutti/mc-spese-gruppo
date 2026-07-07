import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_page.dart';
import 'screens/profile_setup_page.dart';
import 'screens/event_list_page.dart';
import 'services/auth_service.dart'; // Assicurati che il percorso sia corretto

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cgvpvftfpoxqymqbehzw.supabase.co',
    anonKey: 'sb_publishable_I6XKfOiKxrvyE8XEmMr-jg_Ok948G06',
  );

  // RECUPERO DATI UTENTE SE GIÀ LOGGATO (DOPO REBOOT)
  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    await AuthService.refreshCurrentUser(session.user.id);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color azzurroIntenso = Color(0xFF00B2FF);

  @override
  Widget build(BuildContext context) {
    final Session? session = Supabase.instance.client.auth.currentSession;

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
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            borderSide: const BorderSide(color: azzurroIntenso, width: 2),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: azzurroIntenso,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
      home: session == null ? const LoginPage() : const EventListPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/profile-setup': (context) => const ProfileSetupPage(),
        '/home': (context) => const EventListPage(),
      },
    );
  }
}