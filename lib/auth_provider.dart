import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final _fireAuth = FirebaseAuth.instance;
  final form = GlobalKey<FormState>();

  var isLogin = false; // Ubah ini menjadi false untuk pendaftaran
  var enteredEmail = '';
  var enteredPassword = '';

  Future<bool> submit(Function(String) showSnackBar) async {
    final _isValid = form.currentState!.validate();

    if (!_isValid) {
      return false; // Jika form tidak valid, kembalikan false
    }

    form.currentState!.save();

    try {
      if (isLogin) {
        await login(enteredEmail, enteredPassword);
        // Arahkan ke Dashboard setelah login
        return true; // Login berhasil
      } else {
        await register(enteredEmail, enteredPassword);
        // Arahkan ke Dashboard setelah pendaftaran
        return true; // Pendaftaran berhasil
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          showSnackBar("Email already in use"); // Panggil showSnackBar
        } else {
          showSnackBar("Error: ${e.message}"); // Panggil showSnackBar
        }
      } else {
        showSnackBar("Error: $e"); // Panggil showSnackBar
      }
      return false; // Pendaftaran/login gagal
    }
  }

  Future<void> login(String email, String password) async {
    await _fireAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> register(String email, String password) async {
    await _fireAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
