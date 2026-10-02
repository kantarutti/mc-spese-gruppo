import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../config/app_widgets.dart';
import '../../services/phone_info_service.dart';

class ProfileSetupPage extends StatefulWidget {
  final String cellulare;
  const ProfileSetupPage({super.key, required this.cellulare});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _supabase = Supabase.instance.client;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cellulareController = TextEditingController();
  final TextEditingController _nazioneController = TextEditingController();
  final TextEditingController _localitaController = TextEditingController();
  final TextEditingController _valutaBaseController = TextEditingController();
  final TextEditingController _nuovoCodiceController = TextEditingController();
  final TextEditingController _confermaCodiceController =
      TextEditingController();

  bool _isLoading = false;
  bool _isUpdating = false;

  String _codiceIniziale = "";

  bool _obscureCodice = true;
  bool _obscureConferma = true;

  @override
  void initState() {
    super.initState();
    _isLoading = true;

    _cellulareController.text = widget.cellulare;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final response = await _supabase
        .from('utenti')
        .select()
        .eq('cellulare', widget.cellulare)
        .maybeSingle();

    if (response != null) {
      _nomeController.text = response['nome'] ?? '';
      _emailController.text = response['email'] ?? '';
      _localitaController.text = response['localita'] ?? '';
      _codiceIniziale = response['PIN'] ?? '';

      if ((response['nazione'] ?? '').isNotEmpty) {
        _nazioneController.text = response['nazione'];
      }

      if ((response['valuta_base'] ?? '').isNotEmpty) {
        _valutaBaseController.text = response['valuta_base'];
      }

      if (_nazioneController.text.isEmpty ||
          _valutaBaseController.text.isEmpty) {
        final info = PhoneInfoService.getCountryInfo(widget.cellulare);

        if (info != null) {
          final nazione = info['nazione'] ?? '';
          final valuta = info['valuta'] ?? '';

          _nazioneController.text =
              (nazione.toLowerCase() == 'nazione sconosciuta') ? '' : nazione;

          _valutaBaseController.text =
              (valuta.toLowerCase() == 'valuta sconosciuta') ? '' : valuta;
        } else {
          _nazioneController.text = '';
          _valutaBaseController.text = '';
        }
      }
    } else {
      final info = PhoneInfoService.getCountryInfo(widget.cellulare);
      if (info != null) {
        _nazioneController.text = info['nazione']!;
        _valutaBaseController.text = info['valuta']!;
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _aggiornaProfilo() async {
    final email = _emailController.text.trim();
    final password = _nuovoCodiceController.text.isNotEmpty
        ? _nuovoCodiceController.text.trim()
        : _codiceIniziale;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("L'email è obbligatoria")));
      return;
    }

    setState(() => _isUpdating = true);

    try {
      await _supabase.from('utenti').update({
        'nome': _nomeController.text.trim(),
        'email': email,
        'nazione': _nazioneController.text.trim(),
        'localita': _localitaController.text.trim(),
        'valuta_base': _valutaBaseController.text.trim().toUpperCase(),
        'PIN': password,
        'ruolo': 'Ospite',
        'utente_registrato': true,
      }).eq('cellulare', widget.cellulare);

      final utenteRecord = await _supabase
          .from('utenti')
          .select()
          .eq('cellulare', widget.cellulare)
          .single();

      final utenteId = utenteRecord['id'];

      AuthResponse loginRes;

      try {
        loginRes = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              'display_name': _nomeController.text.trim(),
              'phone': widget.cellulare,
            },
          ),
        );
      } catch (e) {
        final signUpRes = await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'display_name': _nomeController.text.trim(),
            'phone': widget.cellulare,
          },
        );

        if (signUpRes.user == null) {
          throw "Errore nella registrazione utente.";
        }

        loginRes = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }

      final user = loginRes.user;

      if (user != null) {
        await _supabase.from('utenti').update({
          'auth_id': user.id,
        }).eq('cellulare', widget.cellulare);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cellulare', widget.cellulare);
      await prefs.setString('utente_id', utenteId.toString());
      await prefs.setString('utente_nome', _nomeController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profilo configurato con successo!")),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore salvataggio: $e")),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppWidgets.appBar(
        leftWidget: const SizedBox(width: 40),
        titleWidget: const Text("Configurazione Profilo"),
        rightWidget: const SizedBox(width: 40),
      ),

      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: _buildProfileForm(),
      ),

      bottomNavigationBar: AppWidgets.actionBar(
        actions: [
          AppWidgets.actionButton(
            icon: Icons.close,
            label: "Annulla",
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
          AppWidgets.actionButton(
            icon: Icons.save,
            label: "Salva",
            onTap: _aggiornaProfilo,
          ),
        ],
      ),
    );
  }
 
  Widget _buildProfileForm() {
    return Column(
      children: [
        _buildTextField(
          _cellulareController,
          "Cellulare",
          Icons.phone,
          enabled: false,
        ),
        _buildTextField(
          _nomeController,
          "Nome Completo",
          Icons.person,
          hint: "Inserisci il tuo nome",
        ),
        _buildTextField(
          _emailController,
          "Email",
          Icons.email,
          keyboardType: TextInputType.emailAddress,
          hint: "Inserisci la tua email",
        ),
        const Divider(height: 40),
        _buildTextField(
          _nazioneController,
          "Nazione",
          Icons.public,
          hint: "Inserisci la tua nazione",
        ),
        _buildTextField(
          _localitaController,
          "Località",
          Icons.location_city,
          hint: "Inserisci la tua città",
        ),
        _buildTextField(
          _valutaBaseController,
          "Valuta",
          Icons.payments,
          hint: "Es. EUR, USD, GBP",
        ),
        const Divider(height: 40),
        const Text("Cambia PIN (Opzionale)",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildPasswordField(
                _nuovoCodiceController,
                "Nuovo Codice",
                _obscureCodice,
                () => setState(() => _obscureCodice = !_obscureCodice),
                hint: "Nuovo PIN",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPasswordField(
                _confermaCodiceController,
                "Conferma",
                _obscureConferma,
                () => setState(() => _obscureConferma = !_obscureConferma),
                hint: "Ripeti PIN",
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        _isUpdating
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _aggiornaProfilo,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text("SALVA MODIFICHE"),
              ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool enabled = true,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey[100],
        ),
      ),
    );
  }
 
  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool obscure,
    VoidCallback onToggle, {
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: onToggle,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
