// lib/src/features/group/presentation/widgets/group_display_card.dart
import 'package:flutter/material.dart';

class GroupDisplayCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;
  final VoidCallback? onDelete;

  const GroupDisplayCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Ermittle die aktuelle Textfarbe basierend auf dem Theme
    final Color iconColor = Theme.of(context).textTheme.bodyLarge!.color!;
    // Eine etwas dunklere/hellere Variante oder die Accent-Farbe könnte auch passen
    // final Color iconColor = Theme.of(context).colorScheme.onSurface; // Oder onPrimary, je nach Kontext

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    // NEU: TextStyle für kleinere Schriftgröße
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge, // Von headlineSmall auf titleLarge geändert
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    // NEU: Icon-Farbe basierend auf dem Theme
                    icon: Icon(Icons.delete_forever, color: iconColor),
                    onPressed: onDelete,
                    tooltip: 'Gruppe löschen',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
