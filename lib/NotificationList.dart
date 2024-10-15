import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ConfirmAccident.dart'; // Import for the ConfirmAccident page
import 'DetailFrome.dart'; // Import for the page to add reasons
import 'package:intl/intl.dart';

class NotificationList extends StatefulWidget {
  final bool showConfirmed;
  final String email; // Add email parameter to identify the user

  const NotificationList({
    Key? key,
    required this.showConfirmed,
    required this.email,
  }) : super(key: key);

  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  // Fetch notifications from the API
  Future<List<dynamic>> fetchNotifications() async {
    final response =
        await http.get(Uri.parse('http://10.10.58.123:5000/get-notifications'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<String?> fetchReason(int notificationId) async {
    final response = await http.get(
      Uri.parse(
          'http://10.10.58.123:5000/get-reason?notification_id=$notificationId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched reason: $data'); // Debugging line
      if (data != null && data.isNotEmpty) {
        return data['reason']; // Retrieve the reason from the response
      }
    }
    return null; // Return null if there is no reason
  }

  // ฟังก์ชันสำหรับแปลงรูปแบบเวลาที่แสดง
  String formatDateTime(String dateTime) {
    try {
      // ลองแปลงวันที่แบบตรง ๆ ก่อน
      DateTime parsedDate = DateTime.parse(dateTime);
      DateFormat outputFormat = DateFormat('dd/MM/yyyy HH:mm');
      return outputFormat.format(parsedDate);
    } catch (e) {
      // ถ้าเกิดข้อผิดพลาด ลองใช้รูปแบบที่กำหนดเอง
      try {
        DateFormat inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
        DateTime parsedDate = inputFormat.parse(dateTime);
        DateFormat outputFormat = DateFormat('dd/MM/yyyy HH:mm');
        return outputFormat.format(parsedDate);
      } catch (e) {
        return 'Invalid date'; // กรณีที่แปลงรูปแบบไม่ได้จริง ๆ
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('ไม่มีรายการแจ้งเตือน'));
        } else {
          // Filter notifications based on their status and email
          final notifications = snapshot.data!.where((notification) {
            if (widget.showConfirmed) {
              // แสดงเฉพาะการแจ้งเตือนที่เป็น confirmed และอีเมลของผู้ใช้ปัจจุบันเท่านั้น
              return notification['status'] == 'confirmed' &&
                  notification['confirmed_by'] == widget.email;
            } else {
              return notification['status'] == 'pending';
            }
          }).toList();

          if (notifications.isEmpty) {
            return Center(child: Text('ไม่มีรายการแจ้งเตือนในสถานะนี้'));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return FutureBuilder<String?>(
                future: notification['is_reason_added'] == 1
                    ? fetchReason(notification['id'])
                    : Future.value(null), // Fetch reason only if it's added
                builder: (context, reasonSnapshot) {
                  String? reasonTag = reasonSnapshot.data;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 3,
                      shadowColor: Colors.black.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orangeAccent,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ตรวจพบเหตุการณ์ซึ่งสันนิษฐานว่าเป็นอุบัติเหตุ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.deepPurple,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  notification['camera_location'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.grey.shade800,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  formatDateTime(notification['cut_timestamp']),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Show the reason tag only if a reason is added
                            if (reasonTag != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  reasonTag,
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Confirm or Pending Button
                                ElevatedButton.icon(
                                  onPressed: widget.showConfirmed
                                      ? null // Disable if already confirmed
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ConfirmAccident(
                                                notificationId:
                                                    notification['id'],
                                                onConfirm: (id) {
                                                  print(
                                                      "Confirmed notification: $id");
                                                },
                                                onDelete: (id) {
                                                  print(
                                                      "Deleted notification: $id");
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                  icon: Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    widget.showConfirmed
                                        ? 'ยืนยันแล้ว'
                                        : 'รอการตรวจสอบ',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.showConfirmed
                                        ? Colors.green.shade600
                                        : Colors.blue.shade600,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    shadowColor: Colors.black.withOpacity(0.3),
                                    elevation: 4,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Add Reason Button
                                if (widget.showConfirmed)
                                  ElevatedButton(
                                    onPressed: reasonTag != null
                                        ? null // Disable if reason is already added
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailsFormWidget(
                                                  notificationId:
                                                      notification['id'],
                                                ),
                                              ),
                                            );
                                          },
                                    child: Text(
                                      'เพิ่มสาเหตุ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: reasonTag != null
                                          ? Colors.grey
                                          : Color.fromARGB(255, 237, 46, 237),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      shadowColor:
                                          Colors.black.withOpacity(0.3),
                                      elevation: 4,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
