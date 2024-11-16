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
  final TextEditingController _controller = TextEditingController();
  int? _editingIndex; // Menyimpan indeks entri yang sedang diedit

  void _addDiaryEntry() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        if (_editingIndex == null) {
          // Jika tidak dalam mode edit, tambahkan entri baru
          _diaryEntries.add(DiaryEntry(
            title: _controller.text,
            date: DateTime.now(),
          ));
        } else {
          // Jika dalam mode edit, perbarui entri yang ada
          _diaryEntries[_editingIndex!].title = _controller.text;
          _editingIndex = null; // Reset mode edit
        }
        _controller.clear();
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
      _editingIndex = index; // Set indeks entri yang sedang diedit
      _controller.text =
          _diaryEntries[index].title; // Isi TextField dengan entri yang ada
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            Expanded(
              child: ListView.builder(
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
                                  icon: Icon(Icons.edit,
                                      color: Colors
                                          .black), // Warna ikon edit diubah menjadi hitam
                                  onPressed: () => _setEditMode(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteDiaryEntry(index),
                                ),
                              ],
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
                                      child: Text(_diaryEntries[index].title),
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null, // Allow multiline input
                      decoration: InputDecoration(
                        hintText: 'Add a new diary entry',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onSubmitted: (value) {
                        _addDiaryEntry();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addDiaryEntry,
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

class DiaryEntry {
  String title;
  DateTime date;

  DiaryEntry({required this.title, required this.date});
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
        Image.asset('images/v1_3.png', width: 50), // Ukuran logo
        SizedBox(width: 10),
        Text(
          'DIARY',
          style: TextStyle(
            fontSize: 40, // Ukuran font
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
            // Navigasi ke halaman dashboard
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back, // Menggunakan ikon panah kembali
            size: 30,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
