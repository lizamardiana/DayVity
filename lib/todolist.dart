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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPriority = 'Normal';
  DateTime? _dueDate;
  bool _isInputVisible = false; // Variabel untuk mengontrol visibilitas input
  int? _editingIndex; // Menyimpan index dari item yang sedang diedit

  void _addTodoItem() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        if (_editingIndex != null) {
          // Update existing item
          _todoItems[_editingIndex!] = TodoItemData(
            title: _titleController.text,
            description: _descriptionController.text,
            priority: _selectedPriority,
            dueDate: _dueDate,
            isChecked: false,
          );
          _editingIndex = null; // Reset editing index
        } else {
          // Add new item
          _todoItems.add(TodoItemData(
            title: _titleController.text,
            description: _descriptionController.text,
            priority: _selectedPriority,
            dueDate: _dueDate, // Pastikan dueDate ditambahkan di sini
            isChecked: false,
          ));
        }
        _sortTodoItems(); // Panggil metode untuk mengurutkan
        _titleController.clear();
        _descriptionController.clear();
        _selectedPriority = 'Normal';
        _dueDate = null;
        _isInputVisible = false; // Sembunyikan input setelah menambahkan item
      });
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _editTodoItem(int index) {
    setState(() {
      _editingIndex = index; // Set index untuk item yang sedang diedit
      _titleController.text = _todoItems[index].title; // Isi title
      _descriptionController.text =
          _todoItems[index].description; // Isi deskripsi
      _selectedPriority = _todoItems[index].priority; // Isi priority
      _dueDate = _todoItems[index].dueDate; // Isi due date
      _isInputVisible = true; // Tampilkan input
    });
  }

  void _sortTodoItems() {
    _todoItems.sort((a, b) {
      // Urutkan berdasarkan prioritas
      int priorityComparison = _comparePriority(a.priority, b.priority);
      if (priorityComparison != 0) {
        return priorityComparison;
      }
      // Jika prioritas sama, urutkan berdasarkan tanggal jatuh tempo
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1; // a lebih rendah jika tidak ada due date
      if (b.dueDate == null)
        return -1; // b lebih rendah jika tidak ada due date
      return a.dueDate!.compareTo(b.dueDate!);
    });
  }

  int _comparePriority(String priorityA, String priorityB) {
    const priorities = ['High', 'Medium', 'Low', 'Normal'];
    return priorities
        .indexOf(priorityA)
        .compareTo(priorities.indexOf(priorityB));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                    onDelete: (index) => setState(() {
                      _todoItems.removeAt(index);
                    }),
                    onToggle: (index, value) {
                      setState(() {
                        _todoItems[index].isChecked = value!;
                      });
                    },
                    onEdit: _editTodoItem, // Pass edit function
                  ),
                ),
                if (_isInputVisible) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Add a new task title',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Add a description',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedPriority,
                    items: <String>['High', 'Medium', 'Low', 'Normal']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPriority = newValue!;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDueDate(context),
                    child: Text('Select Due Date'),
                  ),
                  if (_dueDate != null)
                    Text(
                      'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 10),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isInputVisible =
                      true; // Tampilkan input ketika tombol tambah ditekan
                });
              },
              child: Icon(Icons.add, size: 30),
              backgroundColor: Colors.pink,
            ),
          ),
          if (_isInputVisible)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                onPressed: _addTodoItem,
                child: Icon(Icons.check, size: 30),
                backgroundColor: Colors.green,
              ),
            ),
        ],
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
            fontSize: 24,
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
        Navigator.pop(context);
      },
      child: Icon(
        Icons.arrow_back,
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
              onEdit: () => onEdit(index), // Call edit function
            );
          },
        ),
      ),
    );
  }
}

class TodoItemData {
  String title;
  String description;
  String priority;
  DateTime? dueDate;
  bool isChecked;

  TodoItemData({
    required this.title,
    this.description = '',
    this.priority = 'Normal',
    this.dueDate,
    this.isChecked = false,
  });
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todoItem.title,
                  style: TextStyle(
                    decoration:
                        todoItem.isChecked ? TextDecoration.lineThrough : null,
                    color: Colors.black,
                  ),
                ),
                if (todoItem.description.isNotEmpty)
                  Text(
                    todoItem.description,
                    style: TextStyle(color: Colors.black54),
                  ),
                if (todoItem.dueDate != null)
                  Text(
                    'Due: ${todoItem.dueDate!.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
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
