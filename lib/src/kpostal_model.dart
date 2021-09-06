import 'package:geocoding/geocoding.dart';

class Kpostal {
  /// 국가기초구역번호. 2015년 8월 1일부터 시행된 새 우편번호.
  final String postCode;

  /// 기본 주소
  final String address;

  /// 기본 영문 주소
  final String addressEng;

  /// 도로명 주소
  final String roadAddress;

  /// 영문 도로명 주소
  final String roadAddressEng;

  /// 지번 주소
  final String jibunAddress;

  /// 영문 지번 주소
  final String jibunAddressEng;

  /// 건물관리번호
  final String buildingCode;

  /// 건물명
  final String buildingName;

  /// 공동주택 여부(Y/N)
  final String apartment;

  /// 검색된 기본 주소 타입: R(도로명), J(지번)
  final String addressType;

  /// 도/시 이름
  final String sido;

  /// 영문 도/시 이름
  final String sidoEng;

  /// 시/군/구 이름
  final String sigungu;

  /// 영문 시/군/구 이름
  final String sigunguEng;

  /// 시/군/구 코드
  final String sigunguCode;

  /// 도로명 코드, 7자리로 구성된 도로명 코드입니다. 추후 7자리 이상으로 늘어날 수 있습니다.
  final String roadnameCode;

  /// 법정동/법정리 코드
  final String bcode;

  /// 도로명 값, 검색 결과 중 선택한 도로명주소의 "도로명" 값이 들어갑니다.(건물번호 제외)
  final String roadname;

  /// 도로명 값, 검색 결과 중 선택한 도로명주소의 "도로명의 영문" 값이 들어갑니다.(건물번호 제외)
  final String roadnameEng;

  /// 법정동/법정리 이름
  final String bname;

  /// 영문 법정동/법정리 이름
  final String bnameEng;

  /// 사용자가 입력한 검색어
  final String query;

  /// 검색 결과에서 사용자가 선택한 주소의 타입
  final String userSelectedType;

  /// 검색 결과에서 사용자가 선택한 주소의 언어 타입: K(한글주소), E(영문주소)
  final String userLanguageType;

  /// 위도(플랫폼 geocoding)
  late double? latitude;

  /// 경도(플랫폼 geocoding)
  late double? longitude;

  /// 위도(카카오 geocoding)
  final double? kakaoLatitude;

  /// 경도(카카오 geocoding)
  final double? kakaoLongitude;

  Kpostal({
    required this.postCode,
    required this.address,
    required this.addressEng,
    required this.roadAddress,
    required this.roadAddressEng,
    required this.jibunAddress,
    required this.jibunAddressEng,
    required this.buildingCode,
    required this.buildingName,
    required this.apartment,
    required this.addressType,
    required this.sido,
    required this.sidoEng,
    required this.sigungu,
    required this.sigunguEng,
    required this.sigunguCode,
    required this.roadnameCode,
    required this.roadname,
    required this.roadnameEng,
    required this.bcode,
    required this.bname,
    required this.bnameEng,
    required this.query,
    required this.userSelectedType,
    required this.userLanguageType,
    this.latitude,
    this.longitude,
    this.kakaoLatitude,
    this.kakaoLongitude,
  });

  factory Kpostal.fromJson(Map json) => Kpostal(
        postCode: json['zonecode'] as String,
        address: json['address'] as String,
        addressEng: json['addressEnglish'] as String,
        roadAddress: json['roadAddress'] as String,
        roadAddressEng: json['roadAddressEnglish'] as String,
        jibunAddress: json['jibunAddress'] as String,
        jibunAddressEng: json['jibunAddressEnglish'] as String,
        buildingCode: json['buildingCode'] as String,
        buildingName: json['buildingName'] as String,
        apartment: json['apartment'] as String,
        addressType: json['addressType'] as String,
        sido: json['sido'] as String,
        sidoEng: json['sidoEnglish'] as String,
        sigungu: json['sigungu'] as String,
        sigunguEng: json['sigunguEnglish'] as String,
        sigunguCode: json['sigunguCode'] as String,
        roadnameCode: json['roadnameCode'] as String,
        roadname: json['roadname'] as String,
        roadnameEng: json['roadnameEnglish'] as String,
        bcode: json['bcode'] as String,
        bname: json['bname'] as String,
        bnameEng: json['bnameEnglish'] as String,
        query: json['query'] as String,
        userSelectedType: json['userSelectedType'] as String,
        userLanguageType: json['userLanguageType'] as String,
        kakaoLatitude: double.tryParse(json['kakaoLat'] ?? ''),
        kakaoLongitude: double.tryParse(json['kakaoLng'] ?? ''),
      );

  @override
  String toString() {
    return "우편번호: $postCode, 주소: $address, 경위도: N$latitude° E$longitude°";
  }

  /// 유저가 화면에서 선택한 주소를 그대로 return합니다.
  String get userSelectedAddress {
    if (this.userSelectedType == 'J') {
      if (this.userLanguageType == 'E') return this.jibunAddressEng;
      return this.jibunAddress;
    }
    if (this.userLanguageType == 'E') return this.roadAddressEng;
    return this.roadAddress;
  }

  Future<Location> get latLng async =>
      (await locationFromAddress(addressEng, localeIdentifier: 'ko-KR')).last;
}
