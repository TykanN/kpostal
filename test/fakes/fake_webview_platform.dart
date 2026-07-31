import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// 위젯 테스트용 fake `WebViewPlatform`.
///
/// 생성된 컨트롤러를 [lastController]로 노출해 loadRequest URI 검증,
/// JS 채널 메시지/페이지 로드 완료 이벤트 트리거에 사용합니다.
class FakeWebViewPlatform extends WebViewPlatform {
  FakeWebViewController? lastController;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return lastController = FakeWebViewController(params);
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) {
    return FakeNavigationDelegate(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return FakeWebViewWidget(params);
  }
}

class FakeWebViewController extends PlatformWebViewController {
  FakeWebViewController(super.params) : super.implementation();

  final List<Uri> loadedRequests = [];
  final Map<String, JavaScriptChannelParams> channels = {};
  FakeNavigationDelegate? navigationDelegate;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {
    channels[javaScriptChannelParams.name] = javaScriptChannelParams;
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {
    navigationDelegate = handler as FakeNavigationDelegate;
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    loadedRequests.add(params.uri);
  }

  /// HTML 쪽 `onComplete.postMessage(message)` 수신을 시뮬레이트합니다.
  void receiveMessage(String message) {
    channels['onComplete']!.onMessageReceived(
      JavaScriptMessage(message: message),
    );
  }

  /// 페이지 로드 완료를 시뮬레이트합니다.
  void finishPageLoad() {
    navigationDelegate?.pageFinishedCallback?.call('about:blank');
  }
}

class FakeNavigationDelegate extends PlatformNavigationDelegate {
  FakeNavigationDelegate(super.params) : super.implementation();

  PageEventCallback? pageFinishedCallback;

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {
    pageFinishedCallback = onPageFinished;
  }
}

class FakeWebViewWidget extends PlatformWebViewWidget {
  FakeWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
