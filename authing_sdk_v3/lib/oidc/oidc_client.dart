import 'dart:convert';
import 'dart:io';

import 'package:authing_sdk_v3/client.dart';
import 'package:authing_sdk_v3/oidc/auth_request.dart';
import 'package:authing_sdk_v3/user.dart';
import 'package:authing_sdk_v3/util.dart';

import '../authing.dart';
import '../result.dart';
import 'cookie_manager.dart';

class OIDCClient {
  /// Build authorize URL
  static Future<String> buildAuthorizeUrl(AuthRequest authRequest) async {
    String? secret = authRequest.clientSecret;
    return 'https://' +
        Util.getHost(Authing.config) +
        '/oidc/auth?_authing_lang=' +
        authRequest.authingLang +
        "&app_id=" +
        Authing.sAppId +
        "&client_id=" +
        Authing.sAppId +
        "&nonce=" +
        authRequest.nonce +
        "&redirect_uri=" +
        authRequest.redirectUrl +
        "&response_type=" +
        authRequest.responseType +
        "&scope=" +
        authRequest.scope +
        "&prompt=consent" +
        "&state=" +
        authRequest.state +
        (secret == null
            ? "&code_challenge=" +
                authRequest.codeChallenge +
                "&code_challenge_method=S256"
            : "");
  }

  /// Build logout URL
  static Future<String> buildLogoutUrl(AuthRequest authRequest) async {
    String? secret = authRequest.clientSecret;
    AuthResult result = await AuthClient.getCurrentUser();
    if (result.user == null) {
      return '';
    } else {
      return 'https://' +
          Util.getHost(Authing.config) +
          '/oidc/session/end?id_token_hint=' + (result.user?.idToken ?? '') + '&post_logout_redirect_uri=' + authRequest.redirectUrl;
    }
  }

  /// OIDC prepare
  static Future<AuthRequest> prepareLogin() async {
    AuthRequest authData = AuthRequest();
    authData.createAuthRequest();
    return authData;
  }

  ///Auth by code #
  static Future<AuthResult> authByCode(
      String code, AuthRequest authRequest) async {
    String url = "https://" + Util.getHost(Authing.config) + "/oidc/token";
    String body = "client_id=" +
        Authing.sAppId +
        "&grant_type=authorization_code" +
        "&code=" +
        code +
        "&scope=" +
        authRequest.scope +
        "&prompt=" +
        "consent" +
        "&code_verifier=" +
        authRequest.codeVerifier +
        "&redirect_uri=" +
        Uri.encodeComponent(authRequest.redirectUrl);

    Result result = await oauthRequest("post", url, body);

    AuthResult authResult = AuthResult(result);

    if (authResult.statusCode == 200 || authResult.statusCode == 201) {
      AuthResult userResult = await AuthClient.getCurrentUser();
      authResult.user =
          await User.update(userResult.user ?? User(), result.data);
      return authResult;
    } else {
      return authResult;
    }
  }

  ///Auth by Authing token
  static Future<AuthResult> authByToken(
      String token, AuthRequest authRequest) async {
    String url = "https://" + Util.getHost(Authing.config) + "/oidc/token";
    String body = "client_id=" +
        Authing.sAppId +
        "&grant_type=http://authing.cn/oidc/grant_type/authing_token" +
        "&token=" +
        token +
        "&scope=" +
        authRequest.scope +
        "&prompt=" +
        "consent" +
        "&code_verifier=" +
        authRequest.codeVerifier +
        "&redirect_uri=" +
        Uri.encodeComponent(authRequest.redirectUrl);

    Result result = await oauthRequest("post", url, body);
    AuthResult authResult = AuthResult(result);
    if (authResult.statusCode == 200 || authResult.statusCode == 201) {
      AuthResult userResult = await AuthClient.getCurrentUser();
      authResult.user =
          await User.update(userResult.user ?? User(), result.data);
      return authResult;
    } else {
      return authResult;
    }
  }

  static Future<Result> oauthRequest(
      String method, String uri, String body) async {
    var url = Uri.parse(uri);
    var client = HttpClient();
    HttpClientRequest request = await client.postUrl(url);
    request.headers.set('x-authing-request-from', 'sdk-flutter');
    request.headers.set('x-authing-lang', Util.getLangHeader());

    if (method.toLowerCase() == "post".toLowerCase()) {
      String type = (body.startsWith('{') || body.startsWith("[")) &&
              (body.endsWith("]") || body.endsWith("}"))
          ? "application/json; charset=utf-8"
          : "application/x-www-form-urlencoded; charset=utf-8";

      request.headers.set("content-type", type);
    }

    request.add(utf8.encode(body));

    HttpClientResponse response = await request.close();
    var res = await response.transform(utf8.decoder).join();
    Result result = Result();
    if (response.statusCode == 200 || response.statusCode == 201) {
      CookieManager().addCookies(response);
      result.statusCode = 200;
      result.message = "success";
      result.data = jsonDecode(res);
      return result;
    } else {
      result.statusCode = response.statusCode;
      result.message = "authRequest failed. " + res;
      return result;
    }
  }

  ///Token Change user information
  static Future<Result> getUserInfoByAccessToken(String accessToken,
      [Map? data]) async {
    String url = "https://" + Util.getHost(Authing.config) + "/oidc/me";
    var client = HttpClient();
    HttpClientRequest request = await client.getUrl(Uri.parse(url));

    request.headers.set("Authorization", "Bearer " + accessToken);

    HttpClientResponse response = await request.close();
    var res = await response.transform(utf8.decoder).join();
    Result result = Result();
    if (response.statusCode == 200) {
      result.statusCode = 200;
      result.message = "success";
      result.data = jsonDecode(res);
      // AuthResult authResult = AuthResult(result);
      // authResult.user = await AuthClient.createUser(result);
      // authResult.user =
      //     await User.update(authResult.user ?? User(), data ?? {});
      return result;
    } else {
      result.statusCode = response.statusCode;
      result.message = "getUserInfoByAccessToken failed. " + res;
      return result;
    }
  }

  ///Refresh Access Token
  static Future<AuthResult> getNewAccessTokenByRefreshToken(
      String refreshToken) async {
    String url = "https://" + Util.getHost(Authing.config) + "/oidc/token";
    String body = "client_id=" +
        Authing.sAppId +
        "&grant_type=refresh_token" +
        "&refresh_token=" +
        refreshToken;

    Result result = await oauthRequest("post", url, body);

    AuthResult authResult = AuthResult(result);

    if (authResult.statusCode == 200 || authResult.statusCode == 201) {
      authResult.user = User.create(result.data);

      return authResult;
    } else {
      return authResult;
    }
  }
}
