import 'package:flutter/material.dart';

class PomodoroNotifier extends ChangeNotifier
{
  bool isRunning = false;

  void changeIsRunning(bool value)
  {
    this.isRunning = value;
    notifyListeners();
  }
}