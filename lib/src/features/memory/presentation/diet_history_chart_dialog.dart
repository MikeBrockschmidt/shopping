import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/diet_history_provider.dart';

class DietHistoryChartDialog extends StatefulWidget {
  final String groupId;

  const DietHistoryChartDialog({super.key, required this.groupId});

  @override
  State<DietHistoryChartDialog> createState() => _DietHistoryChartDialogState();
}

class _DietHistoryChartDialogState extends State<DietHistoryChartDialog> {
  int _selectedDays = 7;
  String _viewMode = 'trend'; // 'trend' oder 'distribution'

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
          return Padding(
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
                  SizedBox(
                    height: 300,
                    width: 320,
                    child: _viewMode == 'trend'
                        ? _buildLineChart(provider)
                        : _buildBarChart(provider),
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
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Schließen'),
                ),
              ],
            ),
          );
        },
      ),
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
