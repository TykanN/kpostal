import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:kpostal/src/log.dart';

/// A minimal localhost HTTP server that serves the bundled Kakao postcode
/// HTML asset.
///
/// [webview_flutter] does not provide a localhost server like
/// `flutter_inappwebview`'s `InAppLocalhostServer`, so this lightweight
/// server replaces it. Serving the page from a real `http://localhost` origin
/// is required for the Kakao geocoder, whose JavaScript SDK only runs on
/// domains registered in the Kakao Developers console (e.g. `http://localhost:8080`).
///
/// [webview_flutter]는 `flutter_inappwebview`의 `InAppLocalhostServer`와 같은
/// 로컬 서버를 제공하지 않기 때문에, 이를 대체하기 위한 경량 서버입니다.
class KpostalServer {
  KpostalServer({
    this.host = 'localhost',
    this.port = 8080,
    this.assetPath = 'packages/kpostal/assets/kakao_postcode_localhost.html',
  });

  /// Host to bind. Defaults to `localhost`.
  final String host;

  /// Port to bind. Defaults to 8080.
  final int port;

  /// Flutter asset path of the HTML page to serve.
  final String assetPath;

  HttpServer? _server;

  /// Whether the server is currently running.
  bool get isRunning => _server != null;

  /// Starts the server. Does nothing if it is already running.
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

  /// Stops the server.
  Future<void> close() async {
    await _server?.close(force: true);
    _server = null;
    log('KpostalServer closed');
  }
}
