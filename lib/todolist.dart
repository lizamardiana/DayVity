import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  DateTime? _dueDate;
  bool _isInputVisible = false;
  int? _editingIndex;
  final String userId = 'USER_ID'; // Ganti dengan ID pengguna yang sesuai

  @override
  void initState() {
    super.initState();
    _fetchTodoItems(); // Mengambil data To Do saat halaman dimuat
  }

  void _fetchTodoItems() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('todoItems')
        .where('userId', isEqualTo: userId) // Filter berdasarkan userId
        .get();
    setState(() {
      _todoItems = snapshot.docs.map((doc) {
        return TodoItemData.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  void _addTodoItem() async {
    if (_titleController.text.isNotEmpty) {
      String id = _editingIndex != null
          ? _todoItems[_editingIndex!].id
          : FirebaseFirestore.instance.collection('todoItems').doc().id;

      TodoItemData newItem = TodoItemData(
        id: id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate,
        isChecked: false,
        userId: userId, // Menyimpan userId saat menambah item
      );

      if (_editingIndex != null) {
        await FirebaseFirestore.instance
            .collection('todoItems')
            .doc(id)
            .update(newItem.toMap());
        setState(() {
          _todoItems[_editingIndex!] = newItem;
          _editingIndex = null;
        });
      } else {
        await FirebaseFirestore.instance
            .collection('todoItems')
            .doc(id)
            .set(newItem.toMap());
        setState(() {
          _todoItems.add(newItem);
        });
      }

      _clearInputFields();
    }
  }

  void _clearInputFields() {
    _titleController.clear();
    _descriptionController.clear();
    _dueDate = null;
    _isInputVisible = false;
  }

  void _editTodoItem(int index) {
    setState(() {
      _editingIndex = index;
      _titleController.text = _todoItems[index].title;
      _descriptionController.text = _todoItems[index].description;
      _dueDate = _todoItems[index].dueDate;
      _isInputVisible = true;
    });
  }

  void _deleteTodoItem(String id) async {
    await FirebaseFirestore.instance.collection('todoItems').doc(id).delete();
    setState(() {
      _todoItems.removeWhere((item) => item.id == id);
    });
  }

  Future<void> _selectDueDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
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
                    onDelete: (id) => _deleteTodoItem(id),
                    onToggle: (index, value) {
                      setState(() {
                        _todoItems[index].isChecked =
                            value!; // Memperbarui status
                        FirebaseFirestore.instance
                            .collection('todoItems')
                            .doc(_todoItems[index].id)
                            .update({'isChecked': value});
                      });
                    },
                    onEdit: _editTodoItem,
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
                  ElevatedButton(
                    onPressed: _selectDueDate,
                    child: Text('Select Due Date'),
                  ),
                  if (_dueDate != null)
                    Text(
                      'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.red),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _addTodoItem,
                      child: Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                  _isInputVisible = !_isInputVisible;
                  if (!_isInputVisible) {
                    _clearInputFields();
                  }
                });
              },
              child: Icon(Icons.add, size: 30),
              backgroundColor: Colors.pink,
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
      child: Text(
        'TO DO LIST',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class TodoContainer extends StatelessWidget {
  final List<TodoItemData> todoItems;
  final Function(String) onDelete;
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
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.8,
      child: ListView.builder(
        itemCount: todoItems.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Checkbox(
                value: todoItems[index].isChecked,
                onChanged: (bool? value) {
                  onToggle(index, value);
                },
              ),
              title: Text(
                todoItems[index].title,
                style: TextStyle(
                  decoration: todoItems[index].isChecked
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(todoItems[index].description),
                  if (todoItems[index].dueDate != null)
                    Text(
                      'Due: ${todoItems[index].dueDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      onEdit(index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      onDelete(todoItems[index].id);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TodoItemData {
  String id;
  String title;
  String description;
  DateTime? dueDate;
  bool isChecked; // Tidak lagi final
  String userId;

  TodoItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isChecked = false,
    required this.userId,
  });

  factory TodoItemData.fromMap(Map<String, dynamic> map, String id) {
    return TodoItemData(
      id: id,
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      isChecked: map['isChecked'] ?? false,
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isChecked': isChecked,
      'userId': userId,
    };
  }
}
