import 'package:flutter/material.dart';
import 'welcome.dart'; // เพิ่มการ import หน้า welcome.dart
//import 'package:adsc/Dashboard.dart';
//import 'DetailFrome.dart';
//import 'Profile.dart';
//import 'EditProfile.dart';
//import 'ConfirmAccident.dart';
import 'Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('userEmail');

  runApp(MyApp(initialEmail: email));
}

class MyApp extends StatelessWidget {
  final String? initialEmail;

  const MyApp({this.initialEmail, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADSC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: initialEmail != null
          ? DashboardWidget(email: initialEmail!)
          : WelcomeWidget(),
    );
  }
}
