import 'package:flutter/material.dart';
import 'NotificationList.dart'; // Import the NotificationList widget

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: NotificationList(
          showConfirmed: false, // หรือ true ขึ้นอยู่กับการตั้งค่าเริ่มต้น
          email:
              'userEmail', // ส่ง email ของผู้ใช้ (อาจดึงจาก SharedPreferences)
        ),
      ),
    );
  }
}
