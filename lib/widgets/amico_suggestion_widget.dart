import 'package:flutter/material.dart';

class AmicoSuggestionList extends StatelessWidget {
  final List<Map<String, dynamic>> risultati;
  final Function(Map<String, dynamic>) onSelect;

  const AmicoSuggestionList({
    super.key,
    required this.risultati,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (risultati.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        itemCount: risultati.length,
        itemBuilder: (context, index) {
          final amico = risultati[index];

          return ListTile(
            title: Text(amico['friend_name']),
            subtitle: Text(amico['friend_cellulare'] ?? ''),
            onTap: () => onSelect(amico),
          );
        },
      ),
    );
  }
}
