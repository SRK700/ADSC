import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AccidentStatistics extends StatefulWidget {
  @override
  _AccidentStatisticsState createState() => _AccidentStatisticsState();
}

class _AccidentStatisticsState extends State<AccidentStatistics> {
  List<dynamic> accidentStatistics = [];

  @override
  void initState() {
    super.initState();
    fetchAccidentStatistics();
  }

  Future<void> fetchAccidentStatistics() async {
    final response = await http.get(
        Uri.parse('http://localhost:81/adscAPI/allAccidentStatistics.php'));

    if (response.statusCode == 200) {
      setState(() {
        accidentStatistics = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load statistics');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'สถิติอุบัติเหตุ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.blue.withOpacity(0.5),
      ),
      body: accidentStatistics.isEmpty
          ? Center(
              child: CircularProgressIndicator(), // Loading indicator
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: accidentStatistics.length,
                itemBuilder: (context, index) {
                  return _buildStatCard(
                    accidentStatistics[index]['reason'],
                    accidentStatistics[index]['count'].toString(),
                  );
                },
              ),
            ),
    );
  }

  // Method to build each statistic card
  Widget _buildStatCard(String reason, String count) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon representing the accident reason
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.blueAccent,
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            // Main content of the card
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'จำนวนครั้ง: $count',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Additional detail or action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
