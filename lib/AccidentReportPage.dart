import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccidentReportPage extends StatefulWidget {
  final String? selectedAgency;
  final String? selectedCameraLocation;

  const AccidentReportPage(
      {Key? key, this.selectedAgency, this.selectedCameraLocation})
      : super(key: key);

  @override
  _AccidentReportPageState createState() => _AccidentReportPageState();
}

class _AccidentReportPageState extends State<AccidentReportPage> {
  List<dynamic> _reports = [];
  String searchQuery = '';
  String? selectedAgency;
  String? selectedCameraLocation;
  List<String> agencies = []; // List to hold all agencies
  List<String> cameraLocations = []; // List to hold all camera locations

  @override
  void initState() {
    super.initState();
    selectedAgency = widget.selectedAgency;
    selectedCameraLocation = widget.selectedCameraLocation;
    _fetchAccidentReports();
  }

  Future<void> _fetchAccidentReports() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:81/adscAPI/get-accident-reports.php'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _reports = json.decode(response.body);
          // Extract unique agencies and locations for filtering
          agencies = _reports
              .map((report) => report['agency'] as String)
              .toSet()
              .toList();
          cameraLocations = _reports
              .map((report) => report['camera_location'] as String)
              .toSet()
              .toList();
        });
      } else {
        print('Failed to load accident reports');
      }
    } catch (e) {
      print('Error fetching accident reports: $e');
    }
  }

  List<dynamic> _getFilteredReports() {
    return _reports.where((report) {
      final matchesSearch = searchQuery.isEmpty ||
          report['reason'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesAgency = selectedAgency == null ||
          selectedAgency == 'ทั้งหมด' ||
          report['agency'] == selectedAgency;
      final matchesLocation = selectedCameraLocation == null ||
          selectedCameraLocation == 'ทั้งหมด' ||
          report['camera_location'] == selectedCameraLocation;

      return matchesSearch && matchesAgency && matchesLocation;
    }).toList();
  }

  void _showFilterDialog(BuildContext context, List<String> options,
      String title, Function(String?) onSelected) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length + 1,
              itemBuilder: (context, index) {
                String option = index == 0 ? 'ทั้งหมด' : options[index - 1];
                return ListTile(
                  title: Text(option),
                  onTap: () {
                    onSelected(option == 'ทั้งหมด' ? null : option);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _getFilteredReports();
    return Scaffold(
      appBar: AppBar(
        title: Text('รายงานสาเหตุอุบัติเหตุ'),
        backgroundColor: Color(0xFF4B39EF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard(
                  'รายงานทั้งหมด',
                  filteredReports.length.toString(),
                  Icons.list,
                  Colors.blue,
                ),
                GestureDetector(
                  onTap: () {
                    _showFilterDialog(
                      context,
                      agencies,
                      'เลือกหน่วยงาน',
                      (selected) {
                        setState(() {
                          selectedAgency = selected;
                        });
                      },
                    );
                  },
                  child: _buildSummaryCard(
                    selectedAgency == null ? 'ทั้งหมด' : selectedAgency!,
                    'หน่วยงาน',
                    Icons.business,
                    Colors.orange,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showFilterDialog(
                      context,
                      cameraLocations,
                      'เลือกสถานที่ตั้งกล้อง',
                      (selected) {
                        setState(() {
                          selectedCameraLocation = selected;
                        });
                      },
                    );
                  },
                  child: _buildSummaryCard(
                    selectedCameraLocation == null
                        ? 'ทั้งหมด'
                        : selectedCameraLocation!,
                    'สถานที่',
                    Icons.location_on,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Search Field
            TextField(
              decoration: InputDecoration(
                labelText: 'ค้นหา',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // List of Reports
            Expanded(
              child: ListView.builder(
                itemCount: filteredReports.length,
                itemBuilder: (context, index) {
                  final report = filteredReports[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report['reason'] ?? 'ไม่ทราบสาเหตุ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.description, color: Color(0xFF4B39EF)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'รายละเอียด: ${report['details'] ?? 'ไม่มีข้อมูล'}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.business, color: Color(0xFF4B39EF)),
                              const SizedBox(width: 8),
                              Text(
                                'หน่วยงาน: ${report['agency'] ?? 'ไม่ทราบหน่วยงาน'}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF4B39EF)),
                              const SizedBox(width: 8),
                              Text(
                                'สถานที่ตั้งกล้อง: ${report['camera_location'] ?? 'ไม่ทราบสถานที่'}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.date_range, color: Color(0xFF4B39EF)),
                              const SizedBox(width: 8),
                              Text(
                                'วันที่บันทึก: ${report['recorded_at'] ?? 'ไม่ทราบวันที่'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Summary Card Builder
  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
