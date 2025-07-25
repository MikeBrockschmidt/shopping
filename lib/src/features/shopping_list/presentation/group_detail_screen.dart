import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/src/data/auth_repository.dart';
import 'package:shopping/src/data/database_repository.dart';
import 'package:shopping/src/features/memory/presentation/memory_provider.dart';
import 'package:shopping/src/features/todo/presentation/todo_screen.dart';
import 'package:shopping/src/features/shopping_list/presentation/shopping_list_screen.dart';
import 'package:shopping/src/features/shopping_list/data/shopping_list_provider.dart';
import 'package:shopping/src/features/memory/presentation/memory_screen.dart';
import 'package:shopping/src/theme/theme_provider.dart';

class GroupDetailScreen extends StatefulWidget {
  final DatabaseRepository databaseRepository;
  final AuthRepository authRepository;
  final String groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.databaseRepository,
    required this.authRepository,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              ShoppingListProvider(widget.databaseRepository, widget.groupId),
        ),
        ChangeNotifierProvider(
          // MemoryProvider hinzufügen
          create: (_) =>
              MemoryProvider(widget.databaseRepository, widget.groupId),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.groupName),
          actions: [
            IconButton(
              icon: Icon(
                context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                context.read<ThemeProvider>().toggleTheme(
                  context.read<ThemeProvider>().themeMode != ThemeMode.dark,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await widget.authRepository.signOut();
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            TodoScreen(
              widget.databaseRepository,
              widget.authRepository,
              widget.groupId,
              groupName: widget.groupName,
            ),
            MemoryScreen(groupId: widget.groupId), // MemoryScreen einfügen
            ShoppingListScreen(groupId: widget.groupId),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              label: 'To-Dos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_bookmark), // Icon für Memory
              label: 'Memory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Einkaufsliste',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
