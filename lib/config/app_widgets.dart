import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_event_states.dart';

enum FieldMode { edit, readOnly, disabled }

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
  automaticallyImplyLeading: false,
  titleSpacing: 0,

  title: Row(
    children: [
      // 🔵 LEFT — si adatta allo spazio disponibile
      Flexible(
        flex: 0,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: leftWidget ?? const SizedBox(),
        ),
      ),

      // 🔵 TITLE — ha priorità, prende tutto lo spazio centrale
      Expanded(
        child: Center(
          child: titleWidget != null
              ? DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: titleWidget!,
                  ),
                )
              : const SizedBox(),
        ),
      ),

      // 🔵 RIGHT — si adatta allo spazio disponibile
      Flexible(
        flex: 0,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: rightWidget ?? const SizedBox(),
        ),
      ),
    ],
  ),
);
  }

////// 🔵 EVENT BAR (EventBar di navigazione personalizzata) --------------------
  static Widget eventBar({
    required int currentIndex,
    required Function(int) onTap,
    bool isChiuso = false,
  }) {
    // Definizione dei tab della barra
    final items = [
      {'icon': Icons.home, 'label': 'Home'},
      {'icon': Icons.event, 'label': 'Riepilogo'},
      {'icon': Icons.payments, 'label': 'Spese'},
      {'icon': Icons.sync_alt, 'label': 'Giroconti'},
      {'icon': Icons.bar_chart, 'label': 'Grafici'},
    ];

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, -1),
            blurRadius: AppSpacing.blurMd,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          
          // Se l'evento è chiuso e siamo su Spese (2) o Giroconti (3), forziamo il rosso
          final bool isTargetChiuso = isChiuso && (index == 2 || index == 3);
          
          final Color itemColor = isTargetChiuso
              ? Colors.red
              : isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.7);

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[index]['icon'] as IconData,
                    color: itemColor,
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: 12,
                      fontWeight: isSelected || isTargetChiuso
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
// 🔵 ACTION BAR (barra dei comandi) -------------------------------------
  static Widget actionBar({
    required List<Widget> actions,
  }) {
    return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, -1),
              blurRadius: AppSpacing.blurMd,
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

// 🔵 ACTION BAR BILANCIATA (Adattata esattamente sulla struttura della whiteBar) ----
  static Widget actionBarBalanced({
    Widget? left,
    Widget? center,
    Widget? right,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, -1),
            blurRadius: AppSpacing.blurMd,
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔵 LEFT — prende lo spazio rimanente
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: left ?? const SizedBox(),
            ),
          ),

          // 🔵 CENTER — si adatta al contenuto
          Flexible(
            flex: 0,
            child: Align(
              alignment: Alignment.center,
              child: center ?? const SizedBox(),
            ),
          ),

          // 🔵 RIGHT — prende lo spazio rimanente
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: right ?? const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 WHITE BAR (barra chiara con 3 slot: sinistra / centro / destra)
  static Widget whiteBar({
    Widget? left,
    Widget? center,
    Widget? right,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -1),
            blurRadius: AppSpacing.blurSm,
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: AppColors.secondaryTextColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        child: Row(
          children: [
            // 🔵 LEFT — prende lo spazio rimanente
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: left ?? const SizedBox(),
              ),
            ),

            // 🔵 CENTER — si adatta al contenuto (come l’appBar)
            Flexible(
              flex: 0,
              child: Align(
                alignment: Alignment.center,
                child: center ?? const SizedBox(),
              ),
            ),

            // 🔵 RIGHT — prende lo spazio rimanente
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

// 🔵 WHITE BUTTON (pulsante chiaro per la TabBar) ---------------------------
static Widget whiteButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor, // ⭐ sfondo bianco come la tabBar
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.secondaryTextColor, // ⭐ icona grigio scuro
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
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
    Color? textColor, // Se non passato, prenderà il default da AppColors
  }) {
    // Imposta il colore di default usando AppColors.primaryTextColor se textColor è null
    final resolvedTextColor = textColor ?? AppColors.primaryTextColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: resolvedTextColor, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                color: resolvedTextColor,
                fontSize: AppSpacing.lg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

// 🔵 CAMPO DI INPUT / DISPLAY ==================================================
static Widget inputField({
  required String label,
  required TextEditingController controller,

  // Opzioni comuni
  IconData icon = Icons.edit,
  Function(String)? onChanged,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,

  // Modalità
  FieldMode mode = FieldMode.edit,
}) 

{
  final bool isReadOnly = mode == FieldMode.readOnly;
  final bool isDisabled = mode == FieldMode.disabled;
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,

    // Comportamento
    readOnly: isReadOnly || isDisabled,
    enabled: !isDisabled,
    focusNode: isDisabled ? AlwaysDisabledFocusNode() : null,
    enableInteractiveSelection: !isDisabled && !isReadOnly,

    // Stile del testo
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: isDisabled
          ? Colors.grey[700]
          : isReadOnly
              ? Colors.grey[700]
              : Colors.black,
    ),

    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),

      // Sfondo e bordo in base alla modalità
      filled: isReadOnly || isDisabled,
      fillColor: isDisabled
          ? Colors.grey.withOpacity(0.25)
          : isReadOnly
              ? Colors.grey.withOpacity(0.15)
              : null,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        borderSide: BorderSide(
          color: isDisabled
              ? Colors.grey.shade400
              : isReadOnly
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
        ),
      ),
    ),

    // Callback solo in modalità edit
    onChanged: mode == FieldMode.edit ? onChanged : null,
  );
}

// 🔵 CAMPO DROPDOWN ==========================================================
  static Widget dropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    IconData icon = Icons.list,
    FieldMode mode = FieldMode.edit,
  }) {
    final bool isReadOnly = mode == FieldMode.readOnly;
    final bool isDisabled = mode == FieldMode.disabled;
    final bool isBlocked = isReadOnly || isDisabled;

    return DropdownButtonFormField<String>(
      value: value,
      
      // Stile del testo selezionato unificato
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: isBlocked ? Colors.grey[700] : Colors.black,
      ),

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),

        // Sfondo e bordo in base alla modalità
        filled: isBlocked,
        fillColor: isDisabled
            ? Colors.grey.withOpacity(0.25)
            : isReadOnly
                ? Colors.grey.withOpacity(0.15)
                : null,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(
            color: isBlocked ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(
            color: isBlocked ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ),

      items: options
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              ))
          .toList(),

      // Callback disabilitato se non siamo in modalità edit
      onChanged: mode == FieldMode.edit ? onChanged : null,
    );
  }

// 🔵 BOX PER LE DATE =============================================================
  static Widget dateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    FieldMode mode = FieldMode.edit,
  }) {
    final bool isReadOnly = mode == FieldMode.readOnly;
    final bool isDisabled = mode == FieldMode.disabled;

    return InkWell(
      // Se non siamo in edit, disabilitiamo il tap
      onTap: mode == FieldMode.edit ? onTap : null,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),

          // Sfondo e bordo coerenti con gli altri campi
          filled: isReadOnly || isDisabled,
          fillColor: isDisabled
              ? Colors.grey.withOpacity(0.25)
              : isReadOnly
                  ? Colors.grey.withOpacity(0.15)
                  : null,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            borderSide: BorderSide(
              color: isDisabled
                  ? Colors.grey.shade400
                  : isReadOnly
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            borderSide: BorderSide(
              color: isDisabled
                  ? Colors.grey.shade400
                  : isReadOnly
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
            ),
          ),
        ),
        child: Text(
          date == null
              ? "Seleziona"
              : "${date.day}/${date.month}/${date.year}",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: isDisabled
                ? Colors.grey[500]
                : isReadOnly
                    ? Colors.grey[500]
                    : Colors.black,
          ),
        ),
      ),
    );
  }

// 🔵 BOX PER LE VALUTE ==========================================================
  static Widget valutaField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    FieldMode mode = FieldMode.edit, // 👈 Aggiunto per coerenza
  }) {
    final bool isReadOnly = mode == FieldMode.readOnly;
    final bool isDisabled = mode == FieldMode.disabled;

    return DropdownButtonFormField<String>(
      value: value,

      // Stile del testo selezionato
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: isDisabled
            ? Colors.grey[700]
            : isReadOnly
                ? Colors.grey[700]
                : Colors.black,
      ),

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.currency_exchange),

        // Sfondo e bordo coerenti con gli altri campi
        filled: isReadOnly || isDisabled,
        fillColor: isDisabled
            ? Colors.grey.withOpacity(0.25)
            : isReadOnly
                ? Colors.grey.withOpacity(0.15)
                : null,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(
            color: isDisabled
                ? Colors.grey.shade400
                : isReadOnly
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
          ),
        ),
      ),

      items: options
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              ))
          .toList(),

      // Callback disabilitato se non siamo in modalità edit
      onChanged: mode == FieldMode.edit ? onChanged : null,
    );
  }

// 📦 ACTION CHIP WIDGET --------------------------------------------------------
  static Widget actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    FieldMode mode = FieldMode.edit,
  }) {
    const Color azzurroIntenso = Color(0xFF00B2FF);
    final bool isReadOnly = mode == FieldMode.readOnly;
    final bool isDisabled = mode == FieldMode.disabled;
    final bool isBlocked = isReadOnly || isDisabled;

    return InkWell(
      onTap: isBlocked ? null : onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isBlocked ? Colors.grey.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: azzurroIntenso, // 👈 Il bordo rimane sempre azzurro
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isBlocked ? Colors.grey[500] : azzurroIntenso,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBlocked ? Colors.grey[700] : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

/// 📏 SPACER TECNICO ----------------------------------------------------
  static Widget vSpace(double value) => SizedBox(height: value);
  static Widget hSpace(double value) => SizedBox(width: value);
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}


