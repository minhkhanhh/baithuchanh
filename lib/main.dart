import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<String> _todoList = [];
  TextEditingController _todoController = TextEditingController();
  late File _todoFile;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // Lấy đường dẫn tới file lưu công việc
  Future<File> _getTodoFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/todos.txt');
  }

  // Đọc công việc từ file
  Future<void> _loadTodos() async {
    try {
      _todoFile = await _getTodoFile();
      if (await _todoFile.exists()) {
        String contents = await _todoFile.readAsString();
        setState(() {
          _todoList = contents.split('\n').where((item) => item.isNotEmpty).toList();
        });
      }
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  // Lưu công việc vào file
  Future<void> _saveTodos() async {
    String contents = _todoList.join('\n');
    await _todoFile.writeAsString(contents);
  }

  // Thêm công việc mới
  void _addTodo() {
    if (_todoController.text.isNotEmpty) {
      setState(() {
        _todoList.add(_todoController.text);
        _todoController.clear();
      });
      _saveTodos();
    }
  }

  // Xóa công việc
  void _deleteTodoAt(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
    _saveTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _todoController,
              decoration: InputDecoration(
                labelText: 'Enter a new task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addTodo,
            child: Text('Add Task'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todoList[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTodoAt(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
