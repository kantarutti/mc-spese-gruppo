import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;

class WelcomePagePlatform extends StatefulWidget {
  const WelcomePagePlatform({super.key});

  @override
  State<WelcomePagePlatform> createState() => _WelcomePagePlatformState();
}

class _WelcomePagePlatformState extends State<WelcomePagePlatform> {
  late bool isAndroid;
  late bool isIOS;
  late bool isDesktop;

  @override
  void initState() {
    super.initState();

    // Controllo se l'app è già installata come PWA
    bool isStandalone = false;

    try {
      final media = html.window.matchMedia('(display-mode: standalone)');
      if (media != null && media.matches == true) {
        isStandalone = true;
      }
    } catch (_) {
      isStandalone = false;
    }

    if (isStandalone) {
      Future.microtask(() {
        final session = Supabase.instance.client.auth.currentSession;

        if (session == null) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
      return;
    }

    // Rilevamento piattaforma
    final ua = html.window.navigator.userAgent.toLowerCase();
    isAndroid = ua.contains("android");
    isIOS = ua.contains("iphone") || ua.contains("ipad");
    isDesktop = !isAndroid && !isIOS;
  }

  Widget _buildInstructions() {
    if (isAndroid) {
      return Column(
        children: [
          Image.asset('assets/images/android.png', width: 80),
          const SizedBox(height: 15),
          const Text("Come installare l'app su Android:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• Premi ⋮ in alto o in basso a destra"),
              Text("• Seleziona 'Aggiungi a schermata Home'"),
              Text("• Conferma l'installazione"),
            ],
          ),
        ],
      );
    }

    if (isIOS) {
      return Column(
        children: [
          Image.asset('assets/images/ios.png', width: 80),
          const SizedBox(height: 15),
          const Text("Come installare l'app su iPhone:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• Premi il pulsante Condividi"),
              Text("• Seleziona 'Aggiungi a Home'"),
              Text("• Conferma"),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Image.asset('assets/images/desktop.png', width: 80),
        const SizedBox(height: 15),
        const Text("Come installare l'app su Desktop:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• Clicca sull'icona di installazione nella barra dell'indirizzo"),
            Text("• Conferma l'installazione"),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ICONA APP
                Image.asset('assets/images/Icon-SDG-512.webp',
                    width: 120, height: 120),

                const SizedBox(height: 20),

                // TESTO BENVENUTO
                const Text(
                  "Benvenuto in\nMC Spese di Gruppo!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                // ISTRUZIONI DINAMICHE
                _buildInstructions(),

                const SizedBox(height: 40),

                // CONTINUA SENZA INSTALLARE
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Continua senza installare",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
