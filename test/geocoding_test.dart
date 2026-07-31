import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart'
    show GeocodingPlatformFactory, Location;
import 'package:kpostal/kpostal.dart';

import 'fakes/fake_geocoding.dart';
import 'test_data.dart';

void main() {
  // flutter test 환경의 defaultTargetPlatform은 android → 플랫폼 지오코딩 지원 대상.
  final Kpostal model = Kpostal.fromJson(sampleKpostalJson());

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('영문 주소로 좌표를 찾으면 해당 좌표(마지막 항목)를 반환', () async {
    GeocodingPlatformFactory.instance = FakeGeocodingPlatformFactory(
      FakeGeocoding((address) async {
        if (address == model.addressEng) {
          return const [
            Location(latitude: 1, longitude: 1),
            Location(latitude: 37.478, longitude: 126.945),
          ];
        }
        return const [Location(latitude: 99, longitude: 99)];
      }),
    );

    final Location? result = await model.latLng;

    expect(result, const Location(latitude: 37.478, longitude: 126.945));
  });

  test('영문 주소 결과가 없으면 한글 주소로 폴백', () async {
    GeocodingPlatformFactory.instance = FakeGeocodingPlatformFactory(
      FakeGeocoding((address) async {
        if (address == model.address) {
          return const [Location(latitude: 37.478, longitude: 126.945)];
        }
        return const [];
      }),
    );

    final Location? result = await model.latLng;

    expect(result, const Location(latitude: 37.478, longitude: 126.945));
  });

  test('영문/한글 주소 모두 결과가 없으면 null', () async {
    GeocodingPlatformFactory.instance = FakeGeocodingPlatformFactory(
      FakeGeocoding((_) async => const []),
    );

    expect(await model.latLng, isNull);
  });

  test('지오코딩 중 예외가 발생해도 null 반환(throw 하지 않음)', () async {
    GeocodingPlatformFactory.instance = FakeGeocodingPlatformFactory(
      FakeGeocoding((_) async => throw Exception('platform error')),
    );

    expect(await model.latLng, isNull);
  });

  test('미지원 플랫폼에서는 지오코딩 호출 없이 null 반환', () async {
    int callCount = 0;
    GeocodingPlatformFactory.instance = FakeGeocodingPlatformFactory(
      FakeGeocoding((_) async {
        callCount++;
        return const [Location(latitude: 1, longitude: 1)];
      }),
    );
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;

    expect(await model.latLng, isNull);
    expect(callCount, 0);
  });
}
