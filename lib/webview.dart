import 'dart:io';

import 'package:authing_sdk/oidc/auth_request.dart';
import 'package:authing_sdk/oidc/oidc_client.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebExample extends StatefulWidget {
  final String url;
  final AuthRequest authData;
  const WebExample({Key? key, required this.url, required this.authData})
      : super(key: key);

  @override
  WebExampleState createState() => WebExampleState();
}

class WebExampleState extends State<WebExample> {
  WebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WebView(
        initialUrl: Uri.encodeFull(widget.url),
        javascriptMode: JavascriptMode.unrestricted,
        debuggingEnabled: true,
        gestureNavigationEnabled: true,
        onWebViewCreated: (WebViewController c) async {
          webViewController = c;
        },
        onPageFinished: (String url) {
          if (url.contains(widget.authData.redirectUrl)) {
            _getAuthCode(url);
          }
        },
        onWebResourceError: (error) {},
        navigationDelegate: (NavigationRequest request) {
          if (request.url.contains(widget.authData.redirectUrl)) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  Future _getAuthCode(String value) async {
    Uri uri = Uri.parse(value);
    String authCode = uri.queryParameters["code"] ?? "";
    if (authCode.isNotEmpty) {
      var res = await OIDCClient.authByCode(authCode, widget.authData);
      print(res.code);
      print(res.user?.accessToken);
    }
  }
}
