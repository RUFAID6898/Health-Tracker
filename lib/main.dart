import 'package:flutter/material.dart';

import 'package:health_tracker/view/authentication/AuthenticationScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthTrackerApp());
}

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthenticationScreen(),
    );
  }
}
