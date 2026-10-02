import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_event_states.dart';
import '../config/app_spacing.dart';
import '../config/app_widgets.dart';
import '../models/event_states_model.dart';
 
class EventoCard {
  const EventoCard._(); // opzionale

// 🎯 BADGE STATO EVENTO -------------------------------------------------
static Widget stateBadge(String stato) {
  final eventState = EventStateParser.fromString(stato);

  final color = AppEventStates.getColor(eventState);
  final icon = AppEventStates.getIcon(eventState);
  final label = eventState.label;


    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

// 📌 CARD EVENTO (cliccabile, con icona a sinistra, senza pulsanti) NEW ------
static Widget eventCard({
  required String titolo,
  required String dateRange,
  required String luogo,
  required String stato,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: AppWidgets.technicalCard(
      padding: const EdgeInsets.all(10),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Icona centrata su 3 righe
        children: [
          // 🔵 ICONA (colonna sinistra, va bene così)
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),

          const SizedBox(width: AppSpacing.md),

          // 🔵 BLOCCO DESTRO (due colonne + periodo sotto)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 RIGA 1-2: Nome + Località + Stato
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // COLONNA SINISTRA: Nome + Località
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome
                          Text(
                            titolo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),

                          const SizedBox(height: 2),

                          // Località
                          Row(
                            children: [
                              const Icon(Icons.place_outlined,
                                  size: 18, color: AppColors.secondaryTextColor),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(child: Text(luogo)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // COLONNA DESTRA: Stato (centrato verticalmente su Nome+Località)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        stateBadge(stato),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 🔵 RIGA 3: Periodo (larga quanto Località + Stato)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.secondaryTextColor),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        dateRange,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


}
