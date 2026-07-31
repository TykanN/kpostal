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

**kpostal** is a Korean postal address search widget for Flutter, powered by the [Kakao (Daum) postcode service](https://postcode.map.daum.net/guide). Push a single widget, get a structured address (postcode, road/jibun address, building info, …) back — with optional latitude/longitude geocoding.

Inspired by the discontinued [Kopo](https://pub.dev/packages/kopo) package.

## Features

- 🔎 **Kakao postcode search** as a ready-made `KpostalView` widget — zero configuration to get started.
- 🌐 **Multi-platform**: Android, iOS, macOS, and Web, built on the official [webview_flutter](https://pub.dev/packages/webview_flutter) (iframe on Web).
- 📍 **Geocoding built in**: latitude/longitude via free platform geocoding (Android/iOS/macOS), plus optional [Kakao Maps API](https://apis.map.kakao.com/web/guide/) geocoding.
- 🏠 **Resilient hosting**: uses a GitHub-hosted search page by default, with a local-server fallback (`useLocalServer`) in case of hosting issues.
- 🎨 **Customizable**: custom `AppBar`, loading indicator, and result callback.

## Platform Support

| Android | iOS | macOS | Web | Windows | Linux |
| :-----: | :-: | :---: | :-: | :-----: | :---: |
|   ✅    | ✅  |  ✅   | ✅  |   ❌    |  ❌   |

- Requires Flutter 3.38+ / Dart 3.10+.
- On **Web**, `useLocalServer` is ignored and platform geocoding is unavailable (`latitude`/`longitude` are `null`) — use `kakaoKey` geocoding instead.
- Platform geocoding uses the free OS services with their own usage limits — see the [Apple](https://developer.apple.com/documentation/corelocation/clgeocoder), [Android](https://developer.android.com/reference/android/location/Geocoder), and [geocoding](https://pub.dev/packages/geocoding) docs.

<div align="center"><img src="https://tykann.github.io/kpostal/assets/screenshot.png" width="320" alt="kpostal screenshot" /></div>

## Quick Start

```yaml
dependencies:
  kpostal:
```

```dart
import 'package:kpostal/kpostal.dart';

// Use callback.
await Navigator.push(context, MaterialPageRoute(
  builder: (_) => KpostalView(
    callback: (Kpostal result) {
      print(result.address);
      print(result.latitude);
    },
  ),
));

// Or receive the result as a return value.
Kpostal result = await Navigator.push(
  context, MaterialPageRoute(builder: (_) => KpostalView()));
```

Key fields on the `Kpostal` result: `postCode`, `address`, `roadAddress`, `jibunAddress`, `buildingName`, `sido`, `sigungu`, `latitude`/`longitude`, `kakaoLatitude`/`kakaoLongitude`, `userSelectedAddress` — see the [API reference](https://pub.dev/documentation/kpostal/latest/) for the full list.

## Setup

**🧑🏻‍💻 With the default hosted page, Android and iOS need no extra setup.**

<details>
<summary><b>Android</b> — internet permission (release mode)</summary>

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
```

</details>

<details>
<summary><b>macOS</b> — network entitlements</summary>

```xml
<!-- macos/Runner/DebugProfile.entitlements & Release.entitlements -->
<key>com.apple.security.network.client</key>
<true/>
<!-- only if you use [useLocalServer] -->
<key>com.apple.security.network.server</key>
<true/>
```

</details>

<details>
<summary><b>Local server</b> (optional, <code>useLocalServer: true</code>) — allow http traffic</summary>

The local server serves the search page over `http://localhost`, so cleartext traffic must be allowed.

**Android** — add `android:usesCleartextTraffic="true"` to `<application>` in `AndroidManifest.xml`:

```xml
<application
    android:label="[your_app]"
    android:usesCleartextTraffic="true"
    ...>
```

**iOS** — add `NSAppTransportSecurity` to `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

</details>

<details>
<summary><b>Kakao geocoding</b> (optional, <code>kakaoKey</code>) — get <code>kakaoLatitude</code>/<code>kakaoLongitude</code></summary>

1. Go to the [Kakao Developers site](https://developers.kakao.com), register, and create an app.
2. Add a **Web platform**: App – [Platform] – [Web Platform Registration].
3. Register the site domain:
   - default hosting: `https://tykann.github.io`
   - local server: `http://localhost:{your port, default 8080}`
4. Use the **JavaScript key** shown at the top of the page as `kakaoKey`.

```dart
KpostalView(
  kakaoKey: '{your kakao app JS key}',
  callback: (Kpostal result) {
    print(result.kakaoLatitude);
  },
)
```

</details>

## Usage

```dart
KpostalView(
  useLocalServer: true,        // host the page on localhost (default: false)
  localPort: 8080,             // local server port (default: 8080)
  kakaoKey: '{JS key}',        // enable Kakao geocoding (optional)
  appBar: ...,                 // custom AppBar (optional)
  onLoading: ...,              // custom loading widget (optional)
  callback: (Kpostal result) { ... },
)
```

## Migration from 1.x

Most apps need **no code changes** — v2 swaps the webview engine from `flutter_inappwebview` to the official `webview_flutter` and adds Web/macOS support.

- Requires Flutter 3.38+ / Dart 3.10+.
- On Web, `latitude`/`longitude` are `null` — use `kakaoKey` geocoding if you need coordinates.
- macOS apps need the network entitlements above.

See the [CHANGELOG](https://pub.dev/packages/kpostal/changelog) for details.

## Roadmap

- [x] v2: migrate to official `webview_flutter`, Web & macOS support
- [ ] v2.0.0 stable release
- [ ] Custom search page URL — self-host the postcode page on your own domain (also enables full control on Web, where a local server isn't possible)
- [ ] Embeddable search widget (usable inside bottom sheets/dialogs without a `Scaffold`)
- [ ] Windows/Linux support — blocked on `webview_flutter` desktop support

Have an idea or issue? [Open an issue](https://github.com/TykanN/kpostal/issues) — contributions are welcome!

## License

[MIT](LICENSE)
