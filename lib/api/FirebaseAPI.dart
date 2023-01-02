import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f_logs/f_logs.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_timemanagement/api/API.dart';
import 'package:flutter_timemanagement/data/todo.dart';
import 'package:flutter_timemanagement/util/user_manager.dart';

class FirebaseAPI implements ApiService {

  FirebaseAnalytics analytics = FirebaseAnalytics();

  CollectionReference _todos() { return FirebaseFirestore.instance
      .collection("users")
      .doc(UserManager.uid)
      .collection("todos");
  }

  Stream getTodos() {
    return _todos().snapshots();
  }

  Stream getInProgressTodos() {
    return _todos().where('isDone', isEqualTo: false).snapshots();
  }

  Stream getTodosWithGoals(String goalName) {
    return _todos().where('goalName', isEqualTo: goalName).snapshots();
  }

  Stream getChallenges() {
    return FirebaseFirestore.instance.collection("challenges").snapshots();
  }

  Future<void> addTodo(Map<String, dynamic> entry) async {
    await _todos().add(entry);
  }

  Future<void> updateTodo(String docId, Map<String, dynamic> entry) async {
    await _todos().doc(docId).update(entry);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> user) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update(user);
  }

  List<Todo> getTodosFromSnapshotData(Object data) {
    if (data is QuerySnapshot) {
      return List.from(data.docs.map((e) => Todo.fromJson(e.data(), e.id)));
    } else
      throw Exception("Exception thrown. Data is not in expected format.");
  }

  List<Map<String, dynamic>> getChallengesFromSnapshotData(Object data) {
    if (data is QuerySnapshot) {

      List<Map<String, dynamic>> list = [];
      data.docs.forEach((element) {
        var map = element.data();
        map.addAll({"id" : element.id});
        list.add(map);
      });

      return list;
    }
    else
      throw Exception("Exception thrown. Data is not in expected format.");
  }

  @override
  Future<String> signInEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: email,
          password: password
      );

      var uid = userCredential.user!.uid;
      return uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  Future<Map<String, dynamic>> getUser() async {

    return FirebaseFirestore.instance
        .collection('users')
        .doc(UserManager.uid)
        .get()
        .then((value) {
      return value.data()!;
    });
  }

  Future<String> getImageUrl(String imageName) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child(imageName);

    var url = await ref.getDownloadURL();
    return url;
  }

  @override
  Future<void> log(String text) async {
    FLog.logThis(text: text, type: LogLevel.INFO);
  }

  @override
  Future<void> logEvent(String eventName, {Map<String, dynamic> data = const {}}) async {
    FLog.logThis(text: eventName, type: LogLevel.INFO);

    await analytics.logEvent(
      name: eventName,
      parameters: data
    );
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}