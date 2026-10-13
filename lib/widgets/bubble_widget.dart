import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../config/app_colors.dart';
import '../config/app_spacing.dart';

class BubbleWidget extends StatelessWidget {
  final String title;
  final String text;
  final VoidCallback onClose;
  final VoidCallback onDontShowAgain;

  const BubbleWidget({
    super.key,
    required this.title,
    required this.text,
    required this.onClose,
    required this.onDontShowAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),

        // 🔥 AZZURRO IDENTICO ALLA SECONDA IMMAGINE
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade50,   // ← questo è quello giusto
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.secondaryColor.withOpacity(0.40),
            width: 1.2,
          ),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
                decoration: TextDecoration.none,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: AppColors.secondaryTextColor,
                decoration: TextDecoration.none,
                backgroundColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // ⭐ Placeholder invisibile (mantiene l'allineamento)
    const SizedBox(width: 1),

    // ⭐ Pulsante NON MOSTRARE PIÙ (sempre a destra)
    TextButton(
      onPressed: onDontShowAgain,
      child: Text(
        'non_mostrare_piu'.tr(),
        style: TextStyle(
          color: AppColors.chiusoColor,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
      ),
    ),
  ],
)


          ],
        ),
      ),
    );
  }
}
