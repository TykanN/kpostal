import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart'
    show GeocodingPlatformFactory, Location;
import 'package:kpostal/kpostal.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart'
    show WebViewPlatform;

import 'fakes/fake_geocoding.dart';
import 'fakes/fake_webview_platform.dart';
import 'test_data.dart';

/// flutter_test는 [HttpClient]를 400 반환 mock으로 교체하므로,
/// 실제 로컬 서버 검증을 위해 기본 구현으로 되돌립니다.
class _RealHttpOverrides extends HttpOverrides {}

void main() {
  late FakeWebViewPlatform webViewPlatform;

  setUp(() {
    webViewPlatform = FakeWebViewPlatform();
    WebViewPlatform.instance = webViewPlatform;
    GeocodingPlatformFactory.instance = FakeGeocodingPlatformFactory(
      FakeGeocoding(
        (_) async => const [Location(latitude: 37.478, longitude: 126.945)],
      ),
    );
  });

  FakeWebViewController controller() => webViewPlatform.lastController!;

  group('targetUri', () {
    testWidgets('기본값: 호스팅된 v2 검색 페이지 로드', (tester) async {
      await tester.pumpWidget(MaterialApp(home: KpostalView()));
      await tester.pump();

      final Uri uri = controller().loadedRequests.single;
      expect(uri.scheme, 'https');
      expect(uri.host, 'tykann.github.io');
      expect(uri.path, '/kpostal/assets/kakao_postcode_v2.html');
      expect(uri.queryParameters['enableKakao'], 'false');
      expect(uri.queryParameters.containsKey('key'), isFalse);
    });

    testWidgets('kakaoKey 설정 시 지오코더 활성화 파라미터 전달', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: KpostalView(kakaoKey: 'test-kakao-key')),
      );
      await tester.pump();

      final Uri uri = controller().loadedRequests.single;
      expect(uri.queryParameters['enableKakao'], 'true');
      expect(uri.queryParameters['key'], 'test-kakao-key');
    });

    testWidgets('useLocalServer 설정 시 로컬 서버 기동 후 localhost 페이지 로드', (
      tester,
    ) async {
      const int port = 18090;

      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(home: KpostalView(useLocalServer: true, localPort: port)),
        );
        // 서버 기동(에셋 로드 + 포트 바인딩) 완료 대기
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final Uri uri = controller().loadedRequests.single;
        expect(uri.scheme, 'http');
        expect(uri.host, 'localhost');
        expect(uri.port, port);
        expect(
          uri.path,
          '/packages/kpostal/assets/kakao_postcode_localhost.html',
        );

        // 실제로 서빙 중인지 확인 (flutter_test의 HttpClient mock 우회)
        await HttpOverrides.runWithHttpOverrides(() async {
          final HttpClient client = HttpClient();
          final response = await (await client.get(
            'localhost',
            port,
            '/',
          )).close();
          expect(response.statusCode, HttpStatus.ok);
          client.close();
        }, _RealHttpOverrides());

        // 위젯 dispose 시 서버 종료
        await tester.pumpWidget(const SizedBox());
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HttpOverrides.runWithHttpOverrides(() async {
          await expectLater(
            () async =>
                (await HttpClient().get('localhost', port, '/')).close(),
            throwsA(isA<SocketException>()),
          );
        }, _RealHttpOverrides());
      });
    });

    test('localPort가 등록 포트 범위를 벗어나면 assert 실패', () {
      expect(() => KpostalView(localPort: 80), throwsAssertionError);
      expect(() => KpostalView(localPort: 65535), throwsAssertionError);
    });
  });

  group('로딩 인디케이터', () {
    testWidgets('페이지 로드 완료 전 표시, 완료 후 제거', (tester) async {
      await tester.pumpWidget(MaterialApp(home: KpostalView()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller().finishPageLoad();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('onLoading 커스텀 위젯 사용', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: KpostalView(onLoading: const Text('로딩중'))),
      );
      await tester.pump();

      expect(find.text('로딩중'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('주소 선택 처리', () {
    testWidgets('주소 선택 메시지 수신 시 callback 호출 및 결과와 함께 pop', (tester) async {
      Kpostal? viaCallback;
      Kpostal? viaPop;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                viaPop = await Navigator.push<Kpostal>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        KpostalView(callback: (result) => viaCallback = result),
                  ),
                );
              },
              child: const Text('주소검색'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('주소검색'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      controller().finishPageLoad();
      await tester.pump();

      controller().receiveMessage(sampleKpostalJsonString);
      await tester.pumpAndSettle();

      // KpostalView가 pop되어 원래 화면으로 복귀
      expect(find.text('주소검색'), findsOneWidget);

      expect(viaCallback, isNotNull);
      expect(viaCallback!.postCode, '08758');
      expect(viaCallback!.roadAddress, '서울 관악구 남부순환로 1801');
      // 플랫폼 지오코딩 결과가 모델에 반영됨
      expect(viaCallback!.latitude, 37.478);
      expect(viaCallback!.longitude, 126.945);
      expect(viaPop, same(viaCallback));
    });

    testWidgets('잘못된 메시지 수신 시 callback 없이 pop', (tester) async {
      Kpostal? viaCallback;
      Kpostal? viaPop;
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                viaPop = await Navigator.push<Kpostal>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        KpostalView(callback: (result) => viaCallback = result),
                  ),
                );
                popped = true;
              },
              child: const Text('주소검색'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('주소검색'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      controller().finishPageLoad();
      await tester.pump();

      controller().receiveMessage('not-a-json');
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(viaPop, isNull);
      expect(viaCallback, isNull);
    });
  });

  group('AppBar', () {
    testWidgets('기본 타이틀과 색상 적용', (tester) async {
      await tester.pumpWidget(MaterialApp(home: KpostalView()));
      await tester.pump();

      expect(find.text('주소검색'), findsOneWidget);
      final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.white);
    });

    testWidgets('커스텀 appBar 사용 시 기본 AppBar 대체', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: KpostalView(appBar: AppBar(title: const Text('커스텀 타이틀'))),
        ),
      );
      await tester.pump();

      expect(find.text('커스텀 타이틀'), findsOneWidget);
      expect(find.text('주소검색'), findsNothing);
    });
  });

  group('웹뷰 채널 연결', () {
    testWidgets('onComplete JS 채널이 등록됨', (tester) async {
      await tester.pumpWidget(MaterialApp(home: KpostalView()));
      await tester.pump();

      expect(controller().channels, contains('onComplete'));
    });

    testWidgets('선택 결과 JSON은 Kpostal 모델과 필드가 호환됨', (tester) async {
      // fromJson이 요구하는 모든 필드가 실제 카카오 응답 형태에 존재하는지 검증
      expect(
        () => Kpostal.fromJson(jsonDecode(sampleKpostalJsonString)),
        returnsNormally,
      );
    });
  });
}
