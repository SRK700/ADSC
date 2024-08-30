import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ConfirmAccident extends StatefulWidget {
  @override
  _ConfirmAccidentState createState() => _ConfirmAccidentState();
}

class _ConfirmAccidentState extends State<ConfirmAccident> {
  late VideoPlayerController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // สมมติว่า URL วิดีโอที่ได้รับจากระบบเป็นแบบนี้:
    final videoUrl = 'https://your-api-endpoint.com/accident_video.mp4';

    // กำหนด VideoPlayerController
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ยืนยันอุบัติเหตุ')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // แสดง loading ขณะรอการโหลดวิดีโอ
            : AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
