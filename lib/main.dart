import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/user/welcome_page.dart';
import 'pages/user/login_page.dart';
import 'pages/user/signup_page.dart';
import 'pages/user/verify_otp_page.dart';
import 'pages/user/profile_setup_page.dart';
import 'pages/home_page.dart';
import 'services/auth_service.dart';
import 'config/app_theme.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cgvpvftfpoxqymqbehzw.supabase.co',
    anonKey: 'sb_publishable_I6XKfOiKxrvyE8XEmMr-jg_Ok948G06',
  );

  // Recupero sessione utente se già loggato
  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    await AuthService.refreshCurrentUser(session.user.id);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Session? session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      title: 'MC Spese di Gruppo',
      theme: AppTheme.light,

      // ⭐ Logica corretta: se loggato → HomePage, altrimenti LoginPage
//      home: session == null ? const LoginPage() : const HomePage(),
        home: const WelcomePage(),


routes: {
  '/login': (context) => const LoginPage(),
  '/signup': (context) => const SignupPage(),
  '/verify-otp': (context) => const VerifyOtpPage(),
//  '/profileSetupPage': (context) => const ProfileSetupPage(),
//  '/profilePage': (context) => const ProfilePage(),
  '/home': (context) => const HomePage(),
},

    );
  }
}
