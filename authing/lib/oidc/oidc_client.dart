import 'dart:io';

import 'package:authing_sdk/client.dart';
import 'package:authing_sdk/oidc/auth_request.dart';

import '../authing.dart';
import '../result.dart';
import 'cookie_manager.dart';

class OIDCClient {
  /// auth by OIDC code
  static Future<AuthResult> prepareLogin() async {
    AuthRequest authData = AuthRequest();
    authData.createAuthRequest();
    var url = Uri.parse('https://' +
        Authing.sHost +
        '/oidc/auth?_authing_lang=' +
        authData.authingLang +
        "&app_id=" +
        Authing.sAppId +
        "&client_id=" +
        Authing.sAppId +
        "&nonce=" +
        authData.nonce +
        "&redirect_uri=" +
        authData.redirectUrl +
        "&response_type=" +
        authData.responseType +
        "&scope=" +
        authData.scope +
        "&prompt=consent" +
        "&state=" +
        authData.state +
        "&code_challenge=" +
        authData.codeChallenge +
        "&code_challenge_method=" +
        'S256');

    var client = HttpClient();
    HttpClientRequest request = await client.getUrl(url);
    request.followRedirects = false;

    HttpClientResponse response = await request.close();

    final Result result = AuthClient.parseResponse(response);

    if (response.statusCode == 302) {
      CookieManager().addCookies(response);
      String? location = response.headers["location"]?.first;
      String uuid = Uri.parse(location ?? '').pathSegments.last;
      authData.uuid = uuid;

      AuthResult authResult = AuthResult(result, authRequest: authData);
      return authResult;
    } else {
      AuthResult authResult = AuthResult(result);
      return authResult;
    }
  }

  static Future<AuthResult> loginByAccount(
      String account, String password) async {
    AuthResult authResult = await OIDCClient.prepareLogin();
    if (authResult.code == 200) {
      return AuthClient.loginByAccount(account, password,
          authData: authResult.authData);
    } else {
      return authResult;
    }
  }

  static Future<AuthResult> oidcInteraction(AuthRequest authData) async {
    var url = Uri.parse('https://' +
        Authing.sHost +
        '/interaction/oidc/' +
        authData.uuid +
        "/login");

    String body = "token=" + authData.token;

    var client = HttpClient();
    HttpClientRequest request = await client.postUrl(url);
    request.followRedirects = false;
    String cookie = CookieManager().getCookie();
    print(cookie);
    request.headers.contentType = ContentType(
        "application/x-www-form-urlencoded", "json",
        charset: "charset=utf-8");
    if (cookie.isNotEmpty) {
      request.headers.add(HttpHeaders.cookieHeader, cookie);
    }

    request.write(body);

    HttpClientResponse response = await request.close();
    print(response.statusCode);
    final Result result = AuthClient.parseResponse(response);
    AuthResult authResult = AuthResult(result);

    return authResult;
  }
}
