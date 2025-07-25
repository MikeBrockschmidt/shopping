import 'package:flutter/material.dart';
import 'package:shopping/src/features/todo/domain/todo.dart';
import 'package:shopping/src/theme/palette.dart';

class IconPicker extends StatefulWidget {
  final void Function(TodoIcon icon) onIconChanged;
  const IconPicker({super.key, required this.onIconChanged});

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  TodoIcon _selectedIcon = TodoIcon.values.first;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final colorWeak = color;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              spacing: 4,
              children: [
                Text("Symbole", style: Theme.of(context).textTheme.titleSmall),
                Tooltip(
                  message:
                      "Wähle hier ein Symbol für die Darstellung in der Todo Liste",
                  child: Icon(Icons.info, size: 16),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              runSpacing: 16,
              spacing: 32,
              children: TodoIcon.values.map((e) {
                bool isSelected = _selectedIcon == e;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = e;
                    });
                    widget.onIconChanged(_selectedIcon);
                  },
                  child: Opacity(
                    opacity: isSelected ? 1 : 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(200),
                            blurRadius: isSelected ? 6 : 0,
                            spreadRadius: 0,
                          ),
                        ],
                        color: isSelected ? color : colorWeak,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          e.icon,
                          color: isSelected ? Palette.white : null,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
