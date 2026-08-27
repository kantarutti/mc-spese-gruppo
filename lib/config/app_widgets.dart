import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_event_states.dart';

class AppWidgets {
// 🧱 CARD TECNICA (base per tutte le card) -----------------------------
  static Widget technicalCard({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      child: Padding(
        padding: padding ?? AppSpacing.cardPadding,
        child: child,
      ),
    );
  }

// 🔵 APP_BAR -----------------------------------------------------------
  static PreferredSizeWidget appBar({
    required Widget? leftWidget,
    required Widget? titleWidget,
    required Widget? rightWidget,
  }) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false, // usiamo noi il leftWidget
      titleSpacing: 0,

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔵 LEFT WIDGET (profilo, back, icona evento, oppure null)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: leftWidget ?? const SizedBox(width: 40),
          ),

          // 🔵 TITLE WIDGET (testo, oppure icona + testo)
          Expanded(
            child: Center(
              child: titleWidget != null
                  ? DefaultTextStyle(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      child: titleWidget!,
                    )
                  : const SizedBox(),
            ),
          ),

          // 🔵 RIGHT WIDGET (logout, salva, oppure null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: rightWidget ?? const SizedBox(width: 40),
          ),
        ],
      ),
    );
  }

// 🔵 NAV BAR (NavBar di navigazione) ------------------------------------
  static Widget navBar({
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.7),
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Evento',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payments),
          label: 'Spese',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sync_alt),
          label: 'Giroconti',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Grafici',
        ),
      ],
    );
  }

// 🔵 ACTION BAR (barra dei comandi) -------------------------------------
  static Widget actionBar({
    required List<Widget> actions,
  }) {
    return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, -1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: actions.length == 1
              ? MainAxisAlignment.start // 🔥 1 pulsante → sinistra
              : actions.length == 2
                  ? MainAxisAlignment
                      .spaceBetween // 🔥 2 pulsanti → sinistra / destra
                  : MainAxisAlignment
                      .spaceEvenly, // 🔥 3+ pulsanti → distribuiti
          children: actions,
        ));
  }

// 🔵 TAB BAR (barra chiara con 3 slot: sinistra / centro / destra) ---------
static Widget tabBar({
  Widget? left,
  Widget? center,
  Widget? right,
}) {
    return Container(
      height: 60, // altezza fissa
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor, // ⭐ sfondo bianco
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: AppColors.secondaryTextColor, // ⭐ testo grigio
          fontSize: 15,                        // ⭐ font size 15
          fontWeight: FontWeight.w500,
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: left ?? const SizedBox(),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: center ?? const SizedBox(),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: right ?? const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
}

// 🔵 TAB BUTTON (pulsante chiaro per la TabBar) ---------------------------
static Widget tabButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor, // ⭐ sfondo bianco come la tabBar
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.secondaryTextColor, // ⭐ icona grigio scuro
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryTextColor, // ⭐ testo grigio scuro
              fontSize: 15,                        // ⭐ font size 15
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

// 🔵 ACTION BUTTON (pulsante singolo della ActionBar) -------------------
  static Widget actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

// 🎯 BADGE STATO EVENTO -------------------------------------------------
  static Widget stateBadge(String stato) {
    final color = AppEventStates.getColor(stato);
    final icon = AppEventStates.getIcon(stato);
    final label = AppEventStates.getLabel(stato);

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
    child: technicalCard(
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

// 🔘 PULSANTE TECNICO PRIMARIO ------------------------------------------
  static Widget primaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label),
        ],
      ),
    );
  }

// 🔘 PULSANTE TECNICO SECONDARIO ----------------------------------------
  static Widget secondaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.secondaryColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label),
        ],
      ),
    );
  }

// 🏷️ SEZIONE TITOLO (header interno pagina) -----------------------------
  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        bottom: AppSpacing.md,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryTextColor,
        ),
      ),
    );
  }

// 📌 BLOCCO INPUT + BOTTONE (rettangolare)
  static Widget configInputBlock({
    required Widget inputField,
    required Widget button,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          inputField,
          const SizedBox(height: 12),
          button,
        ],
      ),
    );
  }

// 📌 ELEMENTO LISTA CONFIGURAZIONE (Località, Valute, Gruppi, Persone)
  static Widget configListItem({
    required String title,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Titolo
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Icone azioni
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.secondaryColor,
                ),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.chiusoColor,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

// 📏 SPACER TECNICO ----------------------------------------------------
  static Widget vSpace(double value) => SizedBox(height: value);
  static Widget hSpace(double value) => SizedBox(width: value);

// 📦 ACTION CHIP WIDGET --------------------------------------------------------
  static Widget actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const Color azzurroIntenso = Color(0xFF00B2FF);

    return ActionChip(
      avatar: Icon(icon, size: 20, color: azzurroIntenso),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onPressed: onTap,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: azzurroIntenso),
      ),
    );
  }
}
