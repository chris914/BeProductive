import 'package:flutter_timemanagement/data/todo.dart';

class NavigationHelper
{
  static void Function(Todo)? jumpToPomodoroScreenFunction;

  static void jumpToPomodoroScreen(Todo todo){
    if (jumpToPomodoroScreenFunction != null)
      jumpToPomodoroScreenFunction!(todo);
  }
}