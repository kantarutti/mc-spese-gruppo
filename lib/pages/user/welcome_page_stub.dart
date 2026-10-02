import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/auth_service.dart';

class WelcomePagePlatform extends StatelessWidget {
  const WelcomePagePlatform({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() async {
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        // ⭐ IMPORTANTE PER WINDOWS
        await AuthService.refreshCurrentUser(session.user.id);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return const SizedBox.shrink();
  }
}
