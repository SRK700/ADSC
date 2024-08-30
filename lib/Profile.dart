import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'welcome.dart';
import 'Dashboard.dart';

class ProfileWidget extends StatefulWidget {
  final String email;

  const ProfileWidget({Key? key, required this.email}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  String userName = 'กำลังโหลด...';

  @override
  void initState() {
    super.initState();
    _getUserData(widget.email);
  }

  Future<void> _getUserData(String email) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:81/adscAPI/user.php?email=$email'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty && data.containsKey('first_name')) {
          setState(() {
            userName = data['first_name']; // ใช้ชื่อผู้ใช้ที่ได้จาก API
          });
        } else {
          setState(() {
            userName = 'ไม่พบผู้ใช้';
          });
        }
      } else {
        setState(() {
          userName = 'ข้อผิดพลาดในการโหลด';
        });
      }
    } catch (e) {
      setState(() {
        userName = 'เกิดข้อผิดพลาด';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 140,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1434394354979-a235cd36269d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTJ8fG1vdW50YWluc3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: Colors.grey[800],
                  iconSize: 30,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DashboardWidget(email: widget.email),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 24,
                bottom: 16,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.teal[300]!.withOpacity(0.4),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundImage: const NetworkImage(
                      'https://images.unsplash.com/photo-1489980557514-251d61e3eeb6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OTZ8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              userName, // แสดงชื่อผู้ใช้ที่ได้จาก API
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101213),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.email,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF57636C),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'บัญชีของฉัน',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF57636C),
              ),
            ),
          ),
          buildMenuItem(
            context,
            icon: Icons.account_circle_outlined,
            title: 'แก้ไขข้อมูลผู้ใช้',
            onTap: () {
              // Implement navigation to Edit Profile
            },
          ),
          buildMenuItem(
            context,
            icon: FontAwesomeIcons.line,
            title: 'เชื่อมต่อกับ LINE',
            onTap: () {
              // Implement LINE connection
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to Welcome screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            WelcomeWidget()), // ใช้ WelcomeWidget ที่ถูกต้อง
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey[200],
                  onPrimary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(38),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('ออกจากระบบ'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF57636C),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}
