import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:kpostal/kpostal.dart';

void main() {
  test('Kpostal 모델 json 파싱', () {
    const text =
        '{"postcode":"","postcode1":"","postcode2":"","postcodeSeq":"","zonecode":"08758","address":"서울 관악구 남부순환로 1801","addressEnglish":"1801, Nambusunhwan-ro, Gwanak-gu, Seoul, Korea","addressType":"R","bcode":"1162010100","bname":"봉천동","bnameEnglish":"Bongcheon-dong","bname1":"","bname1English":"","bname2":"봉천동","bname2English":"Bongcheon-dong","sido":"서울","sidoEnglish":"Seoul","sigungu":"관악구","sigunguEnglish":"Gwanak-gu","sigunguCode":"11620","userLanguageType":"K","query":"남부순환로 1801","buildingName":"","buildingCode":"1162010100108740004026943","apartment":"N","jibunAddress":"서울 관악구 봉천동 874-4","jibunAddressEnglish":"874-4, Bongcheon-dong, Gwanak-gu, Seoul, Korea","roadAddress":"서울 관악구 남부순환로 1801","roadAddressEnglish":"1801, Nambusunhwan-ro, Gwanak-gu, Seoul, Korea","autoRoadAddress":"","autoRoadAddressEnglish":"","autoJibunAddress":"","autoJibunAddressEnglish":"","userSelectedType":"R","noSelected":"N","hname":"","roadnameCode":"2000003","roadname":"남부순환로","roadnameEnglish":"Nambusunhwan-ro"}';
    final model = Kpostal.fromJson(jsonDecode(text));

    expect(model.postCode, '08758');
    expect(model.sido, '서울');
    expect(model.sigungu, '관악구');
    expect(model.bname, '봉천동');
    expect(model.jibunAddress, '서울 관악구 봉천동 874-4');
    expect(model.roadAddress, '서울 관악구 남부순환로 1801');
  });
}
