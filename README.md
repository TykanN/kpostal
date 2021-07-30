[![pub package](https://img.shields.io/pub/v/kpostal.svg?label=kpostal&color=blue)](https://pub.dev/packages/kpostal)
[![likes](https://badges.bar/kpostal/likes)](https://pub.dev/packages/kpostal/score)

[![English](https://img.shields.io/badge/Language-English-9cf?style=for-the-badge)](README.md)
[![Korean](https://img.shields.io/badge/Language-Korean-9cf?style=for-the-badge)](README.ko-kr.md)


# About kpostal

Kpostal package can search for Korean postal addresses using [Kakao postcode service](https://postcode.map.daum.net/guide).   
This package is inspired by [Kopo](https://pub.dev/packages/kopo) package that is discontinued.

By default, it uses the Address Search page hosted on Github.   
It's the easiest way to use it.

To respond to errors that arise from hosting problems, we also support hosting local server.

Support Null-Safety!

<div><img src="https://tykann.github.io/kpostal/assets/screenshot.png" width="375"></div>

## Getting Started

Add kpostal to your pubspec.yaml file:
```yaml
dependencies:
  kpostal:
```

## Setup

**🧑🏻‍💻 Neither iOS nor Android requires any action when using default hosting.**

### ❗ Use local server
If you use the [useLocalServer] option to host a local server, you should make the platform specific settings required for http communication.
### Android
Add `android:usesClearextTraffic="true"` to <application> in AndroidManifest.xml file.
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
Add `NSAppTransportSecurity` to info.plist file.
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

// Use local server.
KpostalView(
    useLocalServer: true, // default is false
    localPort: 8080, // default is 8080
    callback: ...
)
```