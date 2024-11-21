import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

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
  List<DiaryEntry> _diaryEntries = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = '';
  int? _editingIndex;
  bool _isInputVisible = false;

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

  void _addOrUpdateDiaryEntry() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        if (_editingIndex == null) {
          _diaryEntries.add(DiaryEntry(
            title: _titleController.text,
            date: DateTime.now(),
            media: [],
            tags: _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .toList(),
            mood: _selectedMood,
            content: _contentController.text,
          ));
        } else {
          // Update the existing entry
          _diaryEntries[_editingIndex!] = DiaryEntry(
            title: _titleController.text,
            date: _diaryEntries[_editingIndex!].date, // Keep the original date
            media: [],
            tags: _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .toList(),
            mood: _selectedMood,
            content: _contentController.text,
          );
          _editingIndex = null; // Reset editing index
        }

        // Clear input fields
        _titleController.clear();
        _tagsController.clear();
        _contentController.clear();
        _selectedMood = '';
        _isInputVisible =
            false; // Hide input fields after adding/updating entry
      });
    }
  }

  void _deleteDiaryEntry(int index) {
    setState(() {
      _diaryEntries.removeAt(index);
    });
  }

  void _setEditMode(int index) {
    setState(() {
      _editingIndex = index;
      _titleController.text = _diaryEntries[index].title;
      _selectedMood = _diaryEntries[index].mood;
      _tagsController.text = _diaryEntries[index].tags.join(', ');
      _contentController.text = _diaryEntries[index].content;
      _isInputVisible = true; // Show input fields when in edit mode
    });
  }

  int _countWords(String text) {
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
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
                                  onPressed: () => _setEditMode(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteDiaryEntry(index),
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
                                              fontSize: 24,
                                            ),
                                          ),
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
              if (_isInputVisible) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(maxHeight: 100),
                          child: TextField(
                            controller: _titleController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add a new diary entry title',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onChanged: (text) {
                              if (_countWords(text) > 25) {
                                // Limit to 25 words
                                _titleController.text =
                                    text.split(' ').take(25).join(' ');
                                _titleController.selection =
                                    TextSelection.fromPosition(TextPosition(
                                        offset: _titleController.text.length));
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(maxHeight: 100),
                          child: TextField(
                            controller: _contentController,
                            maxLines: 3,
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
                    ],
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
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMood = newValue ?? '';
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _addOrUpdateDiaryEntry,
                    child: Text(
                        _editingIndex == null ? "Add Entry" : "Update Entry",
                        style: TextStyle(color: Colors.white)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isInputVisible = !_isInputVisible; // Toggle visibility
            if (_isInputVisible) {
              _editingIndex = null; // Reset editing index when showing input
              _titleController.clear();
              _tagsController.clear();
              _contentController.clear();
              _selectedMood = '';
            }
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}

class DiaryEntry {
  String title;
  DateTime date;
  List<String> media;
  List<String> tags;
  String mood;
  String content;

  DiaryEntry({
    required this.title,
    required this.date,
    required this.media,
    required this.tags,
    required this.mood,
    required this.content,
  });
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
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
        Image.asset('images/v1_3.png', width: 50),
        SizedBox(width: 10),
        Text(
          'DIARY',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class BackDate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            size: 30,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
