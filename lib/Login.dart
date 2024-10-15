import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Dashboard5.dart'; // Import your dashboard page
import 'CreateAccount.dart'; // Import your registration page
import 'ForgotPasswordPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true; // To toggle password visibility

  Future<void> _login(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:81/adscAPI/checklogin.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['message'] == 'Login successful') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', email);
          await prefs.setString('agency', data['user']['agency']);
          await prefs.setString('firstName', data['user']['first_name']);
          await prefs.setString('lastName', data['user']['last_name']);
          await prefs.setString('status', data['user']['status']);

          // ตรวจสอบสถานะผู้ใช้ (รออนุมัติหรือระงับ)
          if (data['user']['status'] == 'รออนุมัติ' ||
              data['user']['status'] == 'ระงับ') {
            String statusMessage = data['user']['status'] == 'รออนุมัติ'
                ? 'บัญชีของคุณยังอยู่ในสถานะรอการอนุมัติ'
                : 'บัญชีของคุณถูกระงับการใช้งาน กรุณาติดต่อเจ้าหน้าที่';

            _showCustomDialog(
              context,
              'ไม่สามารถเข้าใช้งานได้',
              statusMessage,
              Icons.error_outline,
              Colors.orange,
            );
            return;
          }

          // Show custom dialog for success
          _showCustomDialog(
            context,
            'ล็อกอินสำเร็จ!',
            'ยินดีต้อนรับสู่ระบบ',
            Icons.check_circle,
            Colors.green,
          );

          // สมมุติว่าคุณมีการเรียก API ที่จะดึง notificationCount มาได้จาก backend หรือฐานข้อมูล
          int notificationCount = 5; // สามารถแทนที่ด้วยค่าจาก API หรือฐานข้อมูล

          // Navigate to Dashboard after a slight delay
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardWidget(
                  email: email,
                  agency: data['user']['agency'],
                  notificationCount:
                      notificationCount, // ส่ง notificationCount ไปยัง DashboardWidget
                ),
              ),
            );
          });
        } else if (data['message'] == 'Invalid email or password') {
          _showCustomDialog(
            context,
            'ล็อกอินไม่สำเร็จ!',
            'อีเมลหรือรหัสผ่านไม่ถูกต้อง โปรดลองอีกครั้ง',
            Icons.error_outline,
            Colors.red,
          );
        } else if (data['message'] == 'Account not approved or suspended') {
          _showCustomDialog(
            context,
            'ไม่สามารถเข้าใช้งานได้',
            data['status'] ??
                'บัญชีของคุณยังอยู่ในสถานะรอการอนุมัติหรือถูกระงับการใช้งาน',
            Icons.error_outline,
            Colors.orange,
          );
        } else {
          _showCustomDialog(
            context,
            'ล็อกอินไม่สำเร็จ!',
            'โปรดลองอีกครั้ง',
            Icons.error_outline,
            Colors.red,
          );
        }
      } else {
        _showCustomDialog(
          context,
          'ข้อผิดพลาด!',
          'Error: ${response.statusCode} ${response.reasonPhrase}',
          Icons.error_outline,
          Colors.red,
        );
      }
    } catch (e) {
      _showCustomDialog(
        context,
        'เกิดข้อผิดพลาด!',
        'กรุณาลองใหม่อีกครั้ง',
        Icons.error_outline,
        Colors.red,
      );
    }
  }

  void _showCustomDialog(BuildContext context, String title, String message,
      IconData icon, Color iconColor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: iconColor),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: iconColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ตกลง',
                  style: TextStyle(color: Colors.white),
                ),
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
      body: Stack(
        children: [
          FractionallySizedBox(
            heightFactor: 0.6,
            alignment: Alignment.topCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4B39EF),
                    Color(0xFFFF5963),
                    Color(0xFFEE8B60),
                    Colors.white,
                  ],
                  stops: [0.0, 0.3, 0.6, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              color: Colors.white,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.asset(
                          'Images/Logo1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'เข้าสู่ระบบ',
                      style: GoogleFonts.getFont(
                        'Plus Jakarta Sans',
                        color: Color.fromARGB(255, 3, 3, 3),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'อีเมล',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกอีเมล';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: 'รหัสผ่าน',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณากรอกรหัสผ่าน';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: ElevatedButton(
                              onPressed: () {
                                _login(context);
                              },
                              child: Text(
                                'เข้าสู่ระบบ',
                                style: GoogleFonts.getFont(
                                  'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF4B39EF),
                                padding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 80.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ForgotPasswordPage(), // Navigate to the forgot password page
                                ),
                              );
                            },
                            child: Text(
                              'ลืมรหัสผ่าน?',
                              style: GoogleFonts.getFont(
                                'Plus Jakarta Sans',
                                color: Color.fromARGB(255, 235, 115, 106),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAccountWidget(),
                                ),
                              );
                            },
                            child: Text(
                              'ลงทะเบียน',
                              style: GoogleFonts.getFont(
                                'Plus Jakarta Sans',
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
