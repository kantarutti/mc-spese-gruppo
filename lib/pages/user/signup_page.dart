import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mc_spese_gruppo/config/app_widgets.dart';
import 'package:mc_spese_gruppo/config/app_colors.dart';
import 'package:mc_spese_gruppo/formatters/formatters.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _cellController = TextEditingController();

  bool isLoading = false;

  // 🛠️ Attiva/disattiva la modalità mock per saltare le chiamate SMS di Twilio in sviluppo
  static const bool isTestMode = true;

  Future<void> _handleSignup() async {
    // 1. Validazione del cellulare tramite PhoneValidator
    final cell = PhoneValidator.validateAndNotify(context, _cellController.text);
    if (cell == null) return;

    setState(() => isLoading = true);

    try {
      if (isTestMode) {
        // 🧪 MOCK MODE: Simuliamo l'invio senza contattare Supabase/Twilio
        await Future.delayed(const Duration(milliseconds: 800)); // Simulazione ritardo di rete
      } else {
        // 2. Richiesta invio OTP tramite Supabase (Ambiente Reale)
        await Supabase.instance.client.auth.signInWithOtp(
          phone: cell,
        );
      }

      if (!mounted) return;

      // 3. Notifica successo e passaggio alla pagina di verifica OTP
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Codice SMS inviato con successo!")),
      );

      Navigator.pushNamed(
        context,
        '/verify-otp',
        arguments: cell,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore durante l'invio dell'SMS: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _cellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidgets.appBar(
        leftWidget: null,
        titleWidget: const Text(
          "Registrati",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        rightWidget: null,
      ),
      bottomNavigationBar: AppWidgets.actionBar(actions: []),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
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
                const SizedBox(height: 24),

                // 📱 Campo Cellulare
                TextField(
                  controller: _cellController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    PhoneInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Cellulare con prefisso internazionale",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // 🚀 Bottone Invia Codice SMS
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Invia Codice SMS",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Pulsante per tornare al login
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text("Hai già un account? Accedi"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}