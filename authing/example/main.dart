import 'package:authing_sdk/authing.dart';
import 'package:authing_sdk/client.dart';
import 'package:authing_sdk/result.dart';

class MyApp {
  String pool = "pool id";
  String appId = "app id";

  login() async {
    Authing.init(pool, appId);
    AuthResult result = await AuthClient.loginByAccount("username / phone/ email", "clear text password");
    print(result.code); // 200 upon success
  }
}