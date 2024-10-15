import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _historyData = [];

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.10.58.123:5000/get-history'), // เปลี่ยนเป็น URL ของ API จริง
      );

      if (response.statusCode == 200) {
        setState(() {
          _historyData = json.decode(response.body);
        });
      } else {
        print('Failed to load history data');
      }
    } catch (e) {
      print('Error fetching history data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ประวัติ'),
        centerTitle: true,
      ),
      body: _historyData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _historyData.length,
              itemBuilder: (context, index) {
                final historyItem = _historyData[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text('สาเหตุ: ${historyItem['reason']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('รายละเอียด: ${historyItem['details']}'),
                        Text('วันที่: ${historyItem['date_added']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
