import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding/geocoding.dart';

/// `geocoding` 플러그인 기반 지오코딩 구현. (Android/iOS/macOS)
Future<List<Location>> geocodeAddress(String address, Locale locale) =>
    Geocoding(locale: locale).locationFromAddress(address, locale: locale);
