import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class ConfirmAccident extends StatefulWidget {
  final int notificationId;
  final Function onConfirm;
  final Function onDelete;

  const ConfirmAccident({
    Key? key,
    required this.notificationId,
    required this.onConfirm,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ConfirmAccidentState createState() => _ConfirmAccidentState();
}

class _ConfirmAccidentState extends State<ConfirmAccident> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? videoUrl;
  String? selectedValue;
  Map<String, dynamic>? notificationDetails;

  @override
  void initState() {
    super.initState();
    _fetchNotificationDetails();
  }

  Future<void> _fetchNotificationDetails() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.1.247:5000/get_notification_details?id=${widget.notificationId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notificationDetails = data;
          videoUrl = 'http://192.168.1.247:5000/${data['video_path']}';
          _isLoading = false;
        });

        if (videoUrl != null && videoUrl!.isNotEmpty) {
          _controller = VideoPlayerController.network(videoUrl!)
            ..initialize().then((_) {
              setState(() {
                _controller!.play();
              });
            }).catchError((error) {
              print('Error initializing video: $error');
              setState(() {
                _isLoading = false;
              });
            });
        }
      } else {
        print('Failed to load notification details');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching notification details: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> confirmNotification() async {
    try {
      // ดึงอีเมลจาก SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('userEmail') ?? '';

      final response = await http.post(
        Uri.parse('http://192.168.1.247:5000/update-status'),
        body: json.encode({
          'id': widget.notificationId,
          'status': 'confirmed',
          'confirmed_by': userEmail, // ส่ง email ของผู้ใช้ที่ทำการยืนยัน
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Notification confirmed');
        widget.onConfirm(widget.notificationId);
      } else {
        print('Failed to confirm notification');
      }
    } catch (error) {
      print('Error confirming notification: $error');
    }
  }

  Future<void> deleteNotification() async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.247:5000/delete-notification'),
        body: json.encode({
          'id': widget.notificationId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Notification deleted');
        widget.onDelete(widget.notificationId);
      } else {
        print('Failed to delete notification');
      }
    } catch (error) {
      print('Error deleting notification: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ยืนยันอุบัติเหตุ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _controller != null &&
                                _controller!.value.isInitialized
                            ? VideoPlayer(_controller!)
                            : Center(
                                child: Text(
                                  'Failed to load video',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Information Section
                    if (notificationDetails != null) ...[
                      Text(
                        notificationDetails!['camera_location'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ผลการตรวจจับภาพ , อุบัติเหตุ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notificationDetails!['cut_timestamp'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Radio Buttons for confirmation
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('อุบัติเหตุ'),
                                  value: 'อุบัติเหตุ',
                                  groupValue: selectedValue,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedValue = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text('ไม่ใช่อุบัติเหตุ'),
                                  value: 'ไม่ใช่อุบัติเหตุ',
                                  groupValue: selectedValue,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedValue = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  selectedValue != null ? _confirmAction : null,
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'ยืนยัน',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }

  void _confirmAction() {
    if (selectedValue == 'อุบัติเหตุ') {
      confirmNotification();
    } else if (selectedValue == 'ไม่ใช่อุบัติเหตุ') {
      deleteNotification();
    }
    Navigator.pop(context);
  }
}
