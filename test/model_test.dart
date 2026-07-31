import 'package:flutter_test/flutter_test.dart';
import 'package:kpostal/kpostal.dart';

import 'test_data.dart';

void main() {
  group('Kpostal.fromJson', () {
    test('기본 필드 파싱', () {
      final model = Kpostal.fromJson(sampleKpostalJson());

      expect(model.postCode, '08758');
      expect(model.sido, '서울');
      expect(model.sigungu, '관악구');
      expect(model.bname, '봉천동');
      expect(model.jibunAddress, '서울 관악구 봉천동 874-4');
      expect(model.roadAddress, '서울 관악구 남부순환로 1801');
      expect(
        model.addressEng,
        '1801, Nambusunhwan-ro, Gwanak-gu, Seoul, Korea',
      );
      expect(model.buildingCode, '1162010100108740004026943');
      expect(model.apartment, 'N');
    });

    test('jibunAddress가 비어 있으면 autoJibunAddress로 폴백', () {
      final model = Kpostal.fromJson(
        sampleKpostalJson({
          'jibunAddress': '',
          'jibunAddressEnglish': '',
          'autoJibunAddress': '서울 관악구 봉천동 999-9',
          'autoJibunAddressEnglish': '999-9, Bongcheon-dong, Seoul, Korea',
        }),
      );

      expect(model.jibunAddress, '서울 관악구 봉천동 999-9');
      expect(model.jibunAddressEng, '999-9, Bongcheon-dong, Seoul, Korea');
    });

    test('카카오 경위도 파싱', () {
      final model = Kpostal.fromJson(
        sampleKpostalJson({'kakaoLat': '37.478', 'kakaoLng': '126.945'}),
      );

      expect(model.kakaoLatitude, 37.478);
      expect(model.kakaoLongitude, 126.945);
    });

    test('카카오 경위도가 없거나 잘못된 값이면 null', () {
      final absent = Kpostal.fromJson(sampleKpostalJson());
      expect(absent.kakaoLatitude, isNull);
      expect(absent.kakaoLongitude, isNull);

      final invalid = Kpostal.fromJson(
        sampleKpostalJson({'kakaoLat': 'abc', 'kakaoLng': ''}),
      );
      expect(invalid.kakaoLatitude, isNull);
      expect(invalid.kakaoLongitude, isNull);
    });
  });

  group('userSelectedAddress', () {
    test('도로명(R) + 한글(K) 선택 시 도로명 주소', () {
      final model = Kpostal.fromJson(
        sampleKpostalJson({'userSelectedType': 'R', 'userLanguageType': 'K'}),
      );
      expect(model.userSelectedAddress, model.roadAddress);
    });

    test('도로명(R) + 영문(E) 선택 시 영문 도로명 주소', () {
      final model = Kpostal.fromJson(
        sampleKpostalJson({'userSelectedType': 'R', 'userLanguageType': 'E'}),
      );
      expect(model.userSelectedAddress, model.roadAddressEng);
    });

    test('지번(J) + 한글(K) 선택 시 지번 주소', () {
      final model = Kpostal.fromJson(
        sampleKpostalJson({'userSelectedType': 'J', 'userLanguageType': 'K'}),
      );
      expect(model.userSelectedAddress, model.jibunAddress);
    });

    test('지번(J) + 영문(E) 선택 시 영문 지번 주소', () {
      final model = Kpostal.fromJson(
        sampleKpostalJson({'userSelectedType': 'J', 'userLanguageType': 'E'}),
      );
      expect(model.userSelectedAddress, model.jibunAddressEng);
    });
  });
}
