import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart'; // Halaman diary
import 'todolist.dart'; // Halaman todolist
import 'wishlist.dart'; // Halaman wishlist
import 'settings.dart'; // Halaman settings
import 'main.dart'; // Halaman login

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.pink,
      ),
      home: DiaryPage(),
    );
  }
}

class DiaryPage extends StatefulWidget {
  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  List<DiaryEntry> _diaryEntries = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = '';
  String? _editingId;

  final List<String> _moods = [
    '😊',
    '😢',
    '😠',
    '😮',
    '😍',
    '😎',
    '😌',
    '😴',
    '😕'
  ];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchDiaryEntries();
  }

  Future<void> _fetchDiaryEntries() async {
    if (_user != null) {
      final snapshot = await _firestore
          .collection('diaries')
          .where('userId', isEqualTo: _user!.uid)
          .get();

      setState(() {
        _diaryEntries = snapshot.docs.map((doc) {
          return DiaryEntry.fromDocument(doc);
        }).toList();
      });
    }
  }

  Future<void> _addOrUpdateDiaryEntry() async {
    if (_titleController.text.isNotEmpty) {
      if (_editingId == null) {
        // Add new entry
        await _firestore.collection('diaries').add({
          'title': _titleController.text,
          'date': DateTime.now(),
          'media': [],
          'tags': [],
          'mood': _selectedMood,
          'content': _contentController.text,
          'userId': _user!.uid,
        });
      } else {
        // Update existing entry
        await _firestore.collection('diaries').doc(_editingId).update({
          'title': _titleController.text,
          'mood': _selectedMood,
          'content': _contentController.text,
        });
        _editingId = null; // Reset editing ID
      }

      // Clear input fields
      _titleController.clear();
      _contentController.clear();
      _selectedMood = '';

      // Refresh diary entries
      _fetchDiaryEntries();
    }
  }

  Future<void> _deleteDiaryEntry(String id) async {
    await _firestore.collection('diaries').doc(id).delete();
    _fetchDiaryEntries();
  }

  void _setEditMode(DiaryEntry entry) {
    setState(() {
      _editingId = entry.id;
      _titleController.text = entry.title;
      _selectedMood = entry.mood;
      _contentController.text = entry.content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary'),
        centerTitle: true,
        backgroundColor: Colors.pink.shade600,
      ),
      drawer: MyDrawer(), // Panggil drawer di sini
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade100, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _diaryEntries.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(_diaryEntries[index].title),
                            subtitle: Text(
                              "${_diaryEntries[index].date.day}/${_diaryEntries[index].date.month}/${_diaryEntries[index].date.year}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () =>
                                      _setEditMode(_diaryEntries[index]),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteDiaryEntry(
                                      _diaryEntries[index].id),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _diaryEntries[index].content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Diary Entry"),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "Title: ${_diaryEntries[index].title}"),
                                          SizedBox(height: 10),
                                          Text(
                                              "Date: ${_diaryEntries[index].date.day}/${_diaryEntries[index].date.month}/${_diaryEntries[index].date.year}"),
                                          SizedBox(height: 10),
                                          Text(
                                              "Mood: ${_diaryEntries[index].mood}",
                                              style: TextStyle(
                                                  fontFamily: 'NotoColorEmoji',
                                                  fontSize: 24)),
                                          Text(
                                              "Content: ${_diaryEntries[index].content}"),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Close"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text("Lihat Selengkapnya"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Add a new diary entry title',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _contentController,
                  maxLines: 3,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Write your diary content here',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
            DropdownButton<String>(
              value: _selectedMood.isEmpty ? null : _selectedMood,
              hint: Text("Choose your mood"),
              items: _moods.map((String mood) {
                return DropdownMenuItem<String>(
                  value: mood,
                  child: Text(
                    mood,
                    style: TextStyle(
                      fontFamily: 'NotoColorEmoji',
                      fontSize: 24,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMood = value!;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addOrUpdateDiaryEntry,
            ),
          ],
        ),
      ),
    );
  }
}

class DiaryEntry {
  final String id;
  final String title;
  final DateTime date;
  final String mood;
  final String content;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.mood,
    required this.content,
  });

  factory DiaryEntry.fromDocument(DocumentSnapshot doc) {
    return DiaryEntry(
      id: doc.id,
      title: doc['title'],
      date: (doc['date'] as Timestamp).toDate(),
      mood: doc['mood'],
      content: doc['content'],
    );
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        // Menambahkan widget Center
        child: Text(
          'Welcome Your Diary',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.pink,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Diary'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiaryPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.checklist),
            title: Text('To-do List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TodoListPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Wish List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishlistPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
