import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isSaving = false;

  // Controller per i dati profilo
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cellulareController = TextEditingController();
  final TextEditingController _nazioneController = TextEditingController();
  final TextEditingController _localitaController = TextEditingController();
  final TextEditingController _valutaController = TextEditingController();

  // Variabile di stato per la lingua (memorizza il codice breve: 'it', 'en', 'es', 'fr')
  String? _linguaSelezionata = 'it';

  // Controller per il cambio codice
  final TextEditingController _nuovoCodiceController = TextEditingController();
  final TextEditingController _confermaCodiceController =
      TextEditingController();

  bool _obscureNuovo = true;
  bool _obscureConferma = true;

  @override
  void initState() {
    super.initState();
    _caricaDatiProfilo();
  }

  Future<void> _caricaDatiProfilo() async {
    final prefs = await SharedPreferences.getInstance();
    final utenteId = prefs.getString('utente_id'); // UUID

    if (utenteId == null) {
      debugPrint("Nessun utente_id salvato nelle SharedPreferences");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await _supabase
          .from('utenti')
          .select()
          .eq('id', utenteId) // UUID → nessun parse
          .maybeSingle();

      if (data != null) {
        setState(() {
          _nomeController.text = data['nome'] ?? '';
          _emailController.text = data['email'] ?? '';
          _cellulareController.text = data['cellulare'] ?? '';
          _nazioneController.text = data['nazione'] ?? '';
          _localitaController.text = data['localita'] ?? '';
          _valutaController.text = data['valuta_base'] ?? '';

          // Imposta la lingua salvata (fallback a 'it' se vuota o non valida)
          final dbLingua = data['lingua'];
          if (dbLingua != null && ['it', 'en', 'es', 'fr'].contains(dbLingua)) {
            _linguaSelezionata = dbLingua;
          } else {
            _linguaSelezionata = 'it';
          }
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento dati: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _salvaModifiche() async {
    final prefs = await SharedPreferences.getInstance();
    final utenteId = prefs.getString('utente_id'); // UUID

    if (utenteId == null) {
      debugPrint("utente_id non trovato, impossibile salvare");
      return;
    }

    // Validazione PIN
    if (_nuovoCodiceController.text.isNotEmpty) {
      if (_nuovoCodiceController.text != _confermaCodiceController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('pin_non_coincidenti'.tr())),
        );
        return;
      }
      if (_nuovoCodiceController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('pin_lunghezza_minima'.tr())),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> updates = {
        'nome': _nomeController.text.trim(),
        'nazione': _nazioneController.text.trim(),
        'localita': _localitaController.text.trim(),
        'valuta_base': _valutaController.text.trim().toUpperCase(),
        'lingua': _linguaSelezionata ?? 'it',
        'email': _emailController.text.trim(),
      };

      if (_nuovoCodiceController.text.isNotEmpty) {
        updates['PIN'] = _nuovoCodiceController.text.trim();
      }

      // ⭐ AGGIORNA LA TABELLA UTENTI USANDO id (UUID)
      await _supabase.from('utenti').update(updates).eq('id', utenteId);

      // ⭐ Aggiorna AUTH solo se cambia il nome
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final oldName = user.userMetadata?['display_name'] ?? "";
        final newName = _nomeController.text.trim();

        if (newName != oldName) {
          await _supabase.auth.updateUser(
            UserAttributes(
              data: {
                'display_name': newName,
              },
            ),
          );
        }
      }

      // ⭐ SALVA LA LINGUA NELLA VARIABILE PERSISTENTE (SharedPreferences)
      if (_linguaSelezionata != null) {
        await prefs.setString('lingua', _linguaSelezionata!);
        // Applica la lingua scelta all'istante
        await context.setLocale(Locale(_linguaSelezionata!));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('profilo_aggiornato'.tr())),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${'errore_durante_salvataggio'.tr()}: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppWidgets.appBar(
        titleWidget: Text('il_mio_profilo'.tr()),
        leftWidget: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        rightWidget: const SizedBox(width: 40),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_cellulareController, 'cellulare'.tr(), Icons.phone,
                enabled: false),
            _buildTextField(_emailController, 'email'.tr(), Icons.email,
                enabled: false),
            _buildTextField(
                _nomeController, 'nome_completo'.tr(), Icons.person),
            const Divider(height: 40),
            _buildTextField(_nazioneController, 'nazione'.tr(), Icons.public),
            _buildTextField(
                _localitaController, 'localita'.tr(), Icons.location_city),

// ⭐ WIDGET DROPDOWN PER LA LINGUA
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: AppWidgets.dropdownField(
                label: 'lingua'.tr(),
                icon: Icons.language,
                value: _linguaSelezionata,
                options: const ['it', 'en', 'es', 'fr'],
                displayTransformer: (code) {
                  switch (code) {
                    case 'it':
                      return 'Italiano';
                    case 'en':
                      return 'English';
                    case 'es':
                      return 'Español';
                    case 'fr':
                      return 'Français';
                    default:
                      return code;
                  }
                },
                onChanged: (valore) async {
                  if (valore != null) {
                    setState(() {
                      _linguaSelezionata = valore;
                    });

                    // ⭐ APPLICA LA LINGUA ALL'ISTANTE SULLA PAGINA CORRENTE
                    await context.setLocale(Locale(valore));
                  }
                },
              ),
            ),

            _buildTextField(_valutaController, 'valuta'.tr(), Icons.euro),
            const Divider(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('cambia_pin_opzionale'.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                _buildPasswordField(
                  _nuovoCodiceController,
                  'nuovo_pin'.tr(),
                  _obscureNuovo,
                  () => setState(() => _obscureNuovo = !_obscureNuovo),
                ),
                _buildPasswordField(
                  _confermaCodiceController,
                  'conferma_pin'.tr(),
                  _obscureConferma,
                  () => setState(() => _obscureConferma = !_obscureConferma),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: AppWidgets.actionBar(
        actions: [
          AppWidgets.actionButton(
            icon: Icons.close,
            label: 'annulla'.tr(),
            onTap: () => Navigator.pop(context),
          ),
          AppWidgets.actionButton(
            icon: Icons.save,
            label: 'salva'.tr(),
            onTap: _salvaModifiche,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscure, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility : Icons.visibility_off,
                size: 20),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }
}
