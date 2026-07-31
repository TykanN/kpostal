import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders the Kakao postcode page using the `webview_flutter` package.
///
/// This widget is only mounted once the target page is ready to load (e.g.
/// after the local server has started), so it loads [targetUri] immediately in
/// [initState].
class KpostalWebViewFlutter extends StatefulWidget {
  const KpostalWebViewFlutter({
    super.key,
    required this.targetUri,
    required this.onMessage,
    required this.onLoadComplete,
  });

  /// The URL of the Kakao postcode page to load.
  final Uri targetUri;

  /// Called with the JSON payload posted from the page's `onComplete` channel.
  final void Function(String? message) onMessage;

  /// Called when the page finishes loading.
  final VoidCallback onLoadComplete;

  @override
  State<KpostalWebViewFlutter> createState() => _KpostalWebViewFlutterState();
}

class _KpostalWebViewFlutterState extends State<KpostalWebViewFlutter> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      // The HTML bridges the selected address back through
      // `onComplete.postMessage(message)`, which maps directly to this channel.
      ..addJavaScriptChannel(
        'onComplete',
        onMessageReceived: (JavaScriptMessage message) =>
            widget.onMessage(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => widget.onLoadComplete(),
        ),
      )
      ..loadRequest(widget.targetUri);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
