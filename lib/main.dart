import 'package:flutter/material.dart';
import 'Login.dart'; // Import your Login page
import 'Dashboard5.dart'; // Import the Dashboard
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('userEmail');
  final agency =
      prefs.getString('agency'); // Fetch the agency from SharedPreferences

  runApp(MyApp(initialEmail: email, initialAgency: agency));
}

class MyApp extends StatelessWidget {
  final String? initialEmail;
  final String? initialAgency; // Add this line to include the agency parameter

  const MyApp({this.initialEmail, this.initialAgency, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADSC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Navigate to LoginPage if no email, else to Dashboard
      home: initialEmail != null &&
              initialAgency != null // Check both email and agency
          ? DashboardWidget(
              email: initialEmail!,
              agency: initialAgency!) // Pass both email and agency
          : LoginPage(), // Start at login if not logged in
    );
  }
}
