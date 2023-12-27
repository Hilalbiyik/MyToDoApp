import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_to_do_app/constants/colors.dart';
import 'package:my_to_do_app/src/models/to_do_model.dart';
import 'package:my_to_do_app/src/services/hive_service.dart';

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final List<_TodoItem> todosList = [];
  List<_TodoItem> _foundTodos = [];
   late final Box<TodoModel> box;
  bool boxLoaded = false;
  final TextEditingController _todoController = TextEditingController();

  initLocalDb() async {
    final result = await HiveService.initService();
    print(result);
    box = await HiveService.openBox<TodoModel>();
    setState(() {
      boxLoaded = true;
    });
  }

  @override
  void initState() {
    _foundTodos = todosList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: Column(
              children: [
                _buildSearchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                        ),
                        child: Text(
                          'All To Do List',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (_TodoItem todo in _foundTodos.reversed)
                        _buildTodoItem(todo),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                      left: 20,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      
                      controller: _todoController,
                      decoration: InputDecoration(
                        hintText: 'Add a new todo item',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                    onPressed: () {
                      _addToDoItem(_todoController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      minimumSize: Size(60, 60),
                      elevation: 10,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontSize: 40,
                      ),
                    ),
                    onPressed: () {
                      _deleteSelectedTodos();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      minimumSize: Size(60, 60),
                      elevation: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTodoChange(_TodoItem todo) {
    setState(() {
      todo.isChecked = !todo.isChecked;
    });
  }

  void _deleteTodoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
      _foundTodos = todosList;
    });
  }

  void _addToDoItem(String title) {
    setState(() {
      todosList.add(_TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
      ));
      _foundTodos = todosList;
    });
    _todoController.clear();
  }

  void _editTodoItem(_TodoItem todo) {
    _todoController.text = todo.title;
    _showEditDialog(todo);
  }

  void _runFilter(String enteredKeyword) {
    List<_TodoItem> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.title
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundTodos = results;
    });
  }

  Widget _buildSearchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Todo App'),
    );
  }

  Widget _buildTodoItem(_TodoItem todo) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: todo.isChecked
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        trailing: Checkbox(
          value: todo.isChecked,
          onChanged: (value) {
            _handleTodoChange(todo);
          },
        ),
        onLongPress: () {
          _deleteTodoItem(todo.id);
        },
        onTap: () {
          _editTodoItem(todo);
        },
      ),
    );
  }

  Future<void> _showEditDialog(_TodoItem todo) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Todo'),
          content: TextField(
            controller: _todoController,
            decoration: InputDecoration(hintText: 'Edit todo item'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateTodoItem(todo);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateTodoItem(_TodoItem todo) {
    setState(() {
      todo.title = _todoController.text;
    });
    _todoController.clear();
  }

  
  void _deleteSelectedTodos() {
    List<_TodoItem> selectedTodos =
        _foundTodos.where((todo) => todo.isChecked).toList();

    setState(() {
      todosList.removeWhere((todo) => todo.isChecked);
      _foundTodos = todosList;
    });

    // Optional: Perform additional actions with selected todos
    for (var todo in selectedTodos) {
      print('Deleted todo: ${todo.title}');
    }
  }
}
class _TodoItem {
  final String id;
  String title;
  bool isChecked;

  _TodoItem({
    required this.id,
    required this.title,
    this.isChecked = false,
  });
}