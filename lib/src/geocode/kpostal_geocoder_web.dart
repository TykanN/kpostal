import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart'
    show Location;

/// Web에서는 플랫폼 지오코딩을 지원하지 않아 항상 빈 결과를 반환합니다.
Future<List<Location>> geocodeAddress(String address, Locale locale) async =>
    <Location>[];
