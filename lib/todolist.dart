import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.pink,
      ),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<TodoItemData> _todoItems = [];
  final TextEditingController _controller = TextEditingController();

  void _addTodoItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _todoItems.add(TodoItemData(title: _controller.text, isChecked: false));
        _controller.clear();
      });
    }
  }

  void _editTodoItem(int index) {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _todoItems[index].title = _controller.text;
        _controller.clear();
      });
    }
  }

  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
  }

  void _toggleCheckbox(int index, bool? value) {
    setState(() {
      _todoItems[index].isChecked = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.shade100,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Header(),
            Expanded(
              child: TodoContainer(
                todoItems: _todoItems,
                onDelete: _deleteTodoItem,
                onToggle: _toggleCheckbox,
                onEdit: _editTodoItem,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Add a new task',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addTodoItem,
                    color: Colors.pink,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.shade300,
            Colors.pink.shade100,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Logo(),
          BackDate(),
        ],
      ),
    );
  }
}

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('images/v7_116.png', width: 100),
        SizedBox(width: 10),
        Text(
          'TO DO LIST',
          style: TextStyle(
            fontSize: 24, // Ukuran font lebih kecil
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class BackDate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Kembali ke halaman sebelumnya
        Navigator.pop(context);
      },
      child: Icon(
        Icons.arrow_back, // Menggunakan ikon panah kembali
        size: 30,
        color: Colors.white,
      ),
    );
  }
}

class TodoContainer extends StatelessWidget {
  final List<TodoItemData> todoItems;
  final Function(int) onDelete;
  final Function(int, bool?) onToggle;
  final Function(int) onEdit;

  TodoContainer({
    required this.todoItems,
    required this.onDelete,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.95 * MediaQuery.of(context).size.width,
      height: 0.8 * MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: todoItems.length,
          itemBuilder: (context, index) {
            return TodoItem(
              todoItem: todoItems[index],
              onDelete: () => onDelete(index),
              onToggle: (value) => onToggle(index, value),
              onEdit: () {
                // Set the text field with the current item title for editing
                // This can be implemented with a dialog or another method
              },
            );
          },
        ),
      ),
    );
  }
}

class TodoItemData {
  String title;
  bool isChecked;

  TodoItemData({required this.title, this.isChecked = false});
}

class TodoItem extends StatelessWidget {
  final TodoItemData todoItem;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;

  TodoItem({
    required this.todoItem,
    required this.onDelete,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.pink.shade200,
        borderRadius: BorderRadius.circular(5),
        border: Border(bottom: BorderSide(color: Colors.pink.shade100)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: todoItem.isChecked,
            onChanged: onToggle,
          ),
          Expanded(
            child: Text(
              todoItem.title,
              style: TextStyle(
                decoration:
                    todoItem.isChecked ? TextDecoration.lineThrough : null,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
