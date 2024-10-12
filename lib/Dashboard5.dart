import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Profile.dart';
import 'NotificationList.dart';
import 'Login.dart';
import 'AccidentStatistics.dart';
import 'AccidentReportList.dart';

class DashboardWidget extends StatefulWidget {
  final String email;
  final String agency;

  const DashboardWidget({required this.email, required this.agency, Key? key})
      : super(key: key);

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  bool showConfirmed = false;
  List<Map<String, dynamic>> topReasons = [];
  String userName = '';
  String? _selectedAgency;
  String? _selectedCameraLocation;

  List<String> _agencies = [];
  List<String> _cameraLocations = [];

  @override
  void initState() {
    super.initState();
    _fetchTopReasons();
    _fetchUserName();
    _fetchFilters();
    Future.delayed(Duration.zero, () async {
      await _checkLoginStatus();
    });
  }

  Future<void> _fetchFilters() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:81/adscAPI/get-filters.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _agencies = List<String>.from(data['agencies']);
          _cameraLocations = List<String>.from(data['camera_locations']);
        });
      } else {
        print('Failed to load filters');
      }
    } catch (e) {
      print('Error fetching filters: $e');
    }
  }

  Future<void> _fetchTopReasons() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:81/adscAPI/get-top-reasons.php'),
      );

      if (response.statusCode == 200) {
        setState(() {
          topReasons =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print('Failed to load top reasons');
      }
    } catch (e) {
      print('Error fetching top reasons: $e');
    }
  }

  Future<void> _fetchUserName() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:81/adscAPI/user.php?email=${widget.email}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['first_name'] ?? '';
        });
      } else {
        print('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');

    if (email == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'สถิติ (จำนวนครั้ง)',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xFF14181B),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              Text(
                userName.isNotEmpty ? ' $userName' : '',
                style: const TextStyle(
                  color: Color(0xFF4B39EF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: Color(0xFF4B39EF),
                  size: 28,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileWidget(email: widget.email),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatSection(),
              const SizedBox(height: 16),
              widget.agency == 'หน่วยงานที่เกี่ยวข้อง'
                  ? _buildAccidentReportSection()
                  : _buildNotificationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatSection() {
    if (topReasons.isEmpty) {
      return Center(
        child: Text(
          'ไม่มีสถิติที่จะแสดง',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topReasons.length,
        itemBuilder: (context, index) {
          return _buildStatCard(
            topReasons[index]['count'] ?? '0',
            topReasons[index]['reason'] ?? '',
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String count, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccidentStatistics(),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccidentReportSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'รายงานสาเหตุอุบัติเหตุ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101213),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  hint: Text('เลือกหน่วยงาน'),
                  value: _selectedAgency,
                  items: _agencies.map((agency) {
                    return DropdownMenuItem<String>(
                      value: agency,
                      child: Text(agency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAgency = value;
                    });
                  },
                ),
                DropdownButton<String>(
                  hint: Text('เลือกสถานที่ตั้งกล้อง'),
                  value: _selectedCameraLocation,
                  items: _cameraLocations.map((location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCameraLocation = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            AccidentReportList(
              selectedAgency: _selectedAgency,
              selectedCameraLocation: _selectedCameraLocation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'แจ้งเตือนอุบัติเหตุ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101213),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToggleButton('รอการตรวจสอบ', !showConfirmed, () {
                  setState(() {
                    showConfirmed = false;
                  });
                }),
                const SizedBox(width: 8),
                _buildToggleButton('ยืนยันแล้ว', showConfirmed, () {
                  setState(() {
                    showConfirmed = true;
                  });
                }),
              ],
            ),
            const SizedBox(height: 10),
            NotificationList(
              showConfirmed: showConfirmed,
              email: widget.email,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
      String label, bool isActive, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: isActive ? Color(0xFF4B39EF) : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadowColor: Colors.black.withOpacity(0.25),
        elevation: 3,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}
