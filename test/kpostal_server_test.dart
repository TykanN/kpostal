import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:kpostal/src/kpostal_server.dart';

/// flutter_test는 [HttpClient]를 400 반환 mock으로 교체하므로,
/// 실제 로컬 서버 검증을 위해 기본 구현으로 되돌립니다.
class _RealHttpOverrides extends HttpOverrides {}

Future<HttpClientResponse> _get(int port) {
  return HttpOverrides.runWithHttpOverrides(() async {
    final HttpClient client = HttpClient();
    try {
      final HttpClientRequest request = await client.get(
        'localhost',
        port,
        '/',
      );
      return await request.close();
    } finally {
      client.close();
    }
  }, _RealHttpOverrides());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const int testPort = 18080;

  test('start 후 번들된 HTML 에셋을 서빙', () async {
    final server = KpostalServer(port: testPort);
    await server.start();

    try {
      final HttpClientResponse response = await _get(testPort);
      final String body = await response.transform(utf8.decoder).join();
      final String expected = await rootBundle.loadString(
        'packages/kpostal/assets/kakao_postcode_localhost.html',
      );

      expect(response.statusCode, HttpStatus.ok);
      expect(response.headers.contentType?.mimeType, 'text/html');
      expect(
        response.headers.value(HttpHeaders.cacheControlHeader),
        'no-cache',
      );
      expect(body, expected);
    } finally {
      await server.close();
    }
  });

  test('start를 중복 호출해도 안전', () async {
    final server = KpostalServer(port: testPort);
    await server.start();
    await server.start();

    try {
      final HttpClientResponse response = await _get(testPort);
      expect(response.statusCode, HttpStatus.ok);
    } finally {
      await server.close();
    }
  });

  test('close 후에는 연결 불가, close 중복 호출도 안전', () async {
    final server = KpostalServer(port: testPort);
    await server.start();
    await server.close();
    await server.close();

    expect(() => _get(testPort), throwsA(isA<SocketException>()));
  });

  test('close 후 다시 start 가능', () async {
    final server = KpostalServer(port: testPort);
    await server.start();
    await server.close();
    await server.start();

    try {
      final HttpClientResponse response = await _get(testPort);
      expect(response.statusCode, HttpStatus.ok);
    } finally {
      await server.close();
    }
  });
}
