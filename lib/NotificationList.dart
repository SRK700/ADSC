import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ConfirmAccident.dart'; // นำเข้าหน้า ConfirmAccident
import 'DetailFrome.dart'; // หน้าที่ใช้สำหรับเพิ่มสาเหตุ
import 'package:intl/intl.dart';

class NotificationList extends StatefulWidget {
  final bool showConfirmed;

  const NotificationList({Key? key, required this.showConfirmed})
      : super(key: key);

  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  // ฟังก์ชันสำหรับดึงข้อมูลจาก API
  Future<List<dynamic>> fetchNotifications() async {
    final response =
        await http.get(Uri.parse('http://10.10.36.226:5000/get-notifications'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // ฟังก์ชันสำหรับแปลงรูปแบบเวลาที่แสดง
  String formatDateTime(String dateTime) {
    try {
      DateFormat inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
      DateFormat outputFormat = DateFormat('dd/MM/yyyy HH:mm');
      DateTime parsedDate = inputFormat.parse(dateTime);
      return outputFormat.format(parsedDate);
    } catch (e) {
      return 'Invalid date';
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
          // กรองข้อมูลการแจ้งเตือนตามสถานะ
          final notifications = snapshot.data!.where((notification) {
            if (widget.showConfirmed) {
              return notification['status'] == 'confirmed';
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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // เพิ่มมุมโค้ง
                  ),
                  elevation: 3, // ลดเงาลงเพื่อให้ดูนุ่มนวล
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ตรวจพบเหตุการณ์ซึ่งสันนิษฐานว่าเป็นอุบัติเหตุ',
                          style: TextStyle(
                            fontSize: 16, // ลดขนาดฟอนต์เล็กน้อย
                            fontWeight:
                                FontWeight.w600, // เปลี่ยนความหนาของฟอนต์
                            color: Colors.black, // ใช้สีดำเพื่อความคมชัด
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification['camera_location'],
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors
                                .deepPurple, // ใช้สีที่เข้มขึ้นสำหรับชื่อสถานที่
                            fontWeight:
                                FontWeight.bold, // เพิ่มความหนาเพื่อความชัดเจน
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDateTime(notification['cut_timestamp']),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800, // ใช้สีที่เข้มขึ้น
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ปุ่มยืนยันหรือรอการตรวจสอบ
                            ElevatedButton.icon(
                              onPressed: widget.showConfirmed
                                  ? null // Disable if already confirmed
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ConfirmAccident(
                                            notificationId: notification['id'],
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
                                  color: Colors
                                      .white, // สีของข้อความเป็นสีขาวเพื่อความคมชัด
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.showConfirmed
                                    ? Color.fromARGB(255, 185, 58,
                                        181) // สีเขียวสำหรับปุ่ม "ยืนยันแล้ว"
                                    : Colors.blue.shade600,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10, // ปรับขนาดปุ่มให้กระชับขึ้น
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                shadowColor: Colors.black.withOpacity(0.3),
                                elevation: 4,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // ปุ่มเพิ่มสาเหตุ
                            if (widget.showConfirmed)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsFormWidget(
                                        notificationId: notification['id'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'เพิ่มสาเหตุ',
                                  style: TextStyle(
                                    fontSize: 14, // ลดขนาดฟอนต์ให้พอดีกับปุ่ม
                                    fontWeight: FontWeight.w600,
                                    color: Colors
                                        .white, // สีของข้อความเป็นสีขาวเพื่อความคมชัด
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 237, 46,
                                      237), // สีเขียวสำหรับปุ่ม "ยืนยันแล้ว"
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  shadowColor: Colors.black.withOpacity(0.3),
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
        }
      },
    );
  }
}
