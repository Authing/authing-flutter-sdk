import 'package:authing_sdk/authing.dart';
import 'package:authing_sdk/client.dart';
import 'package:authing_sdk/oidc/auth_request.dart';
import 'package:authing_sdk/oidc/oidc_client.dart';
import 'package:authing_sdk/result.dart';
import 'package:flutter/material.dart';

import 'webview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Authing.init("60caaf41da89f1954875cee1", "60caaf41df670b771fd08937");

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              MaterialButton(
                onPressed: () async {
                  var authData = AuthRequest();
                  authData.createAuthRequest();
                  var url = await OIDCClient.buildAuthorizeUrl(authData);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          WebExample(url: url, authData: authData)));
                },
                child: const Text(
                  'webViewLogin',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 70, vertical: 12),
              ),
              const SizedBox(height: 12),
              MaterialButton(
                onPressed: () async {
                  AuthResult result = await AuthClient.logout();
                  print(result.code);
                  print(result.message);
                },
                child: const Text(
                  'logout',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.purple[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 70, vertical: 12),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var authData = AuthRequest();
          authData.createAuthRequest();
          var url = await OIDCClient.buildAuthorizeUrl(authData);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => WebExample(url: url, authData: authData)));
        },
        tooltip: 'webView',
        child: const Icon(Icons.forward),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
