import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_event_states.dart';

class EventWidgets {
  const EventWidgets._(); // opzionale

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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Icona + Nome + Località + Pillola Stato
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ICONA A SINISTRA (sfondo blu navy)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor, // navy originale
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),

                const SizedBox(width: 12),

                // NOME + LOCALITÀ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titolo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.place,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              luogo,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // PULSANTE STATO (moderno, colore dello stato, bordo)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppEventStates.getColor(stato).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppEventStates.getColor(stato),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    stato,
                    style: TextStyle(
                      color: AppEventStates.getColor(stato),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // DATE (con icona, a tutta larghezza)
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateRange,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// BOX CARD VISULIZZAZIONE ====================================================
  static Widget boxCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

// BOX CARD EDITABILE ====================================================
  static Widget editableBoxCard({
    required bool isEditing,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Card(
      elevation: 0,
      color: isEditing
          ? Colors.black.withOpacity(0.05) // 🔵 colore più chiaro in modifica
          : Colors.blue.withOpacity(0.05), // 🔵 colore scuro in visualizzazione
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

// CAMPO DI INPUT ==========================================================
  static Widget inputField({
    required String label,
    required TextEditingController controller,
    IconData icon = Icons.edit,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
    );
  }

// CAMPO DROPDOWN ==========================================================
  static Widget dropdownField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    IconData icon = Icons.list,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: options
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

// CAMPO IN SOLA VISUALIZZAZIONE =============================================
  static Widget readOnlyField({
    required String label,
    required String value,
    IconData icon = Icons.info,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      focusNode: AlwaysDisabledFocusNode(), // 🔥 impedisce il focus
      enableInteractiveSelection: false, // 🔥 impedisce selezione testo
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),

          // ⭐ AGGIUNTA DELLO SFONDO GRIGIO CHIARO
          filled: true,
          fillColor: Colors.grey.withOpacity(0.15),

          // ⭐ (opzionale) bordo più morbido
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          )),
    );
  }

// BOX PER LE DATE =============================================================
  static Widget dateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            date == null
                ? "Seleziona"
                : "${date.day}/${date.month}/${date.year}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold, // ✔ QUI FUNZIONA
            ),
          ),
        ));
  }

// BOX PER LE VALUTE ==========================================================
  static Widget valutaField({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.currency_exchange),
      ),
      items: options
          .map((v) => DropdownMenuItem(
                value: v,
                child: Text(v),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
