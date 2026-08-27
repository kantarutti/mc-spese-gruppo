import 'package:flutter/material.dart';
import '../services/gruppi_service.dart';

class DialogModificaGruppo extends StatefulWidget {
  final String gruppoId;
  final String nomeIniziale;
  final int numeroIniziale;

  const DialogModificaGruppo({
    super.key,
    required this.gruppoId,
    required this.nomeIniziale,
    required this.numeroIniziale,
  });

  @override
  State<DialogModificaGruppo> createState() => _DialogModificaGruppoState();
}

class _DialogModificaGruppoState extends State<DialogModificaGruppo> {
  final GruppiService _gruppiService = GruppiService();

  late TextEditingController nomeController;
  late TextEditingController numeroController;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.nomeIniziale);
    numeroController =
        TextEditingController(text: widget.numeroIniziale.toString());
  }

  Future<void> _salvaModifiche() async {
    final nuovoNome = nomeController.text.trim();
    final nuovoNumero = int.tryParse(numeroController.text.trim()) ?? 0;

    if (nuovoNome.isEmpty) return;

    await _gruppiService.updateGruppo(
      gruppoId: widget.gruppoId,
      nome: nuovoNome, // ✔ nome corretto
      numeroPersone: nuovoNumero, // ✔ nome corretto
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Modifica Gruppo",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: "Nome Gruppo",
              icon: Icon(Icons.group),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: numeroController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Numero Persone",
              icon: Icon(Icons.people),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("ANNULLA"),
        ),
        ElevatedButton(
          onPressed: _salvaModifiche,
          child: const Text("SALVA"),
        ),
      ],
    );
  }
}
