import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../theme/app_colors.dart';

class ExerciseVideoScreen extends StatefulWidget {
  final String title;
  final String videoId;

  const ExerciseVideoScreen({
    super.key,
    required this.title,
    required this.videoId,
  });

  @override
  State<ExerciseVideoScreen> createState() => _ExerciseVideoScreenState();
}

class _ExerciseVideoScreenState extends State<ExerciseVideoScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final embedUrl =
        'https://www.youtube.com/embed/${widget.videoId}?autoplay=1&rel=0&controls=1&modestbranding=1&playsinline=1';

    _controller = WebViewController();
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    _controller.loadRequest(Uri.parse(embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

