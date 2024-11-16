import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'diary.dart'; // Import halaman diary
import 'todolist.dart'; // Import halaman todolist

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        fontFamily: 'Poppins',
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
  Map<String, dynamic>? _weatherData; // Ubah menjadi nullable
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=Jambi&appid=9c45e44638df92368d84946de974a161'));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load weather data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load weather data: $e';
        _isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
      ),
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Welcome to Your Personal Organizer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Manage your tasks and diary entries easily.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            if (_isLoading)
              CircularProgressIndicator() // Tampilkan loading saat mengambil data
            else if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              )
            else
              _buildWeatherInfo(), // Memanggil fungsi untuk membangun informasi cuaca
            SizedBox(height: 20),
            _buildButton(
              context,
              'Open Diary',
              Icons.book,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiaryPage()),
                );
              },
            ),
            SizedBox(height: 20),
            _buildButton(
              context,
              'Open To-Do List',
              Icons.list,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TodoListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    return Column(
      children: [
        Text(
          'City: ${_weatherData?['name'] ?? 'Unknown'}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pastikan URL ikon cuaca dibangun dengan benar
            Image.network(
              'https://openweathermap.org/img/wn/${_weatherData?['weather'][0]['icon']}@2x.png',
              width: 50,
              height: 50,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Icon(Icons.error,
                    size: 50,
                    color:
                        Colors.red); // Tampilkan ikon error jika gagal memuat
              },
            ),
            SizedBox(width: 10),
            Text(
              'Temperature: ${(_weatherData?['main']['temp'] - 273.15).toStringAsFixed(1)}°C',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }

  ElevatedButton _buildButton(BuildContext context, String title, IconData icon,
      VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
