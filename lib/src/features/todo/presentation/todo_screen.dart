import 'package:flutter/material.dart';
import 'package:shopping/src/data/auth_repository.dart';
import 'package:shopping/src/data/database_repository.dart';
import 'package:shopping/src/features/todo/domain/todo.dart';
import 'package:shopping/src/features/todo/presentation/add_todo_screen.dart';
import 'package:shopping/src/features/todo/presentation/widgets/todo_card.dart';
import 'package:shopping/src/theme/palette.dart';

class HomeScreen extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final String groupId;
  final String groupName;

  const HomeScreen(
    this.db,
    this.auth,
    this.groupId, {
    super.key,
    required this.groupName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Todo>>? _myTodos;

  @override
  void initState() {
    super.initState();
    _myTodos = widget.db.getTodos(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final String backgroundImage = isDarkMode
        ? 'assets/images/calendar_d.jpg'
        : 'assets/images/calendar.jpg';

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            image: DecorationImage(
              image: AssetImage(backgroundImage),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(children: []),
          ),
        ),
        toolbarHeight: 200,
        shadowColor: Theme.of(context).colorScheme.primary,
        elevation: 16,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTodoScreen(
                widget.db,
                onTodoAdded: () {
                  setState(() {
                    _myTodos = widget.db.getTodos(widget.groupId);
                  });
                },
                groupId: widget.groupId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: FutureBuilder(
          future: _myTodos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("Fehler: ${snapshot.error}");
              } else if (snapshot.hasData) {
                List<Todo> myTodos = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: myTodos.length,
                  itemBuilder: (context, index) {
                    final Todo todo = myTodos[index];
                    return Dismissible(
                      key: Key(todo.id),
                      secondaryBackground: Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.centerRight,
                        color: Palette.green,
                        child: const Icon(Icons.check),
                      ),
                      background: Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.centerLeft,
                        color: Theme.of(context).colorScheme.error,
                        child: const Icon(Icons.undo),
                      ),
                      child: TodoCard(
                        title: todo.title,
                        subTitle: todo.description,
                        icon: todo.icon.icon,
                        color: todo.color,
                        priority: todo.priority,
                        isDone: todo.isDone,
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          await widget.db.uncheckTodo(widget.groupId, todo.id);
                        } else if (direction == DismissDirection.endToStart) {
                          await widget.db.checkTodo(widget.groupId, todo.id);
                        }
                        setState(() {});

                        return false;
                      },
                    );
                  },
                );
              }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Container();
          },
        ),
      ),
    );
  }
}
