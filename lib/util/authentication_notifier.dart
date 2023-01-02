import 'package:flutter/material.dart';

class AuthenticationNotifier extends ChangeNotifier
{
  bool isAuthenticated = false;

  void changeIsAuthenticated(bool value)
  {
    print("=======auth========" + value.toString());
    this.isAuthenticated = value;
    notifyListeners();
  }
}