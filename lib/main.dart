import 'package:flutter/material.dart';
import 'package:last_park_app/services/firebase_provider.dart';
import 'package:last_park_app/views/auth_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: CircularProgressIndicator());
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyRealApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(child: CircularProgressIndicator());
      },
    );

  }
}

class MyRealApp extends StatefulWidget {
  @override
  _MyRealAppState createState() => _MyRealAppState();
}

class _MyRealAppState extends State<MyRealApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseProvider>(
            create: (_) => FirebaseProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Last Park",
        home: AuthPage(),
      ),
    );
  }
}

