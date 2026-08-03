<p align="center">
  <a href="https://pub.dev/packages/kpostal">
    <img src="https://tykann.github.io/kpostal/assets/kpostal_header.png" width="640" alt="kpostal — Korean postal address search for Flutter" />
  </a>
</p>

<p align="center">
  <a href="https://pub.dev/packages/kpostal"><img src="https://img.shields.io/pub/v/kpostal.svg?label=kpostal&color=blue" alt="pub version" /></a>
  <a href="https://pub.dev/packages/kpostal/score"><img src="https://img.shields.io/pub/points/kpostal" alt="pub points" /></a>
  <a href="https://pub.dev/packages/kpostal/score"><img src="https://img.shields.io/pub/likes/kpostal" alt="pub likes" /></a>
  <a href="https://pub.dev/packages/kpostal/score"><img src="https://img.shields.io/pub/dm/kpostal" alt="downloads" /></a>
  <a href="https://github.com/TykanN/kpostal/actions/workflows/test.yml"><img src="https://github.com/TykanN/kpostal/actions/workflows/test.yml/badge.svg" alt="test" /></a>
  <a href="https://github.com/TykanN/kpostal/blob/master/LICENSE"><img src="https://img.shields.io/github/license/TykanN/kpostal" alt="license" /></a>
</p>

<p align="center">
  <a href="README.md"><img src="https://img.shields.io/badge/Language-English-9cf?style=for-the-badge" alt="English" /></a>
  <a href="README.ko-kr.md"><img src="https://img.shields.io/badge/Language-한국어-9cf?style=for-the-badge" alt="Korean" /></a>
</p>

---

**kpostal**은 [카카오(다음) 우편번호 서비스](https://postcode.map.daum.net/guide) 기반의 Flutter 한국 주소 검색 위젯입니다. 위젯 하나만 띄우면 우편번호·도로명/지번 주소·건물 정보 등 구조화된 주소를 돌려받고, 필요하면 경위도 지오코딩까지 지원합니다.

지원이 중단된 [Kopo](https://pub.dev/packages/kopo) 패키지에서 영감을 받아 제작되었습니다.

## 특징

- 🔎 **카카오 우편번호 검색**을 `KpostalView` 위젯으로 바로 사용 — 별도 설정 없이 시작할 수 있습니다.
- 🌐 **멀티 플랫폼**: Android, iOS, macOS, Web 지원. 공식 [webview_flutter](https://pub.dev/packages/webview_flutter) 기반(Web은 iframe).
- 📍 **지오코딩 내장**: 플랫폼 무료 지오코딩(Android/iOS/macOS)으로 경위도 제공, [카카오맵 API](https://apis.map.kakao.com/web/guide/) 지오코딩도 선택적으로 지원.
- 🏠 **안정적인 호스팅**: 기본은 GitHub 호스팅 검색 페이지, 호스팅 장애 대비 로컬 서버 폴백(`useLocalServer`) 지원.
- 🎨 **커스터마이징**: 커스텀 `AppBar`, 로딩 위젯, 결과 콜백.

## 플랫폼 지원

| Android | iOS | macOS | Web | Windows | Linux |
| :-----: | :-: | :---: | :-: | :-----: | :---: |
|   ✅    | ✅  |  ✅   | ✅  |   ❌    |  ❌   |

- Flutter 3.38+ / Dart 3.10+ 이 필요합니다.
- **Web**에서는 `useLocalServer`가 무시되며, 플랫폼 지오코딩을 사용할 수 없어 `latitude`/`longitude`가 `null`입니다. `kakaoKey` 지오코딩을 사용하세요.
- 플랫폼 지오코딩은 OS가 제공하는 무료 서비스를 사용하므로 자체 사용 제한이 있습니다 — [Apple](https://developer.apple.com/documentation/corelocation/clgeocoder), [Android](https://developer.android.com/reference/android/location/Geocoder), [geocoding](https://pub.dev/packages/geocoding) 문서를 참고하세요.

<div align="center"><img src="https://tykann.github.io/kpostal/assets/screenshot.png" width="320" alt="kpostal 스크린샷" /></div>

## 시작하기

```yaml
dependencies:
  kpostal:
```

```dart
import 'package:kpostal/kpostal.dart';

// 콜백으로 사용
await Navigator.push(context, MaterialPageRoute(
  builder: (_) => KpostalView(
    callback: (Kpostal result) {
      print(result.address);
      print(result.latitude);
    },
  ),
));

// 또는 리턴값으로 받기
Kpostal result = await Navigator.push(
  context, MaterialPageRoute(builder: (_) => KpostalView()));
```

`Kpostal` 결과의 주요 필드: `postCode`, `address`, `roadAddress`, `jibunAddress`, `buildingName`, `sido`, `sigungu`, `latitude`/`longitude`, `kakaoLatitude`/`kakaoLongitude`, `userSelectedAddress` — 전체 목록은 [API 레퍼런스](https://pub.dev/documentation/kpostal/latest/)를 참고하세요.

## 설정

**🧑🏻‍💻 기본 호스팅 페이지 사용 시 Android/iOS는 추가 설정이 없습니다.**

<details>
<summary><b>Android</b> — 인터넷 권한 (릴리즈 모드)</summary>

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
```

</details>

<details>
<summary><b>macOS</b> — 네트워크 entitlement</summary>

```xml
<!-- macos/Runner/DebugProfile.entitlements & Release.entitlements -->
<key>com.apple.security.network.client</key>
<true/>
<!-- [useLocalServer] 사용 시에만 필요 -->
<key>com.apple.security.network.server</key>
<true/>
```

</details>

<details>
<summary><b>로컬 서버</b> (선택, <code>useLocalServer: true</code>) — http 통신 허용</summary>

로컬 서버는 검색 페이지를 `http://localhost`로 서빙하므로 cleartext 통신 허용이 필요합니다.

**Android** — `AndroidManifest.xml`의 `<application>`에 `android:usesCleartextTraffic="true"` 추가:

```xml
<application
    android:label="[your_app]"
    android:usesCleartextTraffic="true"
    ...>
```

**iOS** — `Info.plist`에 `NSAppTransportSecurity` 추가:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

</details>

<details>
<summary><b>카카오 지오코딩</b> (선택, <code>kakaoKey</code>) — <code>kakaoLatitude</code>/<code>kakaoLongitude</code> 받기</summary>

1. [Kakao Developers](https://developers.kakao.com)에서 개발자 등록 후 앱을 생성합니다.
2. **웹 플랫폼 등록**: 앱 선택 – [플랫폼] – [Web 플랫폼 등록].
3. 사이트 도메인 등록:
   - 기본 호스팅: `https://tykann.github.io`
   - 로컬 서버: `http://localhost:{사용 포트, 기본 8080}`
4. 페이지 상단의 **JavaScript 키**를 `kakaoKey`로 사용합니다.

```dart
KpostalView(
  kakaoKey: '{카카오 앱 JS 키}',
  callback: (Kpostal result) {
    print(result.kakaoLatitude);
  },
)
```

</details>

## 사용법

```dart
KpostalView(
  useLocalServer: true,        // 검색 페이지를 localhost로 호스팅 (기본값: false)
  localPort: 8080,             // 로컬 서버 포트 (기본값: 8080)
  kakaoKey: '{JS 키}',          // 카카오 지오코딩 사용 (선택)
  appBar: ...,                 // 커스텀 AppBar (선택)
  onLoading: ...,              // 커스텀 로딩 위젯 (선택)
  callback: (Kpostal result) { ... },
)
```

## 1.x에서 마이그레이션

대부분의 앱은 **코드 변경이 필요 없습니다** — v2는 웹뷰 엔진을 `flutter_inappwebview`에서 공식 `webview_flutter`로 교체하고 Web/macOS 지원을 추가했습니다.

- Flutter 3.38+ / Dart 3.10+ 필요.
- Web에서는 `latitude`/`longitude`가 `null` — 좌표가 필요하면 `kakaoKey` 지오코딩을 사용하세요.
- macOS 앱은 위 네트워크 entitlement 설정이 필요합니다.

자세한 내용은 [CHANGELOG](https://pub.dev/packages/kpostal/changelog)를 확인하세요.

## 로드맵

- [x] v2: 공식 `webview_flutter` 전환, Web & macOS 지원
- [x] v2.0.0 정식 릴리즈
- [ ] 검색 페이지 커스텀 URL — 자체 도메인에 우편번호 페이지 셀프 호스팅 (로컬 서버가 불가능한 Web에서도 완전한 제어 가능)
- [ ] 임베더블 검색 위젯 (`Scaffold` 없이 바텀시트/다이얼로그 내부에서 사용)
- [ ] Windows/Linux 지원 — `webview_flutter` 데스크톱 지원 대기 중

아이디어나 문제가 있다면 [이슈를 남겨주세요](https://github.com/TykanN/kpostal/issues) — 기여를 환영합니다!

## 라이선스

[MIT](LICENSE)
