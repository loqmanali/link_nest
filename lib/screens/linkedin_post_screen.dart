import 'package:flutter/material.dart';

import '../widgets/linkedin_embed.dart';

class LinkedInPostScreen extends StatelessWidget {
  static const String routeName = '/linkedin-post';
  const LinkedInPostScreen({
    super.key,
    required this.embedUrl,
    this.title,
  });

  /// Example: https://www.linkedin.com/embed/feed/update/urn:li:ugcPost:7370138266773258240
  final String embedUrl;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'LinkedIn Post'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ConstrainedBox(
                //   constraints: const BoxConstraints(maxWidth: 600),
                //   child: const Text(
                //     'Embedded LinkedIn Post',
                //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: LinkedInEmbed(
                    embedUrl: embedUrl,
                    // LinkedIn embeds often need a tall height; adjust as needed
                    height: 900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
