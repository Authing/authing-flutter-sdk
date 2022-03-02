import 'package:authing_sdk/authing.dart';
import 'package:authing_sdk/util.dart';

class AuthRequest {
  String? clientId;
  String? finishLoginUrl;
  String? nonce;
  String? redirectUrl;
  String? responseType;
  String? scope;
  String? state;
  String? uuid;
  String? authingLang;
  String? codeVerifier;
  String? codeChallenge;
  String? token;

  createAuthRequest() {
    clientId = Authing.sAppId;
    nonce = Util.getRandomString(10);
    redirectUrl =
        "https://console.authing.cn/console/get-started/" + Authing.sAppId;
    responseType = "code";
    scope =
        "openid profile email phone username address offline_access role extended_fields";
    state = Util.getRandomString(10);
    authingLang = Util.getLangHeader();
    codeVerifier = Util.getRandomString(43);
    codeChallenge = Util.generateCodeChallenge(codeVerifier ?? '');
  }
}
