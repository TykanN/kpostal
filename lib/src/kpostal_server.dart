import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:kpostal/src/log.dart';

/// 번들된 카카오 우편번호 HTML 에셋을 서빙하는 경량 localhost HTTP 서버.
///
/// `webview_flutter`는 `flutter_inappwebview`의 `InAppLocalhostServer` 같은
/// 로컬 서버를 제공하지 않아 이를 대체합니다. 카카오 지오코더 JS SDK는
/// 카카오 개발자 콘솔에 등록된 도메인(예: `http://localhost:8080`)에서만
/// 동작하므로 실제 `http://localhost` 출처로 서빙해야 합니다.
class KpostalServer {
  KpostalServer({
    this.host = 'localhost',
    this.port = 8080,
    this.assetPath = 'packages/kpostal/assets/kakao_postcode_localhost.html',
  });

  final String host;

  final int port;

  /// 서빙할 HTML 페이지의 Flutter 에셋 경로
  final String assetPath;

  HttpServer? _server;

  bool get isRunning => _server != null;

  /// 서버를 시작합니다. 이미 실행 중이면 아무것도 하지 않습니다.
  Future<void> start() async {
    if (_server != null) return;

    final String html = await rootBundle.loadString(assetPath);

    final HttpServer server = await HttpServer.bind(host, port, shared: true);
    _server = server;

    server.listen((HttpRequest request) async {
      request.response.headers.contentType = ContentType.html;
      request.response.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
      request.response.write(html);
      await request.response.close();
    });

    log('KpostalServer started at http://$host:$port');
  }

  /// 서버를 종료합니다.
  Future<void> close() async {
    await _server?.close(force: true);
    _server = null;
    log('KpostalServer closed');
  }
}
