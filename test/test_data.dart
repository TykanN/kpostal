import 'dart:convert';

/// 카카오 우편번호 서비스가 반환하는 실제 형태의 샘플 JSON.
const String sampleKpostalJsonString =
    '{"postcode":"","postcode1":"","postcode2":"","postcodeSeq":"","zonecode":"08758","address":"서울 관악구 남부순환로 1801","addressEnglish":"1801, Nambusunhwan-ro, Gwanak-gu, Seoul, Korea","addressType":"R","bcode":"1162010100","bname":"봉천동","bnameEnglish":"Bongcheon-dong","bname1":"","bname1English":"","bname2":"봉천동","bname2English":"Bongcheon-dong","sido":"서울","sidoEnglish":"Seoul","sigungu":"관악구","sigunguEnglish":"Gwanak-gu","sigunguCode":"11620","userLanguageType":"K","query":"남부순환로 1801","buildingName":"","buildingCode":"1162010100108740004026943","apartment":"N","jibunAddress":"서울 관악구 봉천동 874-4","jibunAddressEnglish":"874-4, Bongcheon-dong, Gwanak-gu, Seoul, Korea","roadAddress":"서울 관악구 남부순환로 1801","roadAddressEnglish":"1801, Nambusunhwan-ro, Gwanak-gu, Seoul, Korea","autoRoadAddress":"","autoRoadAddressEnglish":"","autoJibunAddress":"","autoJibunAddressEnglish":"","userSelectedType":"R","noSelected":"N","hname":"","roadnameCode":"2000003","roadname":"남부순환로","roadnameEnglish":"Nambusunhwan-ro"}';

/// 샘플 JSON을 [overrides]로 일부 필드만 바꿔 반환합니다.
Map<String, dynamic> sampleKpostalJson([
  Map<String, dynamic> overrides = const {},
]) => {
  ...jsonDecode(sampleKpostalJsonString) as Map<String, dynamic>,
  ...overrides,
};
