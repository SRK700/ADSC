import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsFormWidget extends StatefulWidget {
  const DetailsFormWidget({super.key});

  @override
  State<DetailsFormWidget> createState() => _DetailsFormWidgetState();
}

class _DetailsFormWidgetState extends State<DetailsFormWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String? selectedReason;
  TextEditingController? detailsController;

  @override
  void initState() {
    super.initState();
    detailsController = TextEditingController();
  }

  @override
  void dispose() {
    detailsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
                      'ฝ่าฝืนสํญญานไฟจราจร',
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
                    // ใช้ Center เพื่อจัดปุ่มให้อยู่ตรงกลาง
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Handle form submission
                        }
                      },
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
