import 'package:flutter/material.dart';
import 'Dashboard5.dart'; // Dashboard page
import 'NotificationPage.dart'; // A new page that will display NotificationList directly
import 'Profile.dart'; // Profile page
import 'HistoryPage.dart'; // New page for history (after accident reasons)

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    DashboardWidget(email: 'userEmail', agency: 'agency'), // Dashboard
    NotificationPage(), // Notifications
    HistoryPage(), // History
    ProfileWidget(email: 'userEmail') // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // current index of the selected menu
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the index when a new item is tapped
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'แจ้งเตือน',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'ประวัติ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
