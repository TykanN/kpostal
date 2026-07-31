import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:kpostal/src/log.dart';
import 'package:web/web.dart' as web;

/// iframe + `window.postMessage` 기반 웹뷰 구현. (Web)
///
/// 검색 페이지를 iframe으로 띄우고, 페이지에서 `window.parent.postMessage`로
/// 전달한 주소 결과를 message 이벤트로 수신합니다.
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
  static int _viewCounter = 0;

  final String _viewType = 'kpostal-webview-${_viewCounter++}';
  StreamSubscription<web.MessageEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    if (widget.useLocalServer) {
      log('useLocalServer is not supported on the web and will be ignored.');
    }

    final web.HTMLIFrameElement iframe = web.HTMLIFrameElement()
      ..src = widget.targetUri.toString()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    web.EventStreamProviders.loadEvent
        .forTarget(iframe)
        .listen((_) => widget.onLoadFinished());

    ui_web.platformViewRegistry
        .registerViewFactory(_viewType, (int viewId) => iframe);

    _subscription = web.EventStreamProviders.messageEvent
        .forTarget(web.window)
        .listen((web.MessageEvent event) {
      // 검색 페이지 외 출처의 postMessage는 무시합니다.
      if (event.origin != widget.targetUri.origin) return;
      final JSAny? data = event.data;
      if (data.isA<JSString>()) {
        widget.onMessage((data as JSString).toDart);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
