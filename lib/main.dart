import 'package:demofb/firebase_api.dart';
import 'package:demofb/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/login.dart';

Future <void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      ),
      home: LoginPage(),
    );
  }
}



