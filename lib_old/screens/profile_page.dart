import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final TextEditingController _gruppoController = TextEditingController();

  // Controller per il cambio codice
  final TextEditingController _nuovoCodiceController = TextEditingController();
  final TextEditingController _confermaCodiceController = TextEditingController();

  bool _obscureNuovo = true;
  bool _obscureConferma = true;

  @override
  void initState() {
    super.initState();
    _caricaDatiProfilo();
  }

  Future<void> _caricaDatiProfilo() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('utenti')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _nomeController.text = data['nome']?.toString() ?? '';
          _emailController.text = data['email']?.toString() ?? '';
          _cellulareController.text = data['cellulare']?.toString() ?? '';
          _nazioneController.text = data['nazione']?.toString() ?? '';
          _localitaController.text = data['localita']?.toString() ?? '';
          _valutaController.text = data['valuta_base']?.toString() ?? '';
          _gruppoController.text = data['gruppo']?.toString() ?? '';
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento dati: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _salvaModifiche() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    if (_nuovoCodiceController.text.isNotEmpty) {
      if (_nuovoCodiceController.text != _confermaCodiceController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("I nuovi codici non coincidono!")),
        );
        return;
      }
      if (_nuovoCodiceController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Il codice deve essere di almeno 6 caratteri")),
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
        'gruppo': _gruppoController.text.trim(),
      };

      if (_nuovoCodiceController.text.isNotEmpty) {
        updates['codice_personale'] = _nuovoCodiceController.text.trim();
      }

      await _supabase.from('utenti').update(updates).eq('id', user.id);

      if (_nuovoCodiceController.text.isNotEmpty) {
        await _supabase.auth.updateUser(
          UserAttributes(password: _nuovoCodiceController.text.trim()),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profilo aggiornato con successo!")),
        );
        // Ritorna alla pagina precedente dopo il salvataggio
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
      appBar: AppBar(
        title: const Text("Il Mio Profilo", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00B2FF),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_nomeController, "Nome Completo", Icons.person),
            _buildTextField(_emailController, "Email", Icons.email, enabled: false),
            _buildTextField(_cellulareController, "Cellulare", Icons.phone, enabled: false),
            
            const Divider(height: 40),
            
            _buildTextField(_nazioneController, "Nazione", Icons.public),
            _buildTextField(_localitaController, "Località", Icons.location_city),
            _buildTextField(_valutaController, "Valuta (es. EUR)", Icons.euro),
            _buildTextField(_gruppoController, "Gruppo", Icons.group),
            
            const Divider(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Cambia Codice Personale (opzionale)", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildPasswordField(
                    _nuovoCodiceController, 
                    "Nuovo Codice", 
                    _obscureNuovo, 
                    () => setState(() => _obscureNuovo = !_obscureNuovo)
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPasswordField(
                    _confermaCodiceController, 
                    "Conferma", 
                    _obscureConferma, 
                    () => setState(() => _obscureConferma = !_obscureConferma)
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            if (_isSaving)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  // PULSANTE ANNULLA
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00B2FF)),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("ANNULLA", 
                        style: TextStyle(color: Color(0xFF00B2FF), fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // PULSANTE SALVA
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _salvaModifiche,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B2FF),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("SALVA", 
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool enabled = true}) {
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

  Widget _buildPasswordField(TextEditingController controller, String label, bool obscure, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, size: 20),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }
}