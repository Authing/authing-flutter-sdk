import 'package:authing_sdk_v3/authing.dart';
import 'package:authing_sdk_v3/client.dart';
import 'package:authing_sdk_v3/result.dart';

class MyApp {
  String pool = "pool id";
  String appId = "app id";

  login() async {
    Authing.init(pool, appId);
    AuthResult result = await AuthClient.loginByAccount("username / phone/ email", "clear text password");
    print(result.apiCode); // 200 upon success
  }
}