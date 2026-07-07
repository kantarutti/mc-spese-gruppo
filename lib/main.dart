import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/config.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Supabase
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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MC Spese Gruppo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}

/// Wrapper per gestire l'autenticazione
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Se autenticato, mostra MainScreen
    if (authState.isAuthenticated) {
      return const MainScreen();
    }

    // Se non autenticato, mostra LoginScreen
    return const LoginScreen();
  }
}

/// Main screen con bottom navigation
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventiScreen(),
    const GruppiScreen(),
    const SpeseScreen(),
    const ParticipantiScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MC Spese Gruppo'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Profilo'),
                onTap: () {
                  // Mostra profilo
                },
              ),
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                },
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Eventi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Gruppi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Spese',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Partecipanti',
          ),
        ],
      ),
    );
  }
}
