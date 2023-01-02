import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/widgets/priority_chooser.dart';

const Color UrgentImportantColor = Color.fromRGBO(200, 0, 0, 1);
const Color NotUrgentImportantColor = Colors.blue;
Color UrgentNotImportantColor = Colors.yellow.shade800;
const Color NotUrgentNotImportantColor = Colors.green;

Color getColor(Priority priority)
{
  if (priority == Priority.UrgentImportant)
    return UrgentImportantColor;
  if (priority == Priority.UrgentNotImportant)
    return UrgentNotImportantColor;
  if (priority == Priority.NotUrgentImportant)
    return NotUrgentImportantColor;
  if (priority == Priority.NotUrgentNotImportant)
    return NotUrgentNotImportantColor;

  else
    return Colors.transparent;
}

Map<String, String> InfoMap =  {
  "Challenges" : "Your challenges are listed here. Each challenge requires You to do various things in the application, like completing To-Do's. Earning them yields with challenge points."
};