## 1.0.0

### ENHANCEMENTS

- Fix typo
- Example App targets Android SDK 34 version
- Update docs and example

### BREAKING CHANGES

- Dart SDK version `>=2.17.0 <4.0.0`
- Flutter minimum version `3.0.0`
- Updated Android `minSdkVersion` to `19`
- Changed `flutter_inappwebview` dependency version to `^6.0.0`
- Changed `geocoding` dependency version to `^3.0.0`
- The minimum iOS version to be `9.0`(ios/Podfile) with `XCode version >= 14`

## 0.5.1

- fix #12 issue : show representative jibunAddress

## 0.5.0

- remove pubspec.lock from git.
- update dependencies.
- improve method for searching latitude and logitude through geocoding.
  if not found by eng address, retry using kor address.
- log info.

## 0.4.2

- fix a bug below Android 10.

## 0.4.1

- add "bname1" parameter.

## 0.4.0

- remove "webview_flutter" from dependencies.
  all components related to Webview(local hosting, javascript message, view page...) are integrated using "flutter_inappwebview" package.

## 0.3.2

- fix "not callback when geocoding value is null"
- fix protocol error and update html file

## 0.3.1

- fix platform geocoding returns wrong coordinates.
- add kakao geocoding(optional)
- update docs

## 0.3.0

- provides latitude and logitude
- update docs

## 0.2.0

- add search w/ localhost server

## 0.1.3

- update README.md
- add Korean docs
- add 'userSelectedAddress' getter

## 0.1.2

- update docs typo

## 0.1.1

- update docs & fix android bug(can't listen callback)

## 0.1.0

- initial publish
