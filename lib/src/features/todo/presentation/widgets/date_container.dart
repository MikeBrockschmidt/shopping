import 'package:flutter/material.dart';
import 'package:shopping/src/theme/palette.dart';

class DateContainer extends StatelessWidget {
  final String day;
  final bool isToday;

  const DateContainer({super.key, required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: isToday
          ? BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: Palette.white, width: 1.6),
            )
          : null,
      child: Center(
        child: Text(
          day,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: Palette.white),
        ),
      ),
    );
  }
}
