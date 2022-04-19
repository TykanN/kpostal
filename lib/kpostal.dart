library kpostal;

export 'src/kpostal_model.dart';

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kpostal/src/kpostal_model.dart';

class KpostalView extends StatefulWidget {
  static const String routeName = '/kpostal';

  /// AppBar's title
  ///
  /// 앱바 타이틀
  final String title;

  /// AppBar's background color
  ///
  /// 앱바 배경색
  final Color appBarColor;

  /// AppBar's contents color
  ///
  /// 앱바 아이콘, 글자 색상
  final Color titleColor;

  /// this callback function is called when user selects addresss.
  ///
  /// 유저가 주소를 선택했을 때 호출됩니다.
  final Function(Kpostal result)? callback;

  /// build custom AppBar.
  ///
  /// 커스텀 앱바를 추가할 수 있습니다. 추가할 경우 다른 관련 속성은 무시됩니다.
  final PreferredSizeWidget? appBar;

  /// if [userLocalServer] is true, the search page is running on localhost. Default is false.
  ///
  /// [userLocalServer] 값이 ture면, 검색 페이지를 로컬 서버에서 동작시킵니다.
  /// 기본적으로 연결된 웹페이지에 문제가 생기더라도 작동 가능합니다.
  final bool useLocalServer;

  /// Localhost port number. Default is 8080.
  ///
  /// 로컬 서버 포트. 기본값은 8080
  final int localPort;

  /// 웹뷰 로딩 시 인디케이터 색상
  final Color loadingColor;

  /// 웹뷰 로딩 시 표시할 커스텀 위젯
  ///
  /// 해당 옵션 사용 시, 기존 인디케이터를 대체하며, [loadingColor] 옵션은 무시됩니다.
  final Widget? onLoading;

  /// 카카오 API를 통한 경위도 좌표 지오코딩 사용 여부
  final bool useKakaoGeocoder;

  /// [kakaoKey] 설정 시, [kakaoLatitude], [kakaoLongitude] 값을 받을 수 있습니다.
  ///
  /// `developers.kakao.com` 에서 발급받은 유효한 자바스크립트 키를 사용하세요.
  ///
  /// 플랫폼 설정에서 허용 도메인도 추가해야 합니다.
  /// ex) `http://localhost:8080`, `https://tykann.github.io`
  final String kakaoKey;

  KpostalView({
    Key? key,
    this.title = '주소검색',
    this.appBarColor = Colors.white,
    this.titleColor = Colors.black,
    this.appBar,
    this.callback,
    this.useLocalServer = false,
    this.localPort = 8080,
    this.loadingColor = Colors.blue,
    this.onLoading,
    this.kakaoKey = '',
  })  : assert(1024 <= localPort && localPort <= 49151,
            'localPort is out of range. It should be from 1024 to 49151(Range of Registered Port)'),
        useKakaoGeocoder = (kakaoKey != ''),
        super(key: key);

  @override
  _KpostalViewState createState() => _KpostalViewState();
}

class _KpostalViewState extends State<KpostalView> {
  InAppLocalhostServer? _localhost;

  bool initLoadComplete = false;
  bool isLocalhostOn = false;

  @override
  void setState(VoidCallback fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.useLocalServer) {
      _localhost = InAppLocalhostServer(port: widget.localPort);
      _localhost!.start().then((_) {
        setState(() {
          isLocalhostOn = true;
        });
      });
    }
  }

  @override
  void dispose() {
    if (widget.useLocalServer) _localhost?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ??
          AppBar(
            backgroundColor: widget.appBarColor,
            title: Text(
              widget.title,
              style: TextStyle(
                color: widget.titleColor,
              ),
            ),
            iconTheme: IconThemeData().copyWith(color: widget.titleColor),
          ),
      body: Stack(
        children: [
          _buildWebView(),
          initLoadComplete
              ? const SizedBox.shrink()
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Center(
                      child: widget.onLoading ??
                          CircularProgressIndicator(
                              color: widget.loadingColor)),
                ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    String _initialUrl = widget.useLocalServer
        ? 'http://localhost:${widget.localPort}/packages/kpostal/assets/kakao_postcode_localhost.html'
        : 'https://tykann.github.io/kpostal/assets/kakao_postcode.html';

    String _queryParams =
        '?key=${widget.kakaoKey}&enableKakao=${widget.useKakaoGeocoder}';

    if (widget.useLocalServer && !this.isLocalhostOn) {
      return Center(child: CircularProgressIndicator());
    }

    return InAppWebView(
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
        android: AndroidInAppWebViewOptions(useHybridComposition: true),
      ),
      onWebViewCreated: (controller) async {
        // 안드로이드는 롤리팝 버전 이상 빌드에서만 작동 유의
        // WEB_MESSAGE_LISTENER 지원 여부 확인
        if (!Platform.isAndroid || await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.WEB_MESSAGE_LISTENER)) {
          await controller.addWebMessageListener(
            WebMessageListener(
              jsObjectName: "onComplete",
              allowedOriginRules: Set.from(["*"]),
              onPostMessage: (message, sourceOrigin, isMainFrame, replyProxy) => handleMessage(message),
            ),
          );
        }
        else {
          controller.addJavaScriptHandler(
            handlerName: 'onComplete',
            callback: (args) => handleMessage(args[0]),
          );
        }

        await controller.loadUrl(
          urlRequest: URLRequest(
            url: Uri.parse(_initialUrl + _queryParams),
            headers: {},
          ),
        );
      },
      onLoadStop: (_, __) {
        setState(() {
          initLoadComplete = true;
        });
      },
    );
  }

  handleMessage(String? message) async {
    try {
      if (message != null) {
        Kpostal result = Kpostal.fromJson(jsonDecode(message));

        Location? _latLng = await result.latLng;
        if (_latLng != null) {
          result.latitude = _latLng.latitude;
          result.longitude = _latLng.longitude;
        }
        if (widget.callback != null) {
          widget.callback!(result);
        }

        Navigator.pop(context, result);
      } else {
        throw 'fail to load message : message is null';
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }
}
