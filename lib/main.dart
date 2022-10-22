import 'package:authing_sdk_v3/authing.dart';
import 'package:authing_sdk_v3/client.dart';
import 'package:authing_sdk_v3/oidc/auth_request.dart';
import 'package:authing_sdk_v3/oidc/oidc_client.dart';
import 'package:authing_sdk_v3/options/login_options.dart';
import 'package:authing_sdk_v3/options/register_options.dart';
import 'package:authing_sdk_v3/result.dart';
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
    Authing.init("6204d0a406f0423c78f243ae", "6244398c8a4575cdb2cb5656");

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
                  // Navigator.of(context).push(MaterialPageRoute(
                      // builder: (context) =>
                          // WebExample(url: url, authData: authData)));
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

                  // var opt = ();
                  AuthResult result = await AuthClient.loginByEmail("12563438@qq.com", "123456");
                  print(result.statusCode);
                  print(result.apiCode);
                  print(result.message);
                  print(result.data);
                  print(result.user?.accessToken);

                  return;
                  // AuthResult result = await AuthClient.logout();
                  print(result.statusCode);
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
              const SizedBox(height: 12),
              MaterialButton(
                onPressed: () async {
                  // AuthResult result = await AuthClient.getCurrentUser();
                  // print(result.statusCode);
                  // print(result.message);
                  // print(result.user?.username);
                },
                child: const Text(
                  'getUserInfo',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.indigo[700],
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
          // Navigator.of(context).push(MaterialPageRoute(
              // builder: (context) => WebExample(url: url, authData: authData)));
        },
        tooltip: 'webView',
        child: const Icon(Icons.forward),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
