import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'diary.dart'; // Import halaman diary
import 'todolist.dart'; // Import halaman todolist
import 'wishlist.dart'; // Import halaman wishlist
import 'package:table_calendar/table_calendar.dart'; // Import table_calendar

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        fontFamily: 'Times New Roman',
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _calendarData;
  bool _isLoadingWeather = true;
  bool _isLoadingCalendar = true;
  String _errorMessage = '';
  late Map<DateTime, List> _holidays; // Data untuk hari libur
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _fetchCalendar();
    _holidays = {}; // Inisialisasi data libur
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  // Fungsi untuk mengambil data cuaca
  Future<void> _fetchWeather() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=Jambi&appid=9c45e44638df92368d84946de974a161'));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoadingWeather = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load weather data';
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load weather data: $e';
        _isLoadingWeather = false;
      });
      print(e);
    }
  }

  // Fungsi untuk mengambil data hari libur dari Calendarific API
  Future<void> _fetchCalendar() async {
    try {
      final response = await http.get(Uri.parse(
          'https://calendarific.com/api/v2/holidays?&api_key=5UHw30oCbhfYCyP3Nyf4vFkpSQenu3U5&country=ID&year=2024'));

      if (response.statusCode == 200) {
        setState(() {
          _calendarData = json.decode(response.body);
          _isLoadingCalendar = false;
          _parseHolidays(); // Parsing data libur
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load calendar data';
          _isLoadingCalendar = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load calendar data: $e';
        _isLoadingCalendar = false;
      });
      print(e);
    }
  }

  // Parsing data libur ke format yang bisa dipakai oleh TableCalendar
  void _parseHolidays() {
    if (_calendarData != null &&
        _calendarData!['response']['holidays'] != null) {
      var holidays = _calendarData!['response']['holidays'];
      setState(() {
        for (var holiday in holidays) {
          DateTime holidayDate = DateTime.parse(holiday['date']['iso']);
          _holidays[holidayDate] = [holiday['name']];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.pink.shade600,
      ),
      drawer: MyDrawer(), // Menambahkan drawer di sini
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
            children: [
              _buildWelcomeText(),
              SizedBox(height: 20),
              _buildLoadingOrErrorMessage(),
              SizedBox(height: 20),
              _buildWeatherAndCalendar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Text(
      'Welcome to Your Personal Organizer',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.pink.shade800,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoadingOrErrorMessage() {
    if (_isLoadingWeather || _isLoadingCalendar) {
      return CircularProgressIndicator();
    } else if (_errorMessage.isNotEmpty) {
      return Text(
        _errorMessage,
        style: TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildWeatherAndCalendar() {
    return Column(
      children: [
        if (_weatherData != null)
          Card(
            margin: EdgeInsets.only(bottom: 20),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors.pink.shade50,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    'Weather in ${_weatherData!['name']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink.shade800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://openweathermap.org/img/wn/${_weatherData!['weather'][0]['icon']}@2x.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${(_weatherData!['main']['temp'] - 273.15).toStringAsFixed(1)}°C',
                        style: TextStyle(
                            fontSize: 20, color: Colors.pink.shade800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                return _holidays[day] ?? [];
              },
              calendarStyle: CalendarStyle(
                selectedTextStyle: TextStyle(color: Colors.white),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Colors.pink.shade800),
                todayDecoration: BoxDecoration(
                  color: Colors.green.shade700,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
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
              color: Colors.pink.shade600,
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
            leading: Icon(Icons.list),
            title: Text('To-Do List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TodoListPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Wishlist'), // Menambahkan item Wishlist
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WishlistPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
