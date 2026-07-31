/// Selects which WebView package [KpostalView] renders the Kakao postcode
/// page with.
///
/// [KpostalView]가 카카오 우편번호 페이지를 렌더링할 때 사용할 WebView 패키지를 선택합니다.
enum KpostalWebview {
  /// Uses the official [`webview_flutter`](https://pub.dev/packages/webview_flutter)
  /// package. This is the default.
  webviewFlutter,

  /// Uses the [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview)
  /// package.
  inappWebview,
}
