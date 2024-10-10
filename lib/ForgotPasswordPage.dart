import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEmailVerified = false; // Track if the email has been verified

  Future<void> _verifyEmail() async {
    final String email = _emailController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:81/adscAPI/resetPassword.php'), // Replace with your actual API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _isEmailVerified = true; // Allow the user to reset the password
          });
        } else {
          _showDialog('ผิดพลาด', 'อีเมลไม่ถูกต้องหรือไม่มีในระบบ', Icons.error,
              Colors.red);
        }
      } else {
        _showDialog('ผิดพลาด', 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์',
            Icons.error, Colors.red);
      }
    } catch (e) {
      _showDialog('ผิดพลาด', 'กรุณาลองใหม่อีกครั้ง', Icons.error, Colors.red);
    }
  }

  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    if (newPassword != confirmPassword) {
      _showDialog('ผิดพลาด', 'รหัสผ่านไม่ตรงกัน', Icons.error, Colors.red);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost:81/adscAPI/updatePassword.php'), // Replace with your actual API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showDialog('สำเร็จ!', 'รีเซ็ตรหัสผ่านเรียบร้อยแล้ว',
              Icons.check_circle, Colors.green);
        } else {
          _showDialog(
              'ผิดพลาด', 'ไม่สามารถรีเซ็ตรหัสผ่านได้', Icons.error, Colors.red);
        }
      } else {
        _showDialog('ผิดพลาด', 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์',
            Icons.error, Colors.red);
      }
    } catch (e) {
      _showDialog('ผิดพลาด', 'กรุณาลองใหม่อีกครั้ง', Icons.error, Colors.red);
    }
  }

  void _showDialog(
      String title, String message, IconData icon, Color iconColor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: iconColor),
              SizedBox(height: 20),
              Text(title,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: iconColor)),
              SizedBox(height: 10),
              Text(message,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(primary: iconColor),
                child: Text('ตกลง', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ลืมรหัสผ่าน'),
        backgroundColor: Color(0xFF4B39EF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEmailVerified) ...[
                Text(
                  'กรุณากรอกอีเมลเพื่อเริ่มรีเซ็ตรหัสผ่าน:',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _verifyEmail,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF4B39EF),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('ตรวจสอบอีเมล',
                      style: TextStyle(color: Colors.white)),
                ),
              ] else ...[
                Text(
                  'กรุณากรอกรหัสผ่านใหม่:',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่านใหม่',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่านใหม่';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'ยืนยันรหัสผ่านใหม่',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกยืนยันรหัสผ่านใหม่';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF4B39EF),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('ตั้งรหัสผ่านใหม่',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
