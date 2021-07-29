[![pub package](https://img.shields.io/pub/v/kpostal.svg?label=kpostal&color=blue)](https://pub.dev/packages/kpostal)
[![likes](https://badges.bar/kpostal/likes)](https://pub.dev/packages/kpostal/score)

[![English](https://img.shields.io/badge/Language-English-9cf?style=for-the-badge)](README.md)
[![Korean](https://img.shields.io/badge/Language-Korean-9cf?style=for-the-badge)](README.ko-kr.md)


# About kpostal

Kpostal package can search for Korean postal addresses using [Kakao postcode service](https://postcode.map.daum.net/guide).   
This package is inspired by [Kopo](https://pub.dev/packages/kopo) package that is discontinued.

Support Null-Safety!

<div><img src="https://tykann.github.io/kpostal/assets/screenshot.png" width="375"></div>

## Getting Started

Add kpostal to your pubspec.yaml file:
```yaml
dependencies:
  kpostal: ^0.1.3
```

## Setup

🧑🏻‍💻 Nothing to do! Both iOS and Android.

## Example

```dart
import 'package:kpostal/kpostal.dart';

// Use callback.
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

// Not use callback.
TextButton(
    onPressed: () async {
        Kpostal result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
        print(result.address);
    },
    child: Text('Search!'),
),
```