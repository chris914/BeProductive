import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/widgets/priority_chooser.dart';

class AddScreenNotifier extends ChangeNotifier
{
    Priority priority = Priority.Null;

    void changePriority(Priority priority)
    {
        this.priority = priority;
        notifyListeners();
    }
}