library kpostal;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KpostalView extends StatefulWidget {
  static const String routeName = '/kpostal';

  final String title;
  final Color appBarColor;
  final Color titleColor;
  final Function? callback;
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
          initialUrl: 'about:blank',
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: <JavascriptChannel>[
            JavascriptChannel(
                name: 'onComplete',
                onMessageReceived: (JavascriptMessage message) {
                  // KopoModel result = KopoModel.fromJson(jsonDecode(message.message));
                  var result = jsonDecode(message.message);
                  print(result);
                  if (widget.callback != null) {
                    widget.callback!(result);
                  }

                  print('asdb');
                  Navigator.pop(context, result);
                }),
          ].toSet(),
          onWebViewCreated: (WebViewController webViewController) async {
            _controller = webViewController;
            String urlText = await rootBundle.loadString('packages/kpostal/assets/kakao_postcode.html');

            _controller.loadUrl(
                Uri.dataFromString(urlText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
          }),
    );
  }
}
