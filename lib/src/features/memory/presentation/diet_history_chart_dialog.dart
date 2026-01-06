import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/diet_history_provider.dart';
import '../data/diet_history_model.dart';

class DietHistoryChartDialog extends StatefulWidget {
  final String groupId;

  const DietHistoryChartDialog({super.key, required this.groupId});

  @override
  State<DietHistoryChartDialog> createState() => _DietHistoryChartDialogState();
}

class _DietHistoryChartDialogState extends State<DietHistoryChartDialog> {
  int _selectedDays = 7;
  String _viewMode = 'trend'; // 'trend' oder 'distribution'
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DietHistoryProvider>().fetchDietHistory(days: _selectedDays);
    });
  }

  void _onDaysChanged(int days) {
    setState(() {
      _selectedDays = days;
    });
    context.read<DietHistoryProvider>().fetchDietHistory(days: days);
  }

  List<_DayPoint> _buildDayPoints(List<dynamic> dietHistory) {
    final sorted = List.from(dietHistory)..sort((a, b) => a.date.compareTo(b.date));
    final now = DateTime.now();
    final points = <_DayPoint>[];

    for (int i = 0; i < _selectedDays; i++) {
      final date = now.subtract(Duration(days: _selectedDays - 1 - i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final entry = sorted.firstWhere(
        (item) {
          final itemDateStr =
              '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}';
          return itemDateStr == dateStr;
        },
        orElse: () => null,
      );

      points.add(
        _DayPoint(
          x: i.toDouble(),
          status: (entry?.status ?? 0),
          date: date,
          triggers: entry?.triggers ?? const <String>[],
        ),
      );
    }

    return points;
  }

  Map<int, int> _buildStatusCounts(List<dynamic> dietHistory) {
    final counts = {1: 0, 2: 0, 3: 0};
    for (final item in dietHistory) {
      if (counts.containsKey(item.status)) {
        counts[item.status] = counts[item.status]! + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Consumer<DietHistoryProvider>(
        builder: (context, provider, _) {
          final historyByDate = {
            for (final h in provider.dietHistory) _dateKey(h.date): h,
          };
          final calendarDays = _buildMonthDays(_focusedMonth);
          final maxHeight = MediaQuery.of(context).size.height * 0.85;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              minWidth: 320,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Statistik',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 20),
                    // Zeit-Filter (horizontal scroll, damit nichts überläuft)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildFilterButton('7T', 7),
                          const SizedBox(width: 8),
                          _buildFilterButton('14T', 14),
                          const SizedBox(width: 8),
                          _buildFilterButton('Monat', 30),
                          const SizedBox(width: 8),
                          _buildFilterButton('90T', 90),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Trend'),
                          selected: _viewMode == 'trend',
                          onSelected: (_) => setState(() => _viewMode = 'trend'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Verteilung'),
                          selected: _viewMode == 'distribution',
                          onSelected: (_) => setState(() => _viewMode = 'distribution'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Chart
                    if (provider.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      )
                    else if (provider.dietHistory.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Noch keine Daten verfügbar'),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          height: 320,
                          width: 320,
                          child: _viewMode == 'trend'
                              ? _buildLineChart(provider)
                              : _buildBarChart(provider),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Legende
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem('Nein', Colors.green),
                        const SizedBox(width: 16),
                        _buildLegendItem('Neutral', Colors.amber),
                        const SizedBox(width: 16),
                        _buildLegendItem('Ja', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (!provider.isLoading && provider.dietHistory.isNotEmpty) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => setState(() => _showCalendar = !_showCalendar),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kalender (Trigger)',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Icon(_showCalendar ? Icons.expand_less : Icons.expand_more),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                Text(
                                  _monthLabel(_focusedMonth),
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                IconButton(
                                  onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                                  icon: const Icon(Icons.chevron_right),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Expanded(child: Center(child: Text('Mo'))),
                                Expanded(child: Center(child: Text('Di'))),
                                Expanded(child: Center(child: Text('Mi'))),
                                Expanded(child: Center(child: Text('Do'))),
                                Expanded(child: Center(child: Text('Fr'))),
                                Expanded(child: Center(child: Text('Sa'))),
                                Expanded(child: Center(child: Text('So'))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: 1,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                              ),
                              itemCount: calendarDays.length,
                              itemBuilder: (context, index) {
                                final day = calendarDays[index];
                                final key = _dateKey(day.date);
                                final entry = historyByDate[key];
                                final hasTriggers = (entry?.triggers.isNotEmpty ?? false);
                                final statusColor = _statusColor(entry?.status ?? 0);

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: hasTriggers ? () => _showDayDetails(entry!) : null,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: hasTriggers ? statusColor.withOpacity(0.14) : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: hasTriggers ? statusColor.withOpacity(0.7) : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              day.inMonth ? day.date.day.toString() : '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: day.inMonth ? Colors.black : Colors.grey,
                                              ),
                                            ),
                                            if (hasTriggers)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4),
                                                child: Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: statusColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        crossFadeState: _showCalendar ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 180),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Schließen'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.';

  String _statusLabel(int status) {
    switch (status) {
      case 1:
        return 'Nein';
      case 2:
        return 'Neutral';
      case 3:
        return 'Ja';
      default:
        return 'Keine Angabe';
    }
  }

  Color _statusColor(int status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.amber;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _monthLabel(DateTime date) {
    const months = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ];
    final monthName = months[date.month - 1];
    return '$monthName ${date.year}';
  }

  List<_CalendarDay> _buildMonthDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = (firstDayOfMonth.weekday + 6) % 7; // Montag = 0
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final cells = rows * 7;

    final days = <_CalendarDay>[];
    for (int i = 0; i < cells; i++) {
      final dayNum = i - leadingEmpty + 1;
      if (dayNum < 1 || dayNum > daysInMonth) {
        days.add(_CalendarDay(date: firstDayOfMonth, inMonth: false));
      } else {
        days.add(
          _CalendarDay(
            date: DateTime(month.year, month.month, dayNum),
            inMonth: true,
          ),
        );
      }
    }
    return days;
  }

  Future<void> _showDayDetails(DietHistory entry) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(entry.date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(_statusLabel(entry.status), style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 10),
              if (entry.triggers.isEmpty)
                const Text('Keine Trigger für diesen Tag')
              else ...[
                const Text('Trigger', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.triggers.map((t) => Chip(label: Text(t))).toList(),
                ),
              ],
              if (entry.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Notizen', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(entry.notes),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(String label, int days) {
    final isSelected = _selectedDays == days;
    return ElevatedButton(
      onPressed: () => _onDaysChanged(days),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLineChart(DietHistoryProvider provider) {
    final points = _buildDayPoints(provider.dietHistory);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          drawVerticalLine: true,
          drawHorizontalLine: true,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _selectedDays > 14 ? (_selectedDays / 7).ceil().toDouble() : 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
                final date = points[idx].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${date.day}.${date.month}.',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const labels = ['Keine', 'Nein', 'Neutral', 'Ja'];
                if (value >= 0 && value < labels.length) {
                  return Text(
                    labels[value.toInt()],
                    style: const TextStyle(fontSize: 9),
                  );
                }
                return const Text('');
              },
              reservedSize: 50,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minY: 0,
        maxY: 3,
        lineBarsData: [
          LineChartBarData(
            spots: points.map((p) => FlSpot(p.x, p.status.toDouble())).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final status = spot.y.toInt();
                Color dotColor;
                switch (status) {
                  case 1:
                    dotColor = Colors.green;
                    break;
                  case 2:
                    dotColor = Colors.amber;
                    break;
                  case 3:
                    dotColor = Colors.red;
                    break;
                  default:
                    dotColor = Colors.grey;
                }
                return FlDotCirclePainter(
                  radius: 4,
                  color: dotColor,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((t) {
                final idx = t.x.toInt();
                if (idx < 0 || idx >= points.length) return null;
                final p = points[idx];
                String statusLabel;
                switch (p.status) {
                  case 1:
                    statusLabel = 'Grün – Ruhig';
                    break;
                  case 2:
                    statusLabel = 'Gelb – Sensibel';
                    break;
                  case 3:
                    statusLabel = 'Rot – Akut';
                    break;
                  default:
                    statusLabel = 'Keine Angabe';
                }
                final triggerText = p.triggers.isNotEmpty
                    ? '\nTrigger: ${p.triggers.join(', ')}'
                    : '';
                final dateText = '${p.date.day}.${p.date.month}.${p.date.year}';
                return LineTooltipItem(
                  '$dateText\n$statusLabel$triggerText',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).whereType<LineTooltipItem>().toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(DietHistoryProvider provider) {
    final counts = _buildStatusCounts(provider.dietHistory);
    final maxY = (counts.values.fold<int>(0, (a, b) => a > b ? a : b) + 1).toDouble();
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final percentRot = total > 0 ? ((counts[3] ?? 0) / total * 100).toStringAsFixed(0) : '0';
    final percentGelb = total > 0 ? ((counts[2] ?? 0) / total * 100).toStringAsFixed(0) : '0';
    final percentGruen = total > 0 ? ((counts[1] ?? 0) / total * 100).toStringAsFixed(0) : '0';

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        gridData: FlGridData(show: true, horizontalInterval: 1),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Rot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('$percentRot%', style: const TextStyle(fontSize: 10, color: Colors.red)),
                      ],
                    );
                  case 1:
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Gelb', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('$percentGelb%', style: const TextStyle(fontSize: 10, color: Colors.orange)),
                      ],
                    );
                  case 2:
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Grün', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('$percentGruen%', style: const TextStyle(fontSize: 10, color: Colors.green)),
                      ],
                    );
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 1),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: counts[3]?.toDouble() ?? 0, color: Colors.red, width: 22, borderRadius: BorderRadius.circular(4)),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(toY: counts[2]?.toDouble() ?? 0, color: Colors.amber, width: 22, borderRadius: BorderRadius.circular(4)),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(toY: counts[1]?.toDouble() ?? 0, color: Colors.green, width: 22, borderRadius: BorderRadius.circular(4)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayPoint {
  final double x;
  final int status;
  final DateTime date;
  final List<String> triggers;

  _DayPoint({
    required this.x,
    required this.status,
    required this.date,
    required this.triggers,
  });
}

class _CalendarDay {
  final DateTime date;
  final bool inMonth;

  _CalendarDay({required this.date, required this.inMonth});
}
