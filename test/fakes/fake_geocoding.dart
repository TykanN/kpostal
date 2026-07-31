import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';

/// [locationFromAddress] 호출을 [onLocation]으로 위임하는 fake.
class FakeGeocoding extends Geocoding {
  FakeGeocoding(this.onLocation)
    : super.implementation(GeocodingCreationParams());

  final Future<List<Location>> Function(String address) onLocation;

  @override
  Future<List<Location>> locationFromAddress(
    String address, {
    Locale? locale,
  }) => onLocation(address);
}

class FakeGeocodingPlatformFactory extends GeocodingPlatformFactory {
  FakeGeocodingPlatformFactory(this.geocoding);

  final Geocoding geocoding;

  @override
  Geocoding createGeocoding(GeocodingCreationParams params) => geocoding;
}
