import 'package:flutter/material.dart';
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
  final TextEditingController _linguaController = TextEditingController();

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
          _linguaController.text = data['lingua'] ?? '';
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
          const SnackBar(content: Text("I nuovi codici non coincidono!")),
        );
        return;
      }
      if (_nuovoCodiceController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Il codice deve essere di almeno 6 caratteri")),
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
        'lingua': _linguaController.text.trim(),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profilo aggiornato con successo!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore durante il salvataggio: $e")),
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
        titleWidget: const Text("Il Mio Profilo"),
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
            _buildTextField(_cellulareController, "Cellulare", Icons.phone,
                enabled: false),
            _buildTextField(_emailController, "Email", Icons.email,
                enabled: false),
            _buildTextField(_nomeController, "Nome Completo", Icons.person),
            const Divider(height: 40),
            _buildTextField(_nazioneController, "Nazione", Icons.public),
            _buildTextField(
                _localitaController, "Località", Icons.location_city),
            _buildTextField(_linguaController, "Lingua", Icons.language),
            _buildTextField(_valutaController, "Valuta", Icons.euro),
            const Divider(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Cambia il tuo PIN (opzionale)",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                _buildPasswordField(
                  _nuovoCodiceController,
                  "Nuovo PIN",
                  _obscureNuovo,
                  () => setState(() => _obscureNuovo = !_obscureNuovo),
                ),
                _buildPasswordField(
                  _confermaCodiceController,
                  "Conferma PIN",
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
            label: "Annulla",
            onTap: () => Navigator.pop(context),
          ),
          AppWidgets.actionButton(
            icon: Icons.save,
            label: "Salva",
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