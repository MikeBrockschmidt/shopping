import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Formatiert das Datum als "Tag. Monat Jahr" (z.B. "19. Juli 2025")
  String get longDateString {
    return DateFormat('dd. MMMM yyyy').format(this);
  }

  /// Formatiert das Datum als "TT.MM.JJJJ" (z.B. "19.07.2025")
  String get shortDateString {
    return DateFormat('dd.MM.yyyy').format(this);
  }
}
