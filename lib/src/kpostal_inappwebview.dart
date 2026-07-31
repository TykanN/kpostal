import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Renders the Kakao postcode page using the `flutter_inappwebview` package.
class KpostalInAppWebView extends StatelessWidget {
  const KpostalInAppWebView({
    super.key,
    required this.targetUri,
    required this.onMessage,
    required this.onLoadComplete,
  });

  /// The URL of the Kakao postcode page to load.
  final Uri targetUri;

  /// Called with the JSON payload posted from the page's `onComplete` bridge.
  final void Function(String? message) onMessage;

  /// Called when the page finishes loading.
  final VoidCallback onLoadComplete;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialSettings: InAppWebViewSettings(
        useHybridComposition: true,
        javaScriptEnabled: true,
      ),
      onWebViewCreated: (controller) async {
        // 안드로이드는 롤리팝 버전 이상 빌드에서만 작동 유의
        // WEB_MESSAGE_LISTENER 지원 여부 확인
        if (!Platform.isAndroid ||
            await WebViewFeature.isFeatureSupported(
                WebViewFeature.WEB_MESSAGE_LISTENER)) {
          await controller.addWebMessageListener(
            WebMessageListener(
              jsObjectName: "onComplete",
              allowedOriginRules: {"*"},
              onPostMessage:
                  (message, sourceOrigin, isMainFrame, replyProxy) =>
                      onMessage(message?.data.toString()),
            ),
          );
        } else {
          controller.addJavaScriptHandler(
            handlerName: 'onComplete',
            callback: (args) => onMessage(args[0]),
          );
        }

        await controller.loadUrl(
          urlRequest: URLRequest(
            url: WebUri.uri(targetUri),
          ),
        );
      },
      onLoadStop: (_, __) => onLoadComplete(),
    );
  }
}
