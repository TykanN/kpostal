# About kpostal

Kpostal package can search for Korean postal addresses using [Kakao postcode service](https://postcode.map.daum.net/guide).
This package is inspired by [Kopo](https://pub.dev/packages/kopo) package that is discontinued.

Support Null-Safety!

## Getting Started

Add kpostal to your pubspec.yaml file:
```yaml
dependencies:
  kpostal: ^0.1.1
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