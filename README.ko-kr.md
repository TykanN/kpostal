[![pub package](https://img.shields.io/pub/v/kpostal.svg?label=kpostal&color=blue)](https://pub.dev/packages/kpostal)
[![Pub Likes](https://img.shields.io/pub/likes/kpostal)](https://pub.dev/packages/kpostal/score)
[![Test](https://github.com/TykanN/kpostal/actions/workflows/test.yml/badge.svg)](https://github.com/TykanN/kpostal/actions/workflows/test.yml)

[![English](https://img.shields.io/badge/Language-English-blueviolet?style=for-the-badge)](README.md)
[![Korean](https://img.shields.io/badge/Language-Korean-blueviolet?style=for-the-badge)](README.ko-kr.md)

# kpostal에 대해

Kpostal 패키지는 [카카오 우편번호 서비스](https://postcode.map.daum.net/guide)를 이용해서 한국 도로명 주소/우편번호를 검색할 수 있습니다.  
더 이상 지원이 중단된 [Kopo](https://pub.dev/packages/kopo) 패키지를 참고하여 제작되었습니다.

기본적으로 Github에 호스팅된 주소 검색 페이지를 사용합니다.  
가장 간편하게 사용할 수 있는 방식입니다.

호스팅 문제로 발생하는 에러에 대응하기 위해, 로컬서버 호스팅도 추가로 지원합니다.

Kpostal은 해당 주소의 경위도 정보도 제공합니다. iOS 및 Android 플랫폼이 제공하는 무료 지오코딩 서비스를 사용합니다. 이것은 사용에 제한이 있다는 것을 의미합니다. 자세한 내용은 [Apple docs for iOS](https://developer.apple.com/documentation/corelocation/clgeocoder), [Google docs for Android](https://developer.android.com/reference/android/location/Geocoder) 그리고 [geocoding](https://pub.dev/dev/geocoding/geocoding) 플러그인을 참조하십시오.  
**[카카오맵 API](https://apis.map.kakao.com/web/guide/)키를 발급받아 사용하시는 경우, 카카오 지오코딩 값도 얻을 수 있습니다.**

Null-Safety를 지원합니다.

## 플랫폼 지원

| Android | iOS | macOS | Web | Windows | Linux |
| :-----: | :-: | :---: | :-: | :-----: | :---: |
|   ✅    | ✅  |  ✅   | ✅  |   ❌    |  ❌   |

- Android/iOS/macOS는 [webview_flutter](https://pub.dev/packages/webview_flutter), Web은 iframe 기반으로 동작합니다.
- Web에서는 `useLocalServer` 옵션이 지원되지 않으며(무시됨), 플랫폼 지오코딩을 사용할 수 없어 `latitude`/`longitude`가 `null`로 반환됩니다. `kakaoKey` 지오코딩을 사용하세요.
- Flutter 3.38+ / Dart 3.10+ 이 필요합니다.

<div><img src="https://tykann.github.io/kpostal/assets/screenshot.png" width="375"></div>

## 시작하기

ㄴ
pubspec.yaml 파일에 kpostal을 추가해주세요:

```yaml
dependencies:
  kpostal:
```

## 플랫폼별 설정

**🧑🏻‍💻 기본 제공하는 웹호스팅 사용 시 추가 설정은 없습니다.**

**[Android] 릴리즈 모드에서는 인터넷 권한 설정을 확인해주세요!**

```xml
// AndroidManifest.xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**[macOS] 앱에 네트워크 entitlement를 추가해주세요.**

```xml
// macos/Runner/DebugProfile.entitlements & Release.entitlements
<key>com.apple.security.network.client</key>
<true/>
// [useLocalServer] 사용 시에만 필요
<key>com.apple.security.network.server</key>
<true/>
```

### ❗️ 로컬서버 사용 (선택)

[useLocalServer] 옵션을 통해 로컬서버 호스팅을 사용하면 http통신에 필요한 플랫폼별 설정을 해야 합니다.

### Android

AndroidManifest.xml 파일의 <application>에 `android:usesCleartextTraffic="true"`를 추가해주세요.

```xml
<application
        android:label="[your_app]"
        android:icon="@mipmap/ic_launcher"
        ...
        android:usesCleartextTraffic="true"
        ...
        >
    ...
</application>
```

### iOS

info.plist 파일에 `NSAppTransportSecurity`를 추가해주세요.

```xml
<plist version="1.0">
<dict>
    ...
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    ...
</dict>
</plist>
```

### 🧩 카카오 지오코딩 사용(\*선택사항)

1. [Kakao Developer Site](https://developers.kakao.com) 접속
2. 개발자 등록 및 앱 생성
3. 웹 플랫폼 추가: 앱 선택 – [플랫폼] – [Web 플랫폼 등록] – 사이트 도메인 등록
4. 사이트 도메인 등록: [웹] 플랫폼을 선택하고, [사이트 도메인] 을 등록합니다.
   - 기본 사용 시, `https://tykann.github.io` 등록
   - 로컬서버 옵션을 사용 시, `http://localhost:{your port, default is 8080}` 등록
5. 페이지 상단의 [JavaScript 키]를 지도 API의 appkey로 사용합니다.

## 사용 예시

```dart
import 'package:kpostal/kpostal.dart';

// 콜백 기능으로 사용
TextButton(
    onPressed: () async {
        await Navigator.push(context, MaterialPageRoute(
            builder: (_) => KpostalView(
                callback: (Kpostal result) {
                    print(result.address);
                },
            ),
        ));
    },
    child: Text('Search!'),
),

// 콜백 없이 결과값을 리턴 받아서 사용
TextButton(
    onPressed: () async {
        Kpostal result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
        print(result.address);
    },
    child: Text('Search!'),
),

// 로컬서버 사용
KpostalView(
    useLocalServer: true, // 기본값은 false
    localPort: 8080, // 기본값은 8080
    kakaoKey: '{발급받은 카카오 앱 JS 키}' // 생략 시 기본 플랫폼 지오코딩만 사용
    callback: ...
)
```
