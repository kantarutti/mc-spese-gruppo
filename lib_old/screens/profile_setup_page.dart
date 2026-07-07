import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});
  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _supabase = Supabase.instance.client;
  
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cellulareController = TextEditingController(text: '+');
  final TextEditingController _nazioneController = TextEditingController();
  final TextEditingController _localitaController = TextEditingController();
  final TextEditingController _valutaBaseController = TextEditingController();
  final TextEditingController _gruppoController = TextEditingController();
  final TextEditingController _nuovoCodiceController = TextEditingController();
  final TextEditingController _confermaCodiceController = TextEditingController();

  final TextEditingController _verifyCellController = TextEditingController(text: '+');
  final TextEditingController _verifyCodiceController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isVerified = false; 
  
  String _codiceIniziale = ""; 
  String? _ruoloOriginale;
  String? _idRecordDatabase;

  bool _obscureCodice = true;
  bool _obscureConferma = true;
  bool _obscureVerify = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _isVerified = true;
      _caricaDatiProfilo();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verificaAccesso() async {
    final cell = _verifyCellController.text.trim().replaceAll(RegExp(r'\s+'), '');
    final codice = _verifyCodiceController.text.trim();

    if (cell == '+' || codice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inserisci cellulare e codice")));
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final data = await _supabase
          .from('utenti')
          .select()
          .eq('cellulare', cell)
          .eq('codice_personale', codice)
          .maybeSingle();

      if (data != null) {
        // --- NUOVO CONTROLLO: Verifica se già registrato ---
        if (data['primo_accesso'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sei già registrato. Fai il login."),
                backgroundColor: Colors.orange,
              )
            );
          }
          setState(() => _isUpdating = false);
          return; // Blocca l'accesso alla form di registrazione
        }
        // ---------------------------------------------------

        setState(() {
          _isVerified = true;
          _idRecordDatabase = data['id']; 
          _ruoloOriginale = data['ruolo'];
          _nomeController.text = data['nome'] ?? '';
          _emailController.text = data['email'] ?? '';
          _cellulareController.text = data['cellulare'] ?? '+';
          _nazioneController.text = data['nazione'] ?? '';
          _localitaController.text = data['localita'] ?? '';
          _valutaBaseController.text = data['valuta_base'] ?? '';
          _gruppoController.text = data['gruppo'] ?? '';
          _codiceIniziale = data['codice_personale'] ?? '';
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Utente non trovato. Verifica cellulare e codice."))
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e")));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _caricaDatiProfilo() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _supabase
          .from('utenti')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _idRecordDatabase = response['id'];
          _ruoloOriginale = response['ruolo'];
          _nomeController.text = response['nome']?.toString() ?? '';
          _emailController.text = response['email']?.toString() ?? '';
          _cellulareController.text = response['cellulare']?.toString() ?? '+';
          _nazioneController.text = response['nazione']?.toString() ?? '';
          _localitaController.text = response['localita']?.toString() ?? '';
          _valutaBaseController.text = response['valuta_base']?.toString() ?? '';
          _gruppoController.text = response['gruppo']?.toString() ?? '';
          _codiceIniziale = response['codice_personale']?.toString() ?? '';
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _aggiornaProfilo() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("L'email è obbligatoria")));
      return;
    }

    setState(() => _isUpdating = true);

    try {
      // 1. Creazione Utente in Auth (scatena il trigger DB che crea il record vuoto)
      final authRes = await _supabase.auth.signUp(
        email: email,
        password: _nuovoCodiceController.text.isNotEmpty 
            ? _nuovoCodiceController.text.trim() 
            : _codiceIniziale,
      );

      final String? newAuthId = authRes.user?.id;
      if (newAuthId == null) throw "Errore durante il processo di registrazione.";

      final String cellCorrente = _cellulareController.text.trim().replaceAll(RegExp(r'\s+'), '');

      // 2. ELIMINAZIONE RECORD FANTASMA
      await _supabase
          .from('utenti')
          .delete()
          .eq('id', newAuthId)
          .filter('cellulare', 'is', null);

      // 3. AGGIORNAMENTO RECORD ORIGINALE
      await _supabase
          .from('utenti')
          .update({
            'id': newAuthId, 
            'nome': _nomeController.text.trim(),
            'email': email,
            'nazione': _nazioneController.text.trim(),
            'localita': _localitaController.text.trim(),
            'valuta_base': _valutaBaseController.text.trim().toUpperCase(),
            'gruppo': _gruppoController.text.trim(),
            'codice_personale': _nuovoCodiceController.text.isNotEmpty 
                ? _nuovoCodiceController.text.trim() 
                : _codiceIniziale,
            'ruolo': _ruoloOriginale ?? 'Invitato',
            'primo_accesso': true,
          })
          .eq('cellulare', cellCorrente);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profilo configurato con successo!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore salvataggio: $e")));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text("Configurazione Profilo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _isVerified ? _buildProfileForm() : _buildVerificationForm(),
      ),
    );
  }

  Widget _buildVerificationForm() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text("Verifica Registrazione", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        _buildTextField(_verifyCellController, "Cellulare", Icons.phone, 
            inputFormatters: [UniversalPhoneFormatter()], keyboardType: TextInputType.phone),
        _buildPasswordField(_verifyCodiceController, "Codice Personale", _obscureVerify, () => setState(() => _obscureVerify = !_obscureVerify)),
        const SizedBox(height: 30),
        _isUpdating 
          ? const CircularProgressIndicator()
          : ElevatedButton(
              onPressed: _verificaAccesso,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("VERIFICA DATI"),
            ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        _buildTextField(_nomeController, "Nome Completo", Icons.person),
        _buildTextField(_emailController, "Email", Icons.email, keyboardType: TextInputType.emailAddress),
        _buildTextField(_cellulareController, "Cellulare", Icons.phone, enabled: false),
        const Divider(height: 40),
        _buildTextField(_nazioneController, "Nazione", Icons.public),
        _buildTextField(_localitaController, "Località", Icons.location_city),
        _buildTextField(_valutaBaseController, "Valuta Base (EUR, USD)", Icons.payments),
        _buildTextField(_gruppoController, "Gruppo", Icons.group),
        const Divider(height: 40),
        const Text("Cambia Codice Personale (Opzionale)", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildPasswordField(_nuovoCodiceController, "Nuovo Codice", _obscureCodice, () => setState(() => _obscureCodice = !_obscureCodice))),
            const SizedBox(width: 10),
            Expanded(child: _buildPasswordField(_confermaCodiceController, "Conferma", _obscureConferma, () => setState(() => _obscureConferma = !_obscureConferma))),
          ],
        ),
        const SizedBox(height: 30),
        _isUpdating 
          ? const CircularProgressIndicator()
          : ElevatedButton(
              onPressed: _aggiornaProfilo,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("SALVA MODIFICHE"),
            ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool enabled = true, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey[100],
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
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility : Icons.visibility_off), onPressed: onToggle),
          border: const OutlineInputBorder(),
        )
      )
    );
  }
}

class UniversalPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    if (!text.startsWith('+')) text = '+$text';
    String digits = text.substring(1).replaceAll(' ', '');
    if (digits.length > 15) digits = digits.substring(0, 15);
    String formatted = '+';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 8 || i == 11) formatted += ' ';
      formatted += digits[i];
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}