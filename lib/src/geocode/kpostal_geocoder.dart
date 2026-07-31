/// 플랫폼별 지오코딩 구현을 선택하는 conditional export.
///
/// - io(Android/iOS/macOS): `geocoding` 플러그인 기반
/// - web: 플랫폼 지오코딩 미지원 — 항상 빈 결과 반환
library;

export 'kpostal_geocoder_io.dart'
    if (dart.library.js_interop) 'kpostal_geocoder_web.dart';
