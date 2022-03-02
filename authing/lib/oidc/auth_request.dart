import 'package:authing_sdk/authing.dart';
import 'package:authing_sdk/util.dart';

class AuthRequest {
  late String clientId;
  late String finishLoginUrl;
  late String nonce;
  late String redirectUrl;
  late String responseType;
  late String scope;
  late String state;
  late String uuid;
  late String authingLang;
  late String codeVerifier;
  late String codeChallenge;
  late String token;

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
    codeChallenge = Util.generateCodeChallenge(codeVerifier);
  }
}
