import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/data/pomodoro.dart';
import 'package:flutter_timemanagement/util/user_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

Future<void> completeTodo(BuildContext context, String todoDocumentId) async {
  bool cloudFunctionsEnabled = true;

  if (!cloudFunctionsEnabled) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(UserManager.uid)
        .collection("todos")
        .doc(todoDocumentId)
        .update({'isDone': true});
  } else {
    var parameter = {
      'type': 'Todo',
      'object': {'todoDocumentId': todoDocumentId}
    };

    await onCompletedCloudFunctionShowResult(context, parameter);
  }
}

Future<void> addPomodoroEntry(BuildContext context,
    {String todoDocumentId = "", bool completeTodo = false}) async {
  bool cloudFunctionsEnabled = true;

  var timeStamp = Timestamp.fromDate(DateTime.now());
  var id = Uuid().v4();
  var pomodoro = Pomodoro(id, todoDocumentId, timeStamp);

  if (!cloudFunctionsEnabled) {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(UserManager.uid)
        .collection("pomodoros")
        .add(pomodoro.toJson());

    if (completeTodo)
      FirebaseFirestore.instance
          .collection("users")
          .doc(UserManager.uid)
          .collection("todos")
          .doc(todoDocumentId)
          .update({'isDone': true});
  } else {
    var parameter = {
      'type': 'Pomodoro',
      'object': {
        'id': pomodoro.documentId,
        'todoDocumentId': pomodoro.todoDocumentId
      },
      'completeTodo': completeTodo
    };

    await onCompletedCloudFunctionShowResult(context, parameter);
  }
}

Future<void> onCompletedCloudFunctionShowResult(BuildContext context, dynamic parameter) async {
  var callable = FirebaseFunctions.instance.httpsCallable('onCompleted');
  final results = await callable(parameter);
  var result = results.data;
  var shouldUpdate = result['shouldUpdate'] as bool;
  if (!shouldUpdate) return;

  print(result);
  var object = result['object'];
  print(object);

  if (object.length == 0)
    return;

  final snackBar = SnackBar(
      duration: object.length > 1
          ? Duration(milliseconds: (5500))
          : Duration(milliseconds: (4000)),
      content: Container(
        constraints: BoxConstraints(
            minHeight: 0, minWidth: double.infinity, maxHeight: 200),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: object.length,
          itemBuilder: (context, index) => Row(children: [
            Container(
                height: 45,
                width: 45,
                child: object[index]['imageUrl'] != null
                    ? Image.network(object[index]['imageUrl'],
                        width: 40, height: 40)
                    : Container()),
            Expanded(
              child: Container(
                height: 45,
                margin: EdgeInsets.only(left: 8.0),
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(object[index]['name'],
                            style: TextStyle(
                                fontSize: 15, color: Colors.deepOrange))),
                    Container(
                        margin: EdgeInsets.only(top: 8.0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(object[index]['description']))),
                  ],
                ),
              ),
            ),
            index == object.length - 1
                ? TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    child: Text("Close",
                        style:
                            TextStyle(fontSize: 15, color: Colors.deepOrange)))
                : Container(),
          ]),
          separatorBuilder: (context, index) =>
              Container(height: 2, color: Colors.black12),
        ),
      ));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
