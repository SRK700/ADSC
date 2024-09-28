import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProfileWidget extends StatefulWidget {
  final String email;

  const EditProfileWidget({Key? key, required this.email}) : super(key: key);

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _prefixNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _prefixNameController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController(text: widget.email);

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response = await http.get(
      Uri.parse('http://localhost:81/adscAPI/user.php?email=${widget.email}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        _prefixNameController.text = data['prefix'] ?? '';
        _firstNameController.text = data['first_name'] ?? '';
        _lastNameController.text = data['last_name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      });
    } else {
      print('Failed to load user data');
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.put(
      Uri.parse('http://localhost:81/adscAPI/user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'prefix': _prefixNameController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'phone': _phoneController.text,
      }),
    );

    print(response.body); // พิมพ์ response.body เพื่อตรวจสอบ

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data['message'] == 'User updated successfully') {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message']}')),
          );
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid response format: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes')),
      );
    }
  }

  @override
  void dispose() {
    _prefixNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'แก้ไขข้อมูลส่วนตัว',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Prefix Name Input
                _buildTextField(
                  controller: _prefixNameController,
                  labelText: 'คำนำหน้าชื่อ',
                ),
                const SizedBox(height: 16),
                // First Name Input
                _buildTextField(
                  controller: _firstNameController,
                  labelText: 'ชื่อ',
                ),
                const SizedBox(height: 16),
                // Last Name Input
                _buildTextField(
                  controller: _lastNameController,
                  labelText: 'นามสกุล',
                ),
                const SizedBox(height: 16),
                // Phone Input
                _buildTextField(
                  controller: _phoneController,
                  labelText: 'เบอร์โทรศัพท์',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                // Email Input (Disabled)
                _buildTextField(
                  controller: _emailController,
                  labelText: 'อีเมล',
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // ปิดการแก้ไขอีเมล
                ),
                const SizedBox(height: 24),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfileChanges,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'บันทึกการเปลี่ยนแปลง',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      ),
      enabled: enabled,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณากรอก$labelText';
        }
        return null;
      },
    );
  }
}
