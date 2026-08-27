import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;

class WelcomePagePlatform extends StatefulWidget {
  const WelcomePagePlatform({super.key});

  @override
  State<WelcomePagePlatform> createState() => _WelcomePagePlatformState();
}

class _WelcomePagePlatformState extends State<WelcomePagePlatform> {
  html.BeforeInstallPromptEvent? _installEvent;
  bool _isInstalled = false;

  late bool isAndroid;
  late bool isIOS;

  bool _installationCompleted = false;

  @override
  void initState() {
    super.initState();

// -------------------------------------------------------
bool isStandalone = false;

// Controllo sicuro per PWA
try {
  final media = html.window.matchMedia('(display-mode: standalone)');
  if (media != null && media.matches == true) {
    isStandalone = true;
  }
} catch (_) {
  isStandalone = false;
}

_isInstalled = isStandalone;

if (_isInstalled) {
  Future.microtask(() {
//    Navigator.pushReplacementNamed(context, '/login');
final session = Supabase.instance.client.auth.currentSession;

if (session == null) {
  Navigator.pushReplacementNamed(context, '/login');
} else {
  Navigator.pushReplacementNamed(context, '/home');
}

  });
  return;
}

    // -----------------------------------------------------------

    final ua = html.window.navigator.userAgent.toLowerCase();
    isAndroid = ua.contains("android");
    isIOS = ua.contains("iphone") || ua.contains("ipad");

    html.window.addEventListener('beforeinstallprompt', (event) {
      event.preventDefault();
      _installEvent = event as html.BeforeInstallPromptEvent;
      setState(() {});
    });
  }

  void _installApp() {
    _installEvent?.prompt();
  }

  Widget installButton() {
    if (!isAndroid && !isIOS) {
      if (_installEvent != null) {
        return ElevatedButton(
          onPressed: _installApp,
          child: const Text("Installa l'app"),
        );
      }
      return const Text("Preparazione installazione...",
          style: TextStyle(fontSize: 16, color: Colors.grey));
    }

    if (isAndroid) {
      return ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Come installare l'app"),
              content: const Text(
                "Per installare l'app:\n\n"
                "1. Premi ⋮ in basso a destra\n"
                "2. Seleziona 'Aggiungi pagina a'\n"
                "3. Schermata Home\n"
                "4. Conferma l'installazione",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Indietro"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _installationCompleted = true);
                  },
                  child: const Text("Ho installato l'app"),
                ),
              ],
            ),
          );
        },
        child: const Text("Installa l'app"),
      );
    }

    if (isIOS) {
      return ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Come installare l'app"),
              content: const Text(
                "Su iPhone:\n\n"
                "1. Premi il pulsante Condividi\n"
                "2. Seleziona 'Aggiungi a Home'\n"
                "3. Conferma",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Indietro"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _installationCompleted = true);
                  },
                  child: const Text("Ho installato l'app"),
                ),
              ],
            ),
          );
        },
        child: const Text("Installa l'app"),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInstalled) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/Icon-SDG-512.webp',
                  width: 120, height: 120),
              const SizedBox(height: 20),
              const Text(
                "Benvenuto in\nMC Spese di Gruppo!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "Installa l'app per un'esperienza più veloce e comoda.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              if (!_installationCompleted) ...[
                installButton(),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text("Continua senza installare",
                      style: TextStyle(fontSize: 16)),
                ),
              ] else ...[
                const Text(
                  "Ora chiudi la scheda del browser e apri l'app dal cellulare.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
