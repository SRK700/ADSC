import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AccidentReportList extends StatefulWidget {
  const AccidentReportList({Key? key}) : super(key: key);

  @override
  _AccidentReportListState createState() => _AccidentReportListState();
}

class _AccidentReportListState extends State<AccidentReportList> {
  Future<List<dynamic>> fetchAccidentReports() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:81/adscAPI/get-accident-reports.php'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load accident reports');
        return [];
      }
    } catch (e) {
      print('Error fetching accident reports: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchAccidentReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('ไม่มีรายงานสาเหตุอุบัติเหตุ'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final report = snapshot.data![index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                      Text(
                        'รายละเอียด: ${report['details'] ?? 'ไม่มีข้อมูล'}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'หน่วยงาน: ${report['agency'] ?? 'ไม่ทราบหน่วยงาน'}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'วันที่บันทึก: ${report['recorded_at'] ?? 'ไม่ทราบวันที่'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
