import 'package:shopping/src/features/todo/domain/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' hide Priority;

class PrioritySlider extends StatefulWidget {
  final void Function(Priority p) onPriorityChanged;

  const PrioritySlider({super.key, required this.onPriorityChanged});

  @override
  State<PrioritySlider> createState() => _PrioritySliderState();
}

class _PrioritySliderState extends State<PrioritySlider> {
  double priorityValue = 1;
  Priority p = Priority.medium;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Priorität",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Slider(
              max: Priority.values.length - 1,
              divisions: Priority.values.length - 1,
              value: priorityValue,
              onChanged: (newValue) {
                setState(() {
                  priorityValue = newValue;
                  p = Priority.values[priorityValue.toInt()];
                });
                widget.onPriorityChanged(p);
              },
            ),
            Text(p.german),
          ],
        ),
      ),
    );
  }
}
