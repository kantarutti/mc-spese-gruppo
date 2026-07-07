import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/supabase_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const Color azzurroIntenso = Color(0xFF00B2FF);

  final _cellulareController = TextEditingController();
  final _codiceController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cellulareController.dispose();
    _codiceController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final cellulare = _cellulareController.text.trim();
      final codice = _codiceController.text.trim();

      if (cellulare.isEmpty || codice.isEmpty) {
        throw 'Inserisci cellulare e codice';
      }

      final params = LoginParams(
        cellulare: cellulare,
        codice: codice,
      );

      // Chiama il provider di login
      final result = await ref.read(loginProvider(params).future);

      if (result != null && mounted) {
        // Login riuscito - AuthWrapper gestisce la navigazione automaticamente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Benvenuto ${result.nome}!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Header
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: azzurroIntenso,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.groups,
                  size: 70,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              // Titolo
              Text(
                'MC Spese di Gruppo',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: azzurroIntenso,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Gestisci le spese in modo semplice',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              // Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_errorMessage != null) const SizedBox(height: 20),
                    // Cellulare
                    TextField(
                      controller: _cellulareController,
                      keyboardType: TextInputType.phone,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone, color: azzurroIntenso),
                        labelText: 'Cellulare',
                        hintText: 'Inserisci il tuo numero',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Codice Personale
                    TextField(
                      controller: _codiceController,
                      obscureText: true,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: azzurroIntenso),
                        labelText: 'Codice Personale',
                        hintText: 'Inserisci il tuo codice',
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'ACCEDI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Info Text
                    Text(
                      'Usa i tuoi dati di accesso\nprovvisti dall\'amministratore',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
