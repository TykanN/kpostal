[![pub package](https://img.shields.io/pub/v/kpostal.svg?label=kpostal&color=blue)](https://pub.dev/packages/kpostal)
[![likes](https://badges.bar/kpostal/likes)](https://pub.dev/packages/kpostal/score)

[![English](https://img.shields.io/badge/Language-English-blueviolet?style=for-the-badge)](README.md)
[![Korean](https://img.shields.io/badge/Language-Korean-blueviolet?style=for-the-badge)](README.ko-kr.md)


# kpostal에 대해

Kpostal 패키지는 [카카오 우편번호 서비스](https://postcode.map.daum.net/guide)를 이용해서 한국 도로명 주소/우편번호를 검색할 수 있습니다.   
더 이상 지원이 중단된 [Kopo](https://pub.dev/packages/kopo) 패키지를 참고하여 제작되었습니다.

Null-Safety를 지원합니다.

<div><img src="https://tykann.github.io/kpostal/assets/screenshot.png" width="375"></div>

## 시작하기

pubspec.yaml 파일에 kpostal을 추가해주세요:
```yaml
dependencies:
  kpostal: ^0.1.3
```

## 플랫폼별 설정

🧑🏻‍💻 iOS, Android 모두 아무런 작업이 필요없습니다.

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
```