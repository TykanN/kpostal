library kpostal;

export 'src/kpostal_model.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as ia;
import 'package:geocoding/geocoding.dart';
import 'package:kpostal/src/kpostal_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  final Color loadingColor;

  final Widget? onLoading;

  KpostalView(
      {Key? key,
      this.title = '주소검색',
      this.appBarColor = Colors.white,
      this.titleColor = Colors.black,
      this.appBar,
      this.callback,
      this.useLocalServer = false,
      this.localPort = 8080,
      this.loadingColor = Colors.blue,
      this.onLoading})
      : assert(1024 <= localPort && localPort <= 49151,
            'localPort is out of range. It should be from 1024 to 49151(Range of Registered Port)'),
        super(key: key);

  @override
  _KpostalViewState createState() => _KpostalViewState();
}

class _KpostalViewState extends State<KpostalView> {
  late WebViewController _controller;
  WebViewController get controller => _controller;
  bool initLoadComplete = false;

  late ia.InAppWebViewController _inAppController;
  ia.InAppWebViewController get inAppController => _inAppController;
  ia.InAppLocalhostServer? _localhost;
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
      _localhost = ia.InAppLocalhostServer(port: widget.localPort);
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
    if (widget.useLocalServer && !this.isLocalhostOn) {
      return Center(child: CircularProgressIndicator());
    }
    return WebView(
        initialUrl: _initialUrl,
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: <JavascriptChannel>[_channel].toSet(),
        onPageFinished: (_) async {
          setState(() {
            initLoadComplete = true;
          });
        },
        onWebViewCreated: (WebViewController webViewController) async {
          this._controller = webViewController;
        });
  }

  // 자바스크립트 채널
  JavascriptChannel get _channel => JavascriptChannel(
      name: 'onComplete',
      onMessageReceived: (JavascriptMessage message) async {
        Kpostal result = Kpostal.fromJson(jsonDecode(message.message));

        Location _latLng = await result.latLng;
        result.latitude = _latLng.latitude;
        result.longitude = _latLng.longitude;

        if (widget.callback != null) {
          widget.callback!(result);
        }

        Navigator.pop(context, result);
      });
}
