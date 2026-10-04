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

  bool isAndroid = false;
  bool isSamsungInternet = false;
  bool isIOS = false;
  bool _hasDesktopPrompt = false;

  bool _installationCompleted = false;

  @override
  void initState() {
    super.initState();

    // -------------------------------------------------------
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

    _isInstalled = isStandalone;

    if (_isInstalled) {
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

    // -----------------------------------------------------------
    // Rilevamento piattaforma e browser specifico
    final ua = html.window.navigator.userAgent.toLowerCase();
    isSamsungInternet = ua.contains("samsungbrowser");
    isAndroid = ua.contains("android") && !isSamsungInternet;
    isIOS = ua.contains("iphone") || ua.contains("ipad");

    // Gestione PWA desktop / browser compatibili con prompt nativo
    html.window.addEventListener('beforeinstallprompt', (event) {
      event.preventDefault();
      _installEvent = event as html.BeforeInstallPromptEvent;
      setState(() {
        _hasDesktopPrompt = true;
      });
    });
  }

  // -----------------------------------------------------------
  // WIDGET PER LE ISTRUZIONI INLINE BASATE SUL BROWSER
  Widget _buildBrowserInstructions() {
    if (isSamsungInternet) {
      // Samsung Internet usa le stesse istruzioni del desktop richieste
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📱 Istruzioni per Samsung Internet:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A4D8C)),
            ),
            SizedBox(height: 8),
            Text("1. Clicca sull'icona di installazione nella barra dell'indirizzo"),
            Text("2. Conferma l'installazione"),
            SizedBox(height: 6),
            Text("Oppure premi il pulsante che apparirà automaticamente."),
          ],
        ),
      );
    } else if (isAndroid) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📱 Istruzioni per Android (Chrome):",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A4D8C)),
            ),
            SizedBox(height: 8),
            Text("1. Premi il menu (⋮) in alto a destra."),
            Text("2. Seleziona 'Installa app' o 'Aggiungi a Schermata Home'."),
            Text("3. Conferma per completare l'installazione."),
          ],
        ),
      );
    } else if (isIOS) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🍏 Istruzioni per iPhone / iPad (Safari):",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A4D8C)),
            ),
            SizedBox(height: 8),
            Text("1. Tocca il pulsante Condividi (icona quadrato con freccia)."),
            Text("2. Scorri il menu e seleziona 'Aggiungi a Home'."),
            Text("3. Conferma l'aggiunta."),
          ],
        ),
      );
    } else {
      // Desktop o browser generici
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "💻 Istruzioni per PC / Desktop:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A4D8C)),
            ),
            const SizedBox(height: 8),
            const Text("1. Clicca sull'icona di installazione nella barra degli indirizzi in alto."),
            const Text("2. Conferma l'installazione."),
            const SizedBox(height: 6),
            const Text("Oppure premi il pulsante che apparirà automaticamente."),
            if (_hasDesktopPrompt) ...[
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _installEvent?.prompt();
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("Installa ora"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A4D8C),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
  }

  // -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isInstalled) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/Icon-SDG-512.png',
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
                const SizedBox(height: 25),
          
                // Istruzioni mirate in base al browser rilevato
                _buildBrowserInstructions(),
          
                const SizedBox(height: 30),
          
                if (!_installationCompleted) ...[
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
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}