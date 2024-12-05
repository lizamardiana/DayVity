import 'package:flutter/material.dart';

final _fireAuth = 

class AuthProvider extends ChangeNotifier {
  final form = GlobalKey<FormState>();

  var islogin = true;
  var enteredEmail = '';
  var enteredPassword = '';

  void submit() async {
    final _isvalid = form.currentState!.validate();

    if (!_isvalid) {
      return;
    }

    form.currentState!.save();

    try{
      if(islogin){
        final UserCredential = 
      }elese{

      }
    }

    notifyListeners();
  }
}
