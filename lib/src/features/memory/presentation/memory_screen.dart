import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory/src/features/memory/presentation/memory_provider.dart';
import 'package:memory/src/features/memory/data/diet_history_provider.dart';
import 'package:memory/src/features/memory/presentation/diet_history_chart_dialog.dart';

class MemoryScreen extends StatefulWidget {
  final String groupId;

  const MemoryScreen({super.key, required this.groupId});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final List<double> _glassesOpacity = List.generate(8, (_) => 0.5);
  
  // Medikamente für jeden Tag (7 Tage x 5 Medikamente)
  List<List<bool>> _medicationsPerDay = List.generate(7, (_) => List.generate(5, (_) => false));
  
  final List<String> _medications = [
    'Medikament 1',
    'Medikament 2',
    'Medikament 3',
    'Medikament 4',
    'Medikament 5',
  ];

  final List<String> _triggerOptions = const [
    'Zu fettig',
    'Zu süß',
    'Stress',
    'Zu spät gegessen',
    'Kaffee leerer Magen',
    'Schnell gegessen',
  ];

  // Ampel-Status pro Tag: 0 = nichts gewählt, 1 = grün, 2 = gelb, 3 = rot
  List<int> _dietStatusPerDay = List.generate(7, (_) => 0);

  // Trigger-Auswahl pro Tag
  List<List<String>> _dietTriggersPerDay =
      List.generate(7, (_) => <String>[]);

  // Notizen pro Tag
  List<String> _dietNotesPerDay = List.generate(7, (_) => '');

  // TextEditingControllers für Notizen pro Tag
  late List<TextEditingController> _noteControllers;

  // Track welche ToDos sichtbar sind (per Tag)
  List<Map<String, bool>> _visibleTodos = List.generate(7, (_) => {
    'medications': true,
    'diet': true,
    'drinking': true,
  });

  double _currentLiters = 0.0;

  String _getDateLabel(int daysFromNow) {
    final date = DateTime.now().add(Duration(days: daysFromNow));
    
    if (daysFromNow == 0) {
      return 'Heute';
    } else if (daysFromNow == 1) {
      return 'Morgen';
    } else {
      final weekdays = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];
      final weekday = weekdays[date.weekday - 1];
      final dateStr = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
      return '$weekday, $dateStr';
    }
  }

  Color _getDateColor(int daysFromNow) {
    final colors = [
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.orange.shade50,
      Colors.purple.shade50,
      Colors.pink.shade50,
      Colors.teal.shade50,
      Colors.amber.shade50,
    ];
    return colors[daysFromNow % colors.length];
  }

  Color _getDateTextColor(int daysFromNow) {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.pink.shade700,
      Colors.teal.shade700,
      Colors.amber.shade700,
    ];
    return colors[daysFromNow % colors.length];
  }

  IconData _getDateIcon(int daysFromNow) {
    if (daysFromNow == 0) return Icons.calendar_today;
    if (daysFromNow == 1) return Icons.wb_sunny_outlined;
    return Icons.date_range;
  }

  void _memoryProviderListener() {
    final memoryProvider = context.read<MemoryProvider>();
    if (memoryProvider.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(memoryProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        memoryProvider.clearErrorMessage();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<MemoryProvider>().addListener(_memoryProviderListener);
    _calculateCurrentLiters();
    _noteControllers = List.generate(
      7,
      (index) => TextEditingController(text: _dietNotesPerDay[index]),
    );
  }

  @override
  void dispose() {
    for (final controller in _noteControllers) {
      controller.dispose();
    }
    context.read<MemoryProvider>().removeListener(_memoryProviderListener);
    super.dispose();
  }

  void _calculateCurrentLiters() {
    _currentLiters =
        _glassesOpacity.where((opacity) => opacity == 1.0).length * 0.2;
  }

  void _setDietStatus(int dayIndex, int status) {
    setState(() {
      _dietStatusPerDay[dayIndex] = status;
    });
  }

  void _toggleTrigger(int dayIndex, String tag) {
    setState(() {
      final selected = _dietTriggersPerDay[dayIndex];
      if (selected.contains(tag)) {
        selected.remove(tag);
      } else {
        selected.add(tag);
      }
    });
  }

  Widget _buildAmpelCircle({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.85) : color.withOpacity(0.35),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.8),
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _toggleGlassState(int index) {
    setState(() {
      if (index >= 0 && index < _glassesOpacity.length) {
        _glassesOpacity[index] = _glassesOpacity[index] == 0.5 ? 1.0 : 0.5;
        _calculateCurrentLiters();
      }
    });
  }

  Widget _buildGlassColumn(int index) {
    final Color glassColor = _glassesOpacity[index] == 1.0
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;

    return Column(
      children: [
        IconButton(
          icon: Opacity(
            opacity: _glassesOpacity[index],
            child: Icon(Icons.local_drink, size: 60, color: glassColor),
          ),
          onPressed: () => _toggleGlassState(index),
        ),
        const SizedBox(height: 4),
        Text('0,2L', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final memoryProvider = context.watch<MemoryProvider>();

    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final String backgroundImage = isDarkMode
        ? 'assets/images/wedoshopping_dr.png'
        : 'assets/images/wedoshopping_dr-d.png';

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 200,
          elevation: 16,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(backgroundImage, fit: BoxFit.cover),
          ),
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: List.generate(7, (dayIndex) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                color: _getDateColor(dayIndex),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Icon(_getDateIcon(dayIndex), color: _getDateTextColor(dayIndex), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _getDateLabel(dayIndex),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getDateTextColor(dayIndex),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    // Ampel-Check: Süßes/fettiges gegessen?
                    if (_visibleTodos[dayIndex]['diet'] == true)
                      Dismissible(
                        key: Key('diet_$dayIndex'),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            _visibleTodos[dayIndex]['diet'] = false;
                          });
                        },
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              'Hast du heute was süßes oder fettiges gegessen?',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.show_chart, color: Colors.blue),
                              tooltip: 'Statistik anzeigen',
                              onPressed: () {
                                final dietHistoryProvider = context.read<DietHistoryProvider>();
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => ChangeNotifierProvider.value(
                                    value: dietHistoryProvider,
                                    child: DietHistoryChartDialog(groupId: widget.groupId),
                                  ),
                                );
                              },
                            ),
                            children: [
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 84,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildAmpelCircle(
                                            label: 'Nein',
                                            color: Colors.green,
                                            isSelected: _dietStatusPerDay[dayIndex] == 1,
                                            onTap: () => _setDietStatus(dayIndex, 1),
                                          ),
                                          _buildAmpelCircle(
                                            label: 'Neutral',
                                            color: Colors.amber,
                                            isSelected: _dietStatusPerDay[dayIndex] == 2,
                                            onTap: () => _setDietStatus(dayIndex, 2),
                                          ),
                                          _buildAmpelCircle(
                                            label: 'Ja',
                                            color: Colors.red,
                                            isSelected: _dietStatusPerDay[dayIndex] == 3,
                                            onTap: () => _setDietStatus(dayIndex, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        if (_dietStatusPerDay[dayIndex] == 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Bitte wähle erst eine Option'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                          return;
                                        }

                                        final selectedTriggers = List<String>.from(_dietTriggersPerDay[dayIndex]);
                                        final notes = _dietNotesPerDay[dayIndex];

                                        setState(() {
                                          _visibleTodos[dayIndex]['diet'] = false;
                                        });

                                        final targetDate = DateTime.now().add(Duration(days: dayIndex));
                                        final dietProvider = context.read<DietHistoryProvider>();
                                        dietProvider
                                            .saveDietStatus(
                                              _dietStatusPerDay[dayIndex],
                                              date: targetDate,
                                              triggers: selectedTriggers,
                                              notes: notes,
                                            )
                                            .then((_) => dietProvider.fetchDietHistory())
                                            .then((_) {
                                              final errorMsg = dietProvider.errorMessage;
                                              if (mounted) {
                                                if (errorMsg != null && errorMsg.isNotEmpty) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Fehler: $errorMsg'),
                                                      duration: const Duration(seconds: 2),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                  dietProvider.clearErrorMessage();
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Ernährungsstatus gespeichert'),
                                                      duration: Duration(seconds: 1),
                                                    ),
                                                  );
                                                }
                                              }
                                            })
                                            .catchError((e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Fehler: $e'),
                                                    duration: const Duration(seconds: 2),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            });
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blueAccent,
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.check, color: Colors.white),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Fertig',
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Speichern',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Was war der Auslöser? (Mehrfachauswahl möglich)',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _triggerOptions.map((tag) {
                                  final isSelected = _dietTriggersPerDay[dayIndex].contains(tag);
                                  return FilterChip(
                                    label: Text(tag),
                                    selected: isSelected,
                                    onSelected: (_) => _toggleTrigger(dayIndex, tag),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Notiz (optional)',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _noteControllers[dayIndex],
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: 'z.B. Pizza und Eistee gegessen',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                                onChanged: (value) {
                                  _dietNotesPerDay[dayIndex] = value;
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),

                    // Medikamente für alle Tage
                    if (_visibleTodos[dayIndex]['medications'] == true)
                      Dismissible(
                        key: Key('medications_$dayIndex'),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            _visibleTodos[dayIndex]['medications'] = false;
                          });
                        },
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              'Medikamente',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            children: <Widget>[
                              Column(
                                children: List.generate(5, (medIndex) =>
                                  CheckboxListTile(
                                    title: Text(_medications[medIndex]),
                                    value: _medicationsPerDay[dayIndex][medIndex],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _medicationsPerDay[dayIndex][medIndex] = value ?? false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Trinkverhalten nur für Heute (dayIndex == 0)
                    if (dayIndex == 0 && _visibleTodos[dayIndex]['drinking'] == true)
                      Dismissible(
                        key: Key('drinking_$dayIndex'),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            _visibleTodos[dayIndex]['drinking'] = false;
                          });
                        },
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              'Trinkverhalten protokollieren',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            children: <Widget>[
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: List.generate(
                                  4,
                                  (index) => _buildGlassColumn(index),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: List.generate(
                                  4,
                                  (index) => _buildGlassColumn(index + 4),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Text(
                                    'Stand: ${_currentLiters.toStringAsFixed(1)} von 1,6 Litern',
                                    style: Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Memory-Einträge nur für Heute
                    if (dayIndex == 0 && !memoryProvider.isLoading &&
                        memoryProvider.memories.where((memory) => !memory.isArchived).isNotEmpty)
                      ...memoryProvider.memories
                            .where((memory) => !memory.isArchived)
                            .map((memory) => Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            memory.name,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                memory.isArchived
                                                    ? Icons.check_box
                                                    : Icons.check_box_outline_blank,
                                                color: memory.isArchived
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                              onPressed: () {
                                                memoryProvider.toggleMemoryArchived(memory);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                memoryProvider.removeMemory(memory);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                    if (dayIndex != 0 || memoryProvider.isLoading || 
                        memoryProvider.memories.where((memory) => !memory.isArchived).isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Keine Einträge'),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            })..add(const SizedBox(height: 50)),
          ),
        ),
      ),
    );
  }
}
