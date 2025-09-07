import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/app_theme.dart';

class WebViewScreen extends HookWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  // Helper method to ensure URL has proper scheme
  String _ensureUrlScheme(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    // Default to https for URLs without scheme
    return 'https://$url';
  }

  // Helper method to open URL in browser
  Future<void> _launchUrl(String urlString) async {
    final String properUrl = _ensureUrlScheme(urlString);
    final Uri url = Uri.parse(properUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $properUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if running on web
    if (kIsWeb) {
      // For web, show an enhanced UI with preview and buttons
      return Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.95),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Iconsax.share, color: Colors.white),
              onPressed: () async {
                await Share.share(url, subject: title);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Website preview card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Website header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppTheme.borderRadius),
                              topRight: Radius.circular(AppTheme.borderRadius),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Iconsax.global,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      Uri.parse(_ensureUrlScheme(url)).host,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Website content preview
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.only(
                              bottomLeft:
                                  Radius.circular(AppTheme.borderRadius),
                              bottomRight:
                                  Radius.circular(AppTheme.borderRadius),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.document,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Website Preview',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // URL information
                  const Text(
                    'Website URL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            url,
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Iconsax.copy,
                            size: 20,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: url));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('URL copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Iconsax.export),
                          label: const Text('Open in Browser'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadius,
                              ),
                            ),
                          ),
                          onPressed: () {
                            _launchUrl(url);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Iconsax.arrow_left),
                      label: const Text('Go Back'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Security note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.shield_tick,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This link will open in your default browser for security and compatibility reasons.',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 14,
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
        ),
      );
    }

    // State hooks for mobile
    final isLoading = useState(true);
    final progress = useState(0.0);
    final currentTitle = useState(title);
    final isBottomBarVisible = useState(true);
    final scrollController = useScrollController();
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: 1.0,
    );

    // Create a ValueNotifier to store the controller
    final webViewControllerNotifier = useState<WebViewController?>(null);

    // Initialize the controller
    useEffect(() {
      // Create a new controller
      final newController = WebViewController();

      // Configure the controller
      newController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              isLoading.value = true;
            },
            onProgress: (int progressValue) {
              progress.value = progressValue / 100;
            },
            onPageFinished: (String url) async {
              isLoading.value = false;
              final pageTitle = await newController.getTitle();
              if (pageTitle != null && pageTitle.isNotEmpty) {
                currentTitle.value = pageTitle;
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(_ensureUrlScheme(url)));

      // Update the controller notifier
      webViewControllerNotifier.value = newController;

      return null;
    }, []);

    // Effect for scroll listener to show/hide bottom bar
    useEffect(() {
      void listener() {
        // Check scroll direction
        final direction = scrollController.position.userScrollDirection;
        final shouldShow = direction == ScrollDirection.idle ||
            direction == ScrollDirection.forward;

        if (shouldShow != isBottomBarVisible.value) {
          isBottomBarVisible.value = shouldShow;
          if (shouldShow) {
            animationController.forward();
          } else {
            animationController.reverse();
          }
        }
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController]);

    // Get the controller from the notifier
    final webViewController = webViewControllerNotifier.value;

    // If controller is not yet initialized, show loading indicator
    if (webViewController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Mobile WebView implementation
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          currentTitle.value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        actions: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            IconButton(
              icon: const Icon(Iconsax.refresh, color: Colors.black),
              onPressed: () {
                webViewController.reload();
              },
            ),
            IconButton(
              icon: const Icon(Iconsax.share, color: Colors.black),
              onPressed: () async {
                final currentUrl = await webViewController.currentUrl();
                if (currentUrl != null) {
                  await Share.share(currentUrl, subject: currentTitle.value);
                }
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Animated progress indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isLoading.value ? 3 : 0,
              child: LinearProgressIndicator(
                value: progress.value,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
              ),
            ),
            // WebView
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadius),
                  topRight: Radius.circular(AppTheme.borderRadius),
                ),
                child: WebViewWidget(controller: webViewController),
              ),
            ),
            // Animated bottom navigation bar
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return SizeTransition(
                  sizeFactor: animationController,
                  axisAlignment: -1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.largeBorderRadius),
                        topRight: Radius.circular(AppTheme.largeBorderRadius),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 375),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            _buildNavButton(
                              icon: Iconsax.arrow_left,
                              onPressed: () async {
                                if (await webViewController.canGoBack()) {
                                  await webViewController.goBack();
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            _buildNavButton(
                              icon: Iconsax.home,
                              onPressed: () {
                                webViewController.loadRequest(
                                    Uri.parse(_ensureUrlScheme(url)));
                              },
                            ),
                            _buildNavButton(
                              icon: Iconsax.copy,
                              onPressed: () async {
                                final currentUrl =
                                    await webViewController.currentUrl();
                                if (currentUrl != null) {
                                  await Clipboard.setData(
                                      ClipboardData(text: currentUrl));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('URL copied to clipboard'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                            _buildNavButton(
                              icon: Iconsax.arrow_right,
                              onPressed: () async {
                                if (await webViewController.canGoForward()) {
                                  await webViewController.goForward();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: AppTheme.primaryColor,
        iconSize: 22,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
