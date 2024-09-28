import 'dart:convert'; // นำเข้าการจัดการ JSON
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // นำเข้า SharedPreferences
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class DetailsFormWidget extends StatefulWidget {
  final int notificationId; // รับค่า notificationId

  const DetailsFormWidget({super.key, required this.notificationId});

  @override
  State<DetailsFormWidget> createState() => _DetailsFormWidgetState();
}

class _DetailsFormWidgetState extends State<DetailsFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String? selectedReason;
  TextEditingController? detailsController;
  String? agency; // เก็บข้อมูลหน่วยงานที่ดึงมาจาก SharedPreferences

  @override
  void initState() {
    super.initState();
    detailsController = TextEditingController();
    _loadAgency(); // โหลดค่า agency จาก SharedPreferences
  }

  Future<void> _loadAgency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      agency = prefs.getString('agency'); // ดึง agency จาก SharedPreferences
    });
  }

  @override
  void dispose() {
    detailsController?.dispose();
    super.dispose();
  }

  Future<void> _saveAccidentDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      // ทำการบันทึกข้อมูล โดยส่ง agency และ notificationId ไปใน request ด้วย
      final details = detailsController?.text;
      final reason = selectedReason;

      // ส่งข้อมูลไปยัง API บันทึกเหตุผล
      final response = await http.post(
        Uri.parse(
            'http://192.168.1.246:5000/save-accident-reason'), // แทนที่ด้วย URL ของ API จริง
        body: json.encode({
          'notification_id':
              widget.notificationId, // ใช้ notificationId จาก widget
          'reason': reason,
          'details': details,
          'agency': agency, // ใช้ค่า agency จาก SharedPreferences
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // แสดงผลลัพธ์เมื่อบันทึกสำเร็จ
        Navigator.of(context).pop(); // ปิดฟอร์มเมื่อบันทึกเสร็จสิ้น
      } else {
        // แสดงข้อผิดพลาดเมื่อบันทึกไม่สำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save accident reason')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF15161E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'บันทึกสาเหตุอุบัติเหตุ',
          style: GoogleFonts.outfit(
            color: Color(0xFF15161E),
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'เลือกสาเหตุ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Color(0xFFE5E7EB), width: 2),
                      ),
                    ),
                    value: selectedReason,
                    items: [
                      'เมาแล้วขับ',
                      'ขับด้วยความเร็ว',
                      'หลับใน',
                      'ตัดหน้ากระชั้นชิด',
                      'ฝ่าฝืนสัญญาณไฟจราจร',
                      'ทัศนวิสัยไม่ดี',
                      'โทรศัพท์ขณะขับขี่',
                      'บรรทุกเกิน',
                      'อื่นๆ'
                    ]
                        .map((reason) => DropdownMenuItem<String>(
                              value: reason,
                              child: Text(reason),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => selectedReason = val),
                    icon: Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: detailsController,
                    decoration: InputDecoration(
                      labelText: 'รายละเอียดเพิ่มเติม',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFFE5E7EB), width: 2),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: 6,
                    maxLength: 200,
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _saveAccidentDetails,
                      icon: FaIcon(FontAwesomeIcons.solidSave, size: 15),
                      label: Text(
                        'บันทึก',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48), // ปรับขนาดปุ่ม
                        primary: Color(0xFF6F61EF),
                        onPrimary: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 16), // ปรับ padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),
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
    );
  }
}
