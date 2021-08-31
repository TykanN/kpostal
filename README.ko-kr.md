[![pub package](https://img.shields.io/pub/v/kpostal.svg?label=kpostal&color=blue)](https://pub.dev/packages/kpostal)
[![likes](https://badges.bar/kpostal/likes)](https://pub.dev/packages/kpostal/score)

[![English](https://img.shields.io/badge/Language-English-blueviolet?style=for-the-badge)](README.md)
[![Korean](https://img.shields.io/badge/Language-Korean-blueviolet?style=for-the-badge)](README.ko-kr.md)


# kpostal에 대해

Kpostal 패키지는 [카카오 우편번호 서비스](https://postcode.map.daum.net/guide)를 이용해서 한국 도로명 주소/우편번호를 검색할 수 있습니다.   
더 이상 지원이 중단된 [Kopo](https://pub.dev/packages/kopo) 패키지를 참고하여 제작되었습니다.

기본적으로 Github에 호스팅된 주소 검색 페이지를 사용합니다.  
가장 간편하게 사용할 수 있는 방식입니다.

호스팅 문제로 발생하는 에러에 대응하기 위해, 로컬서버 호스팅도 추가로 지원합니다.   

Kpostal은 해당 주소의 경위도 정보도 제공합니다. iOS 및 Android 플랫폼이 제공하는 무료 지오코딩 서비스를 사용합니다. 이것은 사용에 제한이 있다는 것을 의미합니다. 자세한 내용은 [Apple docs for iOS](https://developer.apple.com/documentation/corelocation/clgeocoder), [Google docs for Android](https://developer.android.com/reference/android/location/Geocoder) 그리고 [geocoding](https://pub.dev/dev/geocoding/geocoding) 플러그인을 참조하십시오.

Null-Safety를 지원합니다.

<div><img src="https://tykann.github.io/kpostal/assets/screenshot.png" width="375"></div>

## 시작하기

pubspec.yaml 파일에 kpostal을 추가해주세요:
```yaml
dependencies:
  kpostal:
```

## 플랫폼별 설정

**🧑🏻‍💻 기본 제공하는 웹호스팅 사용 시 iOS, Android 모두 아무런 작업이 필요없습니다.**

### ❗️ 로컬서버 사용
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
    callback: ...
)
```