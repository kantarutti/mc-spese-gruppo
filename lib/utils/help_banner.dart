import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../config/app_spacing.dart';

class HelpBanner extends StatefulWidget {
  final String prefsKey;      // es: "showTeamsHelp"
  final String title;         // titolo del banner
  final String message;       // testo descrittivo
  final bool visible;         // mostra solo se la lista è vuota

  const HelpBanner({
    super.key,
    required this.prefsKey,
    required this.title,
    required this.message,
    required this.visible,
  });

  @override
  State<HelpBanner> createState() => _HelpBannerState();
}
class _HelpBannerState extends State<HelpBanner> {
  bool show = true;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadFlag();
  }

  Future<void> _loadFlag() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      show = prefs.getBool(widget.prefsKey) ?? true;
    });
  }

  Future<void> _disableHelp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(widget.prefsKey, false);
    setState(() => show = false);
  }

  void hideOnTyping() {
    setState(() => isTyping = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible || !show || isTyping) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.secondaryColor.withOpacity(0.40),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.message,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.secondaryTextColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(() => show = false),
                child: const Text(
                  "Chiudi",
                  style: TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _disableHelp,
                child: const Text(
                  "Non mostrare più",
                  style: TextStyle(
                    color: AppColors.chiusoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
