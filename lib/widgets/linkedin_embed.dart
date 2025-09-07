import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/linkedin_utils.dart';

class LinkedInEmbed extends StatefulWidget {
  const LinkedInEmbed({
    super.key,
    required this.embedUrl,
    this.width,
    this.height,
    this.backgroundColor,
    this.showOpenInBrowser = true,
  });

  /// Example: https://www.linkedin.com/embed/feed/update/urn:li:ugcPost:7370138266773258240
  final String embedUrl;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final bool showOpenInBrowser;

  @override
  State<LinkedInEmbed> createState() => _LinkedInEmbedState();
}

class _LinkedInEmbedState extends State<LinkedInEmbed> {
  WebViewController? _controller;
  late final String? _normalizedUrl;

  String? _extractUrl(String input) {
    final trimmed = input.trim();

    // If it's a LinkedIn post in any common format, convert it to the official embed URL
    final liEmbed = LinkedInUtils.toEmbedUrl(trimmed);
    if (liEmbed != null) {
      return liEmbed;
    }
    // If input is a full iframe HTML, extract src="..."
    final iframeRegex =
        RegExp(r'<iframe[^>]*src="([^"]+)"[^>]*>', caseSensitive: false);
    final match = iframeRegex.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    // If looks like a URL already
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    // If starts with // or no scheme, prepend https
    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }
    if (trimmed.isNotEmpty && !trimmed.contains(' ')) {
      return 'https://$trimmed';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _normalizedUrl = _extractUrl(widget.embedUrl);
    if (!kIsWeb) {
      if (_normalizedUrl != null) {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.transparent)
          ..setNavigationDelegate(NavigationDelegate(
            onNavigationRequest: (request) {
              // Keep user on the embedded post; external opens via the overlay button
              if (request.url == _normalizedUrl) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ))
          ..loadRequest(Uri.parse(_normalizedUrl!));
        _controller = controller;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? MediaQuery.of(context).size.width;
    final height = widget.height ?? 600;

    if (_normalizedUrl == null) {
      return Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        color: widget.backgroundColor ?? Colors.transparent,
        child: const Text('Unable to render embed: invalid URL/iframe.'),
      );
    }

    if (kIsWeb) {
      // On Flutter Web, use flutter_html to inject the iframe directly.
      final iframe = '<iframe '
          'src="$_normalizedUrl" '
          'width="${width.toInt()}" '
          'height="${height.toInt()}" '
          'style="border:0;" '
          'loading="lazy" '
          'referrerpolicy="no-referrer-when-downgrade" '
          'allow="encrypted-media; clipboard-write; fullscreen; picture-in-picture" '
          'frameborder="0" '
          'allowfullscreen '
          'title="Embedded post"></iframe>';
      return Container(
        width: width,
        height: height,
        color: widget.backgroundColor ?? Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(child: Html(data: iframe)),
            if (widget.showOpenInBrowser)
              Positioned(
                top: 8,
                right: 8,
                child: _OpenInBrowserButton(url: _normalizedUrl!),
              ),
          ],
        ),
      );
    }

    // On mobile/desktop platforms, use an in-app WebView to load the embed URL directly.
    return Container(
      width: width,
      height: height,
      color: widget.backgroundColor ?? Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: _controller == null
                ? const Center(child: CircularProgressIndicator())
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: WebViewWidget(controller: _controller!),
                  ),
          ),
          if (widget.showOpenInBrowser && _normalizedUrl != null)
            Positioned(
              top: 8,
              right: 8,
              child: _OpenInBrowserButton(url: _normalizedUrl!),
            ),
        ],
      ),
    );
  }
}

class _OpenInBrowserButton extends StatelessWidget {
  const _OpenInBrowserButton({
    required this.url,
  });

  final String url;

  Future<void> _open() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(24),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.open_in_new, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
