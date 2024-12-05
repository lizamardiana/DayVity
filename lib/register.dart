import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Impor provider
import 'auth_provider.dart'; // Impor AuthProvider
import 'dashboard.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context); // Mendapatkan instance AuthProvider

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
                      "Create Account",
                      style: TextStyle(
                        color: Colors.pink[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 11),
                    Text(
                      "Please fill in the details below to create an account.",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    Form(
                      key: authProvider.form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Email Input
                          Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              authProvider.enteredEmail =
                                  value; // Menyimpan email
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.pink[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "example@gmail.com",
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.6),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 17),
                            ),
                          ),
                          SizedBox(height: 15),
                          // Password Input
                          Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            obscureText: true,
                            onChanged: (value) {
                              authProvider.enteredPassword =
                                  value; // Meny impan password
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.pink[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 17),
                              suffixIcon: Icon(Icons.visibility_off),
                            ),
                          ),
                        ],
                      ),
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
                          if (authProvider.form.currentState!.validate()) {
                            final success =
                                await authProvider.submit((message) {
                              showSnackBar(context, message);
                            });
                            if (success) {
                              // Navigasi ke halaman dashboard setelah pendaftaran berhasil
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DashboardPage()));
                            }
                          }
                        },
                        child: Text(
                          "REGISTER",
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
                          "Already have an account? ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigasi kembali ke halaman login
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Login",
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

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
