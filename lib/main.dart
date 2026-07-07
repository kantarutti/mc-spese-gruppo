import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/config.dart';
import 'utils/utils.dart';
import 'models/models.dart';
import 'services/services.dart';
import 'exceptions/exceptions.dart';

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
      home: const HomeScreen(),
    );
  }
}

// Screen temporanea per testare
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MC Spese Gruppo'),
      ),
      body: const Center(
        child: Text('App inizializzata correttamente! 🎉'),
      ),
    );
  }
}