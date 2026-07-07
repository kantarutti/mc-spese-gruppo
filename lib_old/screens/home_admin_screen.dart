import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  static const Color azzurroIntenso = Color(0xFF00B2FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: azzurroIntenso,
        title: const Text("Pannello Admin", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // Corretto: Creiamo l'istanza per chiamare il metodo logout()
              final authService = AuthService();
              await authService.logout(); 
              
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Benvenuto nell'area Amministratore"),
      ),
    );
  }
}