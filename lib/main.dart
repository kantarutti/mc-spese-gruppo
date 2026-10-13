import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
  await EasyLocalization.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cgvpvftfpoxqymqbehzw.supabase.co',
    anonKey: 'sb_publishable_I6XKfOiKxrvyE8XEmMr-jg_Ok948G06',
  );

  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    await AuthService.refreshCurrentUser(session.user.id);
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('it'), // Solo codice lingua
        Locale('en'),
        Locale('es'),
        Locale('fr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('it'),
      useOnlyLangCode: true, // ⭐ QUESTO DICE A EASY_LOCALIZATION DI USARE SOLO it.json, en.json, ECC.
      child: const MyApp(),
    ),
  );
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

      // 🌐 Parametri obbligatori per la gestione delle lingue
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      home: const WelcomePage(),

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/verify-otp': (context) => const VerifyOtpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}