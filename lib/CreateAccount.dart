import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login.dart';

class CreateAccountWidget extends StatefulWidget {
  @override
  _CreateAccountWidgetState createState() => _CreateAccountWidgetState();
}

class _CreateAccountWidgetState extends State<CreateAccountWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisibility1 = false;
  bool _passwordVisibility2 = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String? _selectedRole;
  String? _selectedGender;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController1.dispose();
    _passwordController2.dispose();
    _prefixController.dispose();
    _fullNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_passwordController1.text != _passwordController2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select gender")),
      );
      return;
    }

    final url =
        'http://localhost:81/adscAPI/user.php'; // เปลี่ยนเป็น URL ของ API ที่คุณใช้

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'agency': _selectedRole,
        'first_name': _fullNameController.text,
        'last_name': _lastNameController.text,
        'gender': _selectedGender,
        'prefix': _prefixController.text,
        'status': 'รออนุมัติ',
        'email': _emailController.text,
        'password': _passwordController1.text,
        'phone': _phoneNumberController.text,
      }),
    );

    print(response.body);

    try {
      final data = json.decode(response.body);
      print('Decoded JSON: $data');

      if (response.statusCode == 200) {
        print('Registration successful: ${data['message']}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoginPage()), // เปลี่ยนเป็นหน้า Login ที่ต้องการ
        );
      } else {
        print('Registration failed: ${data['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error decoding JSON")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B39EF), Color(0xFFEE8B60)],
            stops: [0, 1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 570),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color(0x33000000),
                    offset: Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Dropdown for Role
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          items: [
                            DropdownMenuItem(
                              value: 'เจ้าหน้าที่ตำรวจ',
                              child: Text('เจ้าหน้าที่ตำรวจ'),
                            ),
                            DropdownMenuItem(
                              value: 'เจ้าหน้าที่กู้ภัย',
                              child: Text('เจ้าหน้าที่กู้ภัย'),
                            ),
                            DropdownMenuItem(
                              value: 'หน่วยงานอื่นที่เกี่ยวข้อง',
                              child: Text('หน่วยงานอื่นที่เกี่ยวข้อง'),
                            ),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedRole = val),
                          decoration: InputDecoration(
                            labelText: 'โปรดเลือกกลุ่มผู้ใช้',
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Color(0xFFF1F4F8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      // Gender Radio Buttons
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'ระบุเพศ',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('ชาย'),
                              value:
                                  'ชาย', // เปลี่ยนค่าให้ตรงกับ enum ในฐานข้อมูล
                              groupValue: _selectedGender,
                              onChanged: (val) =>
                                  setState(() => _selectedGender = val),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('หญิง'),
                              value:
                                  'หญิง', // เปลี่ยนค่าให้ตรงกับ enum ในฐานข้อมูล
                              groupValue: _selectedGender,
                              onChanged: (val) =>
                                  setState(() => _selectedGender = val),
                            ),
                          ),
                        ],
                      ),
                      // Prefix Field
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                        child: TextFormField(
                          controller: _prefixController,
                          autofocus: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'คำนำหน้าชื่อ',
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: 'ป้อนคำนำหน้าชื่อ เช่น ร้อยตรี',
                            filled: true,
                            fillColor: Color(0xFFF1F4F8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Full Name Field
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _fullNameController,
                          autofocus: true,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'ชื่อ',
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: 'ป้อนชื่อ',
                            filled: true,
                            fillColor: Color(0xFFF1F4F8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Last Name Field
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'นามสกุล',
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: 'ป้อนนามสกุล',
                            filled: true,
                            fillColor: Color(0xFFF1F4F8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกนามสกุล';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Email Field
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _emailController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'อีเมล',
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xFF57636C),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: 'ป้อนอีเมล',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFF1F4F8),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF4B39EF),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF1F4F8),
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xFF101213),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกอีเมล';
                            } else if (!RegExp(
                                    r"^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$")
                                .hasMatch(value)) {
                              return 'กรุณากรอกอีเมลที่ถูกต้อง';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Phone Number Field
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'เบอร์โทรศัพท์',
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: 'ป้อนเบอร์โทรศัพท์',
                            filled: true,
                            fillColor: Color(0xFFF1F4F8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกเบอร์โทรศัพท์';
                            } else if (!RegExp(r'^[0-9]{10}$')
                                .hasMatch(value)) {
                              return 'กรุณากรอกเบอร์โทรศัพท์ที่ถูกต้อง (10 หลัก)';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Password Fields
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _passwordController1,
                          obscureText: !_passwordVisibility1,
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่าน',
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xFF57636C),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: 'ป้อนรหัสผ่าน',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFF1F4F8),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF4B39EF),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF1F4F8),
                            suffixIcon: InkWell(
                              onTap: () => setState(
                                () => _passwordVisibility1 =
                                    !_passwordVisibility1,
                              ),
                              child: Icon(
                                _passwordVisibility1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Color(0xFF57636C),
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xFF101213),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกรหัสผ่าน';
                            } else if (value.length < 6) {
                              return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: TextFormField(
                          controller: _passwordController2,
                          obscureText: !_passwordVisibility2,
                          decoration: InputDecoration(
                            labelText: 'ยืนยันรหัสผ่าน',
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xFF57636C),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            hintText: 'ยืนยันรหัสผ่าน',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFF1F4F8),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF4B39EF),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Color(0xFFF1F4F8),
                            suffixIcon: InkWell(
                              onTap: () => setState(
                                () => _passwordVisibility2 =
                                    !_passwordVisibility2,
                              ),
                              child: Icon(
                                _passwordVisibility2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Color(0xFF57636C),
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xFF101213),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณายืนยันรหัสผ่าน';
                            } else if (value != _passwordController1.text) {
                              return 'รหัสผ่านไม่ตรงกัน';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Register Button
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _registerUser();
                              }
                            },
                            child: Text('สร้างบัญชี'),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF4B39EF),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: TextStyle(
                                fontFamily: 'Roboto',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
