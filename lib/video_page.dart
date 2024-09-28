import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPage extends StatefulWidget {
  final String videoUrl;

  const VideoPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadAndPlayVideo();
  }

  Future<void> _downloadAndPlayVideo() async {
    final videoFile =
        await _downloadFile(widget.videoUrl, 'downloaded_video.mp4');
    if (videoFile != null) {
      _controller = VideoPlayerController.file(videoFile)
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
          });
          _controller.play();
        });
    }
  }

  Future<File?> _downloadFile(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        return file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download video');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
    );
  }
}
