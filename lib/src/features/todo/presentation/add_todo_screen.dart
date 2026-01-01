import 'package:flutter/material.dart';
import 'package:shopping/src/data/database_repository.dart';
import 'package:shopping/src/features/todo/domain/todo.dart';
import 'package:shopping/src/features/todo/presentation/icon_picker.dart';
import 'package:shopping/src/features/todo/presentation/widgets/color_slider.dart';
import 'package:shopping/src/features/todo/presentation/widgets/priority_slider.dart';
import 'package:shopping/src/common/date_formats.dart';

class AddTodoScreen extends StatefulWidget {
  final DatabaseRepository db;
  final void Function() onTodoAdded;
  final String groupId;

  const AddTodoScreen(
    this.db, {
    super.key,
    required this.onTodoAdded,
    required this.groupId,
  });

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  Color _selectedColor = Colors.red;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Priority _selectedPriority = Priority.medium;
  bool _isLoading = false;
  TodoIcon _selectedIcon = TodoIcon.values.first;
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  List<String> _suggestions = [];
  late FocusNode _titleFocusNode;

  @override
  void initState() {
    super.initState();
    _titleFocusNode = FocusNode();
    _titleController.addListener(_updateSuggestions);
    _titleFocusNode.addListener(() {
      if (!_titleFocusNode.hasFocus) {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  void _updateSuggestions() async {
    if (!mounted) return;
    final suggestions = await widget.db.getSuggestedTitles(widget.groupId, _titleController.text);
    if (mounted) {
      setState(() {
        _suggestions = suggestions;
      });
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateSuggestions);
    _titleFocusNode.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: _selectedColor)),
      child: Scaffold(
        appBar: AppBar(title: Text('Neues Todo')),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 16,
                children: [
                  TextFormField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    decoration: InputDecoration(
                      labelText: "Titel",
                      hintText: "Titel eingeben",
                    ),
                  ),
                  if (_suggestions.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: _suggestions.map((suggestion) {
                          return Material(
                            child: InkWell(
                              onTap: () {
                                _titleController.text = suggestion;
                                setState(() {
                                  _suggestions = [];
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.history, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(suggestion)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    onTap: () {
                      setState(() {
                        _suggestions = [];
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Beschreibung",
                      hintText: "Beschreibung eingeben",
                    ),
                  ),
                  PrioritySlider(
                    onPriorityChanged: (p) {
                      _selectedPriority = p;
                    },
                  ),
                  IconPicker(
                    onIconChanged: (icon) {
                      _selectedIcon = icon;
                    },
                  ),
                  ColorSlider(
                    onColorSelected: (color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                  ),
                  Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final DateTime? newDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              Duration(days: 365 * 100),
                            ),
                          );
                          if (newDate != null) {
                            setState(() {
                              _selectedDate = newDate;
                            });
                          }
                        },
                        child: Text(
                          "Fällig am: ${_selectedDate.longDateString}",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final Todo todo = Todo(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                groupId: widget.groupId,
                                title: _titleController.text,
                                description: _descriptionController.text,
                                priority: _selectedPriority,
                                color: _selectedColor,
                                isDone: false,
                                dueDate: _selectedDate,
                                icon: _selectedIcon,
                              );

                              setState(() {
                                _isLoading = true;
                              });
                              
                              try {
                                await widget.db.createTodo(todo.groupId, todo);
                                
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  widget.onTodoAdded();
                                }
                              } catch (e) {
                                setState(() {
                                  _isLoading = false;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Fehler beim Erstellen: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      child: Text("Todo erstellen"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
