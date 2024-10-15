import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'Dashboard5.dart'; // Import หน้า Dashboard ของคุณ
import 'Profile.dart'; // Import หน้า Profile ของคุณ
import 'NotificationPage.dart'; // Import หน้า NotificationPage ของคุณ
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleBottomBar extends StatefulWidget {
  final String email;
  final String agency;

  const GoogleBottomBar({Key? key, required this.email, required this.agency})
      : super(key: key);

  @override
  State<GoogleBottomBar> createState() => _GoogleBottomBarState();
}

class _GoogleBottomBarState extends State<GoogleBottomBar> {
  int _selectedIndex = 1; // เริ่มต้นจากหน้าแจ้งเตือน
  int notificationCount = 0; // ค่าเริ่มต้นของ notification count

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount(); // ดึงข้อมูลแจ้งเตือนตั้งแต่เริ่มต้น
    _pages = [
      DashboardWidget(
        email: widget.email,
        agency: widget.agency,
        notificationCount:
            notificationCount, // ส่งค่า notificationCount ไปยัง Dashboard
      ),
      NotificationPage(), // หน้าแจ้งเตือน
      ProfileWidget(email: widget.email), // หน้า Profile
    ];
  }

  // ฟังก์ชันดึงข้อมูล notification count
  Future<void> _fetchNotificationCount() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.10.58.123:5000/get-notification-count'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notificationCount = data['count'];
          print("Notification Count: $notificationCount"); // Debugging
        });
      } else {
        print('Failed to load notification count');
      }
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // แสดงผลหน้าตามที่เลือก
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // เปลี่ยนหน้าตามเมนูที่เลือก
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.dashboard),
            title: const Text("หน้าหลัก"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (notificationCount > 0) // แสดง Badge เมื่อ count มากกว่า 0
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: const Text("แจ้งเตือน"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("โปรไฟล์"),
            selectedColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
