import 'package:cloud_firestore/cloud_firestore.dart';

class Pomodoro{
  final String documentId;
  final String todoDocumentId;
  final Timestamp timestamp;

  Pomodoro(this.documentId, this.todoDocumentId, this.timestamp);

  static Pomodoro fromJson(Map<String, dynamic> json, String documentId){
    return Pomodoro(documentId, json["todoDocumentId"], json['timestamp']);
  }

  Map<String, dynamic> toJson() {
    var json = Map<String, dynamic>();
    json['documentId'] = documentId;
    json['todoDocumentId'] = todoDocumentId;
    json['timestamp'] = timestamp;

    return json;
  }
}