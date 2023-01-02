import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/api/API.dart';
import 'package:flutter_timemanagement/data/pomodoro.dart';
import 'package:flutter_timemanagement/data/todo.dart';
import 'package:flutter_timemanagement/data/user.dart';
import 'package:flutter_timemanagement/util/user_manager.dart';
import 'package:flutter_timemanagement/widgets/priority_chooser.dart';
import 'package:uuid/uuid.dart';

class MockAPI implements ApiService {

  late List<Todo> Todos;
  late List<Pomodoro> Pomodoros;
  late List<Map<String, dynamic>> Challenges;

  late User user;


  MockAPI() {
    Challenges = [
      {
        "Name" : "Test Challenge 1",
        "ImageName" : ""
      },
      {
        "Name" : "Test Challenge 2",
        "ImageName" : ""
      }
    ];

    print(Challenges);

    Todos = [
      Todo("todo-1", "Test Todo", "My Test Content", false, null, Priority.UrgentImportant, Icons.info, ""),
      Todo("todo-2", "Test Todo 2", "My Test Content", false, null, Priority.UrgentImportant, Icons.info, ""),
      Todo("todo-3", "Test Todo 3", "My Test Content", false, null, Priority.UrgentImportant, Icons.info, ""),
      Todo("todo-4", "Test Todo 4", "My Test Content", false, null, Priority.UrgentImportant, Icons.info, ""),
    ];

    Pomodoros = [];


    user = User("TEST", "EmailPW", "-- Chris --", "", 0, false, 0, 1, []);
  }

  @override
  Future<void> addTodo(Map<String, dynamic> entry) async {
    Todos.add(Todo.fromJson(entry, Uuid().v4()));
  }

  @override
  Stream getChallenges() async* {
    print("CHALLENGES");
    print(Challenges);
    yield Challenges;
  }

  @override
  List<Map<String, dynamic>> getChallengesFromSnapshotData(Object data) {
    print("DATA");
    print(data);

    if (data is List<Map<String, dynamic>>)
      return data;

    throw Exception("Unknown type conversion");
  }

  @override
  Stream getInProgressTodos() async* {
    yield Todos;
  }

  @override
  Stream getTodos() async* {
    print(Todos);
    yield Todos;
  }

  @override
  List<Todo> getTodosFromSnapshotData(Object data) {
    print(data);

    if (data is List<Todo>)
      return data;
    if (data is Todo)
      return [data];

    throw Exception("Unknown type conversion");
  }

  @override
  Stream getTodosWithGoals(String goalName) async* {
    yield Todos;
  }

  @override
  Future<String> signInEmailPassword(String email, String password) async {
    return user.documentId;
  }

  @override
  Future<void> updateTodo(String docId, Map<String, dynamic> entry) async {
    print("update todo");
    var index = Todos.indexWhere((element) => element.documentId == docId);
    Todos.removeAt(index);
    Todos.insert(index, Todo.fromJson(entry, docId));
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> user) async {
      this.user = User.fromJson(user, userId);
  }

  Future<Map<String, dynamic>> getUser() async {
      return user.toJson();
  }

  Future<String> getImageUrl(String imageName) async {
    return "https://picsum.photos/200";
  }

  @override
  Future<void> log(String text) async {
      print(text);
  }

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic> data = const {}}) async {
      print(eventName);
  }

  @override
  Future<void> signOut() async {

  }
}