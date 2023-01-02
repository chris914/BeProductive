import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class FirebaseInitializer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FirebaseInitializerState();
  }
}

class FirebaseInitializerState extends State<FirebaseInitializer> {
  late Future<FirebaseApp> _initialization;

  Future<FirebaseApp> initFirebase() async {
    final firebaseApp = await Firebase.initializeApp();

    // Ideal time to initialize
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

    return firebaseApp;
  }

  @override
  void initState() {
    super.initState();
    _initialization = initFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (context) => FirebaseAnalytics(),
        child: FutureBuilder(
            future: _initialization,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Failed to initialize Firebase"));
              }

              if (snapshot.hasData) return MyApp();

              return Center(child: CircularProgressIndicator());
            }));
  }
}
