import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_timemanagement/api/FirebaseAPI.dart';
import 'package:flutter_timemanagement/api/MockAPI.dart';
import 'package:flutter_timemanagement/data/todo.dart';

final ApiService API = FirebaseAPI();

abstract class ApiService {
  Future<String> signInEmailPassword(String email, String password);

  Stream getTodos();
  Stream getInProgressTodos();
  Stream getTodosWithGoals(String goalName);
  Stream getChallenges();
  Future<void> addTodo(Map<String, dynamic> entry);
  Future<void> updateTodo(String docId, Map<String, dynamic> entry);
  Future<void> updateUser(String userId, Map<String, dynamic> user);

  List<Todo> getTodosFromSnapshotData(Object data);
  List<Map<String, dynamic>> getChallengesFromSnapshotData(Object data);
  Future<Map<String, dynamic>> getUser();
  Future<String> getImageUrl(String imageName);

  Future<void> log(String text);
  Future<void> logEvent(String eventName, {Map<String, dynamic> data});

  Future<void> signOut();
}

class AuthException {
  String code;
  String? msg;

  AuthException(this.code, this.msg);
}

class ConnectionHelper {
  static Future<bool> isConnectionOk() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile)
      return true;
    else if (connectivityResult == ConnectivityResult.wifi)
      return true;

    return false;
  }
}

class ApiHelper {

  /// Checks for connectivity issues.
  /// If everything is in order, the callback runs.
  /// Otherwise the optional parameter, errorCallback runs.
  static void safeCallNetworkMethod(VoidCallback callback, {VoidCallback? errorCallback}) async {
    var isConnectionOk = await ConnectionHelper.isConnectionOk();
    if (!isConnectionOk) {
      if (errorCallback != null)
        errorCallback();

      return;
    }

    callback.call();
  }
}