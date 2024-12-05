import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Impor Firebase Core
import 'firebase_options.dart'; // Impor file konfigurasi Firebase yang dihasilkan
import 'register.dart';
import 'auth_provider.dart'; // Impor AuthProvider
import 'package:provider/provider.dart'; // Impor provider
import 'dashboard.dart'; // Impor halaman dashboard

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Memastikan binding telah diinisialisasi
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Inisialisasi Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(), // Menambahkan AuthProvider
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/', // Halaman awal
        routes: {
          '/': (context) => LoginPage(), // Rute untuk halaman login
          '/dashboard': (context) =>
              DashboardPage(), // Rute untuk halaman dashboard
        },
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context); // Ambil instance AuthProvider

    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Container(
            color: Colors.white,
          ),
          // Main Content
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 400,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        color: Colors.pink[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 11),
                    Text(
                      "Please enter your credentials to login.",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 64),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.pink[50],
                          ),
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 17),
                              hintText:
                                  'Enter your email', // Hint text untuk email
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.pink[50],
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 17),
                              suffixIcon: Icon(Icons.visibility_off),
                              hintText:
                                  'Enter your password', // Hint text untuk password
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[600],
                        ),
                        onPressed: () async {
                          String email = emailController.text;
                          String password = passwordController.text;

                          try {
                            await authProvider.login(email, password);
                            Navigator.pushReplacementNamed(
                                context, '/dashboard');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: Text(
                          "LOGIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account yet? ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()),
                            );
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.pink[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
