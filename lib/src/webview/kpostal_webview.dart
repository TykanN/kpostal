/// 플랫폼별 웹뷰 구현을 선택하는 conditional export.
///
/// - io(Android/iOS/macOS): `webview_flutter` 기반
/// - web: iframe + `window.postMessage` 기반
library;

export 'kpostal_webview_io.dart'
    if (dart.library.js_interop) 'kpostal_webview_web.dart';
