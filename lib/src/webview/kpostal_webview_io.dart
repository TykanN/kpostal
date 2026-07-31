import 'package:flutter/material.dart';
import 'package:kpostal/src/kpostal_server.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// `webview_flutter` 기반 웹뷰 구현. (Android/iOS/macOS)
class KpostalWebView extends StatefulWidget {
  const KpostalWebView({
    super.key,
    required this.targetUri,
    required this.useLocalServer,
    required this.localPort,
    required this.onMessage,
    required this.onLoadFinished,
  });

  final Uri targetUri;
  final bool useLocalServer;
  final int localPort;
  final void Function(String? message) onMessage;
  final VoidCallback onLoadFinished;

  @override
  State<KpostalWebView> createState() => _KpostalWebViewState();
}

class _KpostalWebViewState extends State<KpostalWebView> {
  late final WebViewController _controller;
  KpostalServer? _localhost;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      // HTML에서 `onComplete.postMessage(message)`로 선택한 주소를 전달합니다.
      ..addJavaScriptChannel(
        'onComplete',
        onMessageReceived: (JavaScriptMessage message) =>
            widget.onMessage(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => widget.onLoadFinished()),
      );
    _load();
  }

  Future<void> _load() async {
    if (widget.useLocalServer) {
      _localhost = KpostalServer(port: widget.localPort);
      await _localhost!.start();
    }
    await _controller.loadRequest(widget.targetUri);
  }

  @override
  void dispose() {
    _localhost?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
