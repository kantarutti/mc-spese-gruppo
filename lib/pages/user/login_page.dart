import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart'; // ⭐ NECESSARIO PER context.setLocale

import 'package:mc_spese_gruppo/pages/user/profile_setup_page.dart';
import 'package:mc_spese_gruppo/config/app_widgets.dart';
import 'package:mc_spese_gruppo/config/app_colors.dart';
import 'package:mc_spese_gruppo/config/app_spacing.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _cellController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCellulare();
    _loadSavedNome();
  }

  /// ⭐ Carica il cellulare salvato su disco e lo mette nel campo
  Future<void> _loadSavedCellulare() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCell = prefs.getString('cellulare');

    if (savedCell != null) {
      _cellController.text = savedCell;
    }
  }

  Future<void> _loadSavedNome() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNome = prefs.getString('utente_nome');
    // Eventuale logica con savedNome se necessaria
  }

  Future<void> _handleLogin() async {
    final rawCell = _cellController.text.trim();
    final pin = _pinController.text.trim();

    if (rawCell.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci cellulare e PIN")),
      );
      return;
    }

    // Normalizzazione cellulare
    final cell = rawCell.replaceAll(RegExp(r'\s+'), '');

    // Deve iniziare con +
    if (!cell.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Il numero deve iniziare con +")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ CERCA UTENTE NEL DATABASE
      final data = await Supabase.instance.client
          .from('utenti')
          .select()
          .eq('cellulare', cell)
          .eq('PIN', pin)
          .maybeSingle();

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Utente non trovato. Verifica cellulare e PIN.")),
        );
        return;
      }

      // ⭐ 2️⃣ SOLO ORA SALVIAMO CELLULARE + UTENTE_ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cellulare', cell);
      await prefs.setString('utente_id', data['id'].toString());
      await prefs.setString('utente_nome', data['nome']);

// 🌐 AGGIUNTA GESTIONE LINGUA DA SUPABASE
      final String? linguaUtente = data['lingua'];
      if (linguaUtente != null && linguaUtente.isNotEmpty) {
        await context.setLocale(Locale(linguaUtente));
        await prefs.setString('lingua', linguaUtente);
      }


      // 2️⃣ SE NON È REGISTRATO → APRI SETUP
      if (data['primo_accesso'] == false || data['email'] == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileSetupPage(cellulare: cell),
          ),
        );
        return;
      }

      // 3️⃣ SE È REGISTRATO → LOGIN AUTH
      final email = data['email'];
      final password = data['PIN'];

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // ⭐ 1️⃣ ID Auth generato da Supabase
        final authUserId = response.user!.id;

        // ⭐ 2️⃣ ID utente della tua app (quello che usi ovunque)
        final utentiId = data['id'];

        // ⭐ 4️⃣ Vai alla Home passando utentiId
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: utentiId,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Errore durante il login.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppWidgets.appBar(
        leftWidget: const SizedBox(width: 40),
        titleWidget: const Text("MC Spese di Gruppo"),
        rightWidget: const SizedBox(width: 40),
      ),
      bottomNavigationBar: AppWidgets.actionBar(actions: []),
      body: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ⭐ ICONA APP
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.1),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/Icon-SDG-512.webp',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ⭐ CELLULARE
              TextField(
                controller: _cellController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Cellulare (+ prefisso internazionale numero)",
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ⭐ PIN
              TextField(
                controller: _pinController,
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "PIN",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePin ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () {
                      setState(() => _obscurePin = !_obscurePin);
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ⭐ LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Accedi"),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ⭐ REGISTRATI BUTTON (Disabilitato per Beta Test)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Applicazione in Beta Test. Registrazione non disponibile."),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  child: const Text("Registrati"),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}