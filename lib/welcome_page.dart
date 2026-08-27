import 'package:flutter/material.dart';

import 'welcome_page_stub.dart'
    if (dart.library.html) 'welcome_page_web.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WelcomePagePlatform();
  }
}
