import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'smart_watering_system.dart'; // Import your main app screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Watering System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SmartWateringSystem(),
      ),
    );
  }
}
