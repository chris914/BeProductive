import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/widgets/priority_chooser.dart';

class Todo {
  final String documentId;
  final String title;
  final String content;
  Priority priority;
  final Timestamp? timestamp;
  final IconData? iconData;
  bool isDone;
  String goalName;

  Todo(this.documentId, this.title, this.content, this.isDone, this.timestamp, this.priority, this.iconData, this.goalName);

  static Todo fromJson(Map<String, dynamic> json, String documentId) {
      var prio = stringToPriority(json['priority'].toString());
      IconData? iconData;
      if (json['icon'] != null)
      {
        var icon = json['icon'];
        var codePoint = icon['codePoint'];
        var font = icon['font'];
        var fontPackage = icon['fontPackage'];
        iconData = IconData(codePoint, fontFamily: font, fontPackage: fontPackage);
      }

      var goalName = json.containsKey('goalName') ? json['goalName'] : "";

      return Todo(documentId, json['title'] ?? "", json['content'], json['isDone'], json['timestamp'], prio, iconData, goalName);
    }

  static Priority stringToPriority(String prio) {
      var priority = Priority.Null;
      if (prio == 'IU')
        priority = Priority.UrgentImportant;
      if (prio == 'INU')
        priority = Priority.NotUrgentImportant;
      if (prio == 'NIU')
        priority = Priority.UrgentNotImportant;
      if (prio == 'NINU')
        priority = Priority.NotUrgentNotImportant;

      return priority;
  }

  static String priorityToString(Priority priority) {
    if (priority == Priority.UrgentImportant)
      return "IU";
    if (priority == Priority.UrgentNotImportant)
      return "NIU";
    if (priority == Priority.NotUrgentImportant)
      return "INU";
    if (priority == Priority.NotUrgentNotImportant)
      return "NINU";

    return "";
  }

  Map<String, dynamic> toJson() {
    var json = Map<String, dynamic>();
    json['documentId'] = documentId;
    json['title'] = title;
    json['content'] = content;
    json['isDone'] = isDone;
    json['timestamp'] = timestamp;
    json['priority'] = Todo.priorityToString(priority);
    if (iconData != null) {
      var iconMap = Map<String, dynamic>();
      iconMap['codePoint'] = iconData!.codePoint;
      iconMap['font'] = iconData!.fontFamily;
      iconMap['fontPackage'] = iconData!.fontPackage;
      json['icon'] = iconMap;
    }
    json['goalName'] = goalName;

    return json;
  }

  String getDocumentId() => documentId;
}