import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tasks/login_firebase.dart';

import 'firestore_islemleri.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:App(),
    );
  }
}
class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(body: Center(
            child: Text("Xeta bas verdi"+snapshot.error.toString()),
          ),);
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return FireStoreIshlemleri();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return  Scaffold(body: Center(
          child: CircularProgressIndicator(),
        ),);
      },
    );
  }
}
