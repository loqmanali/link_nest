import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'linkedin_embed.dart';

class GenericEmbed extends StatefulWidget {
  const GenericEmbed({
    super.key,
    required this.embedUrl,
    this.width,
    this.height,
    this.backgroundColor,
  });

  final String embedUrl;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  @override
  State<GenericEmbed> createState() => _GenericEmbedState();
}

class _GenericEmbedState extends State<GenericEmbed> {
  WebViewController? _controller;

  bool get _isLinkedIn => widget.embedUrl.contains('linkedin.com');

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && !_isLinkedIn) {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..loadRequest(Uri.parse(widget.embedUrl));
      _controller = controller;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? MediaQuery.of(context).size.width;
    final height = widget.height ?? 600;

    if (_isLinkedIn) {
      // Delegate to specialized LinkedIn embed to handle quirks per platform
      return LinkedInEmbed(
        embedUrl: widget.embedUrl,
        width: width,
        height: height,
        backgroundColor: widget.backgroundColor,
      );
    }

    if (kIsWeb) {
      // Try to render a generic iframe on web
      final iframe =
          '<iframe src="${widget.embedUrl}" width="${width.toInt()}" height="${height.toInt()}" frameborder="0" allowfullscreen title="Embedded content"></iframe>';
      return Container(
        width: width,
        height: height,
        color: widget.backgroundColor ?? Colors.transparent,
        child: Html(data: iframe),
      );
    }

    // Mobile/desktop fallback via WebView
    return Container(
      width: width,
      height: height,
      color: widget.backgroundColor ?? Colors.transparent,
      child: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: WebViewWidget(controller: _controller!),
            ),
    );
  }
}
