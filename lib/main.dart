import 'package:flutter/material.dart';
import 'Login.dart'; // Import your Login page
import 'Dashboard5.dart'; // Import the Dashboard
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('userEmail');
  final agency =
      prefs.getString('agency'); // Fetch the agency from SharedPreferences

  // Fetch notification count from the API
  final notificationCount = await _fetchNotificationCount();

  runApp(MyApp(
    initialEmail: email,
    initialAgency: agency,
    notificationCount: notificationCount, // Pass the fetched notification count
  ));
}

Future<int> _fetchNotificationCount() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.10.58.123:5000/get-notification-count'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data[
          'count']; // Return the notification count from the API response
    } else {
      print('Failed to load notification count');
      return 0; // Return 0 in case of failure
    }
  } catch (e) {
    print('Error fetching notification count: $e');
    return 0; // Return 0 in case of an error
  }
}

class MyApp extends StatelessWidget {
  final String? initialEmail;
  final String? initialAgency;
  final int notificationCount; // Include notificationCount as a parameter

  const MyApp(
      {this.initialEmail,
      this.initialAgency,
      required this.notificationCount,
      super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADSC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Navigate to LoginPage if no email, else to Dashboard
      home: initialEmail != null && initialAgency != null
          // Check both email and agency
          ? DashboardWidget(
              email: initialEmail!,
              agency: initialAgency!,
              notificationCount:
                  notificationCount, // Use the fetched notificationCount
            )
          : LoginPage(), // Start at login if not logged in
    );
  }
}
