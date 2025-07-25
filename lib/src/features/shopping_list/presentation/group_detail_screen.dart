import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/src/data/auth_repository.dart';
import 'package:shopping/src/data/database_repository.dart';
import 'package:shopping/src/features/todo/presentation/todo_screen.dart';
import 'package:shopping/src/features/shopping_list/presentation/shopping_list_screen.dart';
import 'package:shopping/src/features/shopping_list/data/shopping_list_provider.dart';
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
    return ChangeNotifierProvider(
      create: (_) =>
          ShoppingListProvider(widget.databaseRepository, widget.groupId),
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
            HomeScreen(
              widget.databaseRepository,
              widget.authRepository,
              widget.groupId,
              groupName: widget.groupName,
            ),
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
