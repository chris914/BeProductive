import 'package:flutter/material.dart';

class NavigationNotifier extends ChangeNotifier
{
  bool isUpdateRequired = false;
  String targetScreen = "";
  Object? data;

  void sendData(String targetScreen, Object data)
  {
    this.targetScreen = targetScreen;
    this.data = data;
    isUpdateRequired = true;

    notifyListeners();
  }

  Object consumeData()
  {
    isUpdateRequired = false;
    targetScreen = "";
    return data!;
  }
}