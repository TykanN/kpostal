library kpostal;

export 'src/kpostal_model.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kpostal/src/kpostal_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KpostalView extends StatefulWidget {
  static const String routeName = '/kpostal';

  final String title;
  final Color appBarColor;
  final Color titleColor;
  final Function(Kpostal result)? callback;
  final PreferredSizeWidget? appBar;

  KpostalView({
    Key? key,
    this.title = '주소검색',
    this.appBarColor = Colors.white,
    this.titleColor = Colors.black,
    this.appBar,
    this.callback,
  }) : super(key: key);

  @override
  _KpostalViewState createState() => _KpostalViewState();
}

class _KpostalViewState extends State<KpostalView> {
  late WebViewController _controller;
  WebViewController get controller => _controller;

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
      body: WebView(
          initialUrl: 'https://tykann.github.io/kpostal/assets/kakao_postcode.html',
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: <JavascriptChannel>[_channel].toSet(),
          onWebViewCreated: (WebViewController webViewController) async {
            _controller = webViewController;
          }),
    );
  }

  JavascriptChannel get _channel => JavascriptChannel(
      name: 'onComplete',
      onMessageReceived: (JavascriptMessage message) {
        Kpostal result = Kpostal.fromJson(jsonDecode(message.message));

        if (widget.callback != null) {
          widget.callback!(result);
        }

        Navigator.pop(context, result);
      });
}
