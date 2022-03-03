import 'dart:convert';

import 'package:authing_sdk/oidc/auth_request.dart';
import 'package:authing_sdk/oidc/oidc_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'authing.dart';
import 'result.dart';
import 'user.dart';
import 'util.dart';

class AuthClient {
  static const String keyToken = "authing_id_token";
  static User? currentUser;

  /// register a new user by email address and a password.
  static Future<AuthResult> registerByEmail(
      String email, String password) async {
    var body = jsonEncode({
      'email': email,
      'password': Util.encrypt(password),
      'forceLogin': true
    });
    final Result result = await post('/api/v2/register/email', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// register a new user by username and a password.
  static Future<AuthResult> registerByUserName(
      String username, String password) async {
    var body = jsonEncode({
      'username': username,
      'password': Util.encrypt(password),
      'forceLogin': true
    });
    final Result result = await post('/api/v2/register/username', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// register a new user by phone number and an SMS verification code.
  static Future<AuthResult> registerByPhoneCode(
      String phone, String code, String password) async {
    var body = jsonEncode({
      'phone': phone,
      'code': code,
      'password': Util.encrypt(password),
      'forceLogin': true
    });
    final Result result = await post('/api/v2/register/phone-code', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// login by account and password.
  static Future<AuthResult> loginByAccount(String account, String password,
      {AuthRequest? authData}) async {
    var body =
        jsonEncode({'account': account, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/login/account', body);

    if (authData == null) {
      AuthResult authResult = AuthResult(result);
      authResult.user = await createUser(result);
      return authResult;
    } else {
      AuthResult authResult = AuthResult(result);
      authResult.user = await createUser(result);

      if (authResult.code == 200) {
        authData.token = authResult.user?.token ?? "";

        return OIDCClient.oidcInteraction(authData);
      } else {
        return authResult;
      }
    }
  }

  /// login by phone number and an SMS verification code.
  static Future<AuthResult> loginByPhoneCode(String phone, String code) async {
    var body = jsonEncode({'phone': phone, 'code': code});
    final Result result = await post('/api/v2/login/phone-code', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// login by LDAP username and password.
  static Future<AuthResult> loginByLDAP(
      String username, String password) async {
    var body =
        jsonEncode({'username': username, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/login/ldap', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// login by AD username and password.
  static Future<AuthResult> loginByAD(String username, String password) async {
    var body =
        jsonEncode({'username': username, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/login/ad', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// get current logged in user's profile.
  static Future<AuthResult> getCurrentUser() async {
    final Result result = await get('/api/v2/users/me');
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// logout.
  static Future<AuthResult> logout() async {
    final Result result = await get('/api/v2/logout?app_id=' + Authing.sAppId);
    currentUser = null;
    return AuthResult(result);
  }

  /// send an SMS code.
  static Future<AuthResult> sendSms(String phone,
      [String? phoneCountryCode]) async {
    Map map = {};
    map.putIfAbsent('phone', () => phone);
    if (phoneCountryCode != null) {
      map.putIfAbsent('phoneCountryCode', () => phoneCountryCode);
    }
    final Result result = await post('/api/v2/sms/send', jsonEncode(map));
    return AuthResult(result);
  }

  /// send an email.
  static Future<AuthResult> sendEmail(String email, String scene) async {
    var body = jsonEncode({'email': email, 'scene': scene});
    final Result result = await post('/api/v2/email/send', body);
    return AuthResult(result);
  }

  /// get user's custom data. custom field should be defined via Authing console.
  static Future<AuthResult> getCustomData(String userId) async {
    final Result result =
        await get('/api/v2/udfs/values?targetType=USER&targetId=' + userId);
    if (result.data["data"] is List) {
      currentUser?.setCustomData(result.data["data"] as List);
    }
    return AuthResult(result);
  }

  /// set user's custom data.
  static Future<AuthResult> setCustomData(List data) async {
    List list = [];
    for (var element in data) {
      Map map = {};
      map.putIfAbsent("definition", () => element["key"]);
      map.putIfAbsent("value", () => element["value"]);
      list.add(map);
    }
    var body = jsonEncode({'udfs': list});
    final Result result = await post('/api/v2/udfs/values', body);
    if (result.data["data"] is List) {
      currentUser?.setCustomData(result.data["data"] as List);
    }
    return AuthResult(result);
  }

  /// reset password by phone number and an SMS code.
  static Future<AuthResult> resetPasswordByPhoneCode(
      String phone, String code, String password) async {
    var body = jsonEncode(
        {'phone': phone, 'code': code, 'newPassword': Util.encrypt(password)});
    final Result result = await post('/api/v2/password/reset/sms', body);
    return AuthResult(result);
  }

  /// reset password by email and an email code.
  static Future<AuthResult> resetPasswordByEmailCode(
      String email, String code, String password) async {
    var body = jsonEncode(
        {'email': email, 'code': code, 'newPassword': Util.encrypt(password)});
    final Result result = await post('/api/v2/password/reset/email', body);
    return AuthResult(result);
  }

  /// update current user's profile.
  static Future<AuthResult> updateProfile(Map map) async {
    var body = jsonEncode(map);
    final Result result = await post('/api/v2/users/profile/update', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// update current user's password.
  static Future<AuthResult> updatePassword(String newPassword,
      [String? oldPassword]) async {
    Map map = {};
    map.putIfAbsent('newPassword', () => Util.encrypt(newPassword));
    if (oldPassword != null) {
      map.putIfAbsent('oldPassword', () => Util.encrypt(oldPassword));
    }
    final Result result =
        await post('/api/v2/password/update', jsonEncode(map));
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// bind phone to current user.
  static Future<AuthResult> bindPhone(String phone, String code) async {
    var body = jsonEncode({'phone': phone, 'phoneCode': code});
    final Result result = await post('/api/v2/users/phone/bind', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// unbind current user's phone number.
  static Future<AuthResult> unbindPhone() async {
    final Result result = await post('/api/v2/users/phone/unbind');
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// 2230 same phone number
  /// 1320004 phone already bind
  static Future<AuthResult> updatePhone(String phone, String phoneCode,
      [String? oldPhone,
      String? oldPhoneCode,
      String? phoneCountryCode,
      String? oldPhoneCountryCode]) async {
    Map map = {};
    map.putIfAbsent('phone', () => phone);
    map.putIfAbsent('phoneCode', () => phoneCode);
    if (oldPhone != null && oldPhoneCode != null) {
      map.putIfAbsent('oldPhone', () => oldPhone);
      map.putIfAbsent('oldPhoneCode', () => oldPhoneCode);
    }
    if (phoneCountryCode != null) {
      map.putIfAbsent('phoneCountryCode', () => phoneCountryCode);
    }
    if (oldPhoneCountryCode != null) {
      map.putIfAbsent('oldPhoneCountryCode', () => oldPhoneCountryCode);
    }
    final Result result =
        await post('/api/v2/users/phone/update', jsonEncode(map));
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// bind email to current user.
  static Future<AuthResult> bindEmail(String email, String code) async {
    var body = jsonEncode({'email': email, 'emailCode': code});
    final Result result = await post('/api/v2/users/email/bind', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// unbind email to current user.
  // 1320009 no email
  // 1320010 no other login method
  static Future<AuthResult> unbindEmail() async {
    final Result result = await post('/api/v2/users/email/unbind');
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// update current user's email address.
  static Future<AuthResult> updateEmail(String email, String emailCode,
      [String? oldEmail, String? oldEmailCode]) async {
    Map map = {};
    map.putIfAbsent('email', () => email);
    map.putIfAbsent('emailCode', () => emailCode);
    if (oldEmail != null && oldEmailCode != null) {
      map.putIfAbsent('oldEmail', () => oldEmail);
      map.putIfAbsent('oldEmailCode', () => oldEmailCode);
    }
    final Result result =
        await post('/api/v2/users/email/update', jsonEncode(map));
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// link current user with a social account
  static Future<AuthResult> link(
      String primaryUserToken, String secondaryUserToken) async {
    var body = jsonEncode({
      'primaryUserToken': primaryUserToken,
      'secondaryUserToken': secondaryUserToken
    });
    final Result result = await post('/api/v2/users/link', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// unlink current user with a social account
  static Future<AuthResult> unlink(String provider) async {
    Map map = {};
    map.putIfAbsent('provider', () => provider);
    if (currentUser != null) {
      map.putIfAbsent('primaryUserToken', () => currentUser!.token);
    }
    final Result result = await post('/api/v2/users/unlink', jsonEncode(map));
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// 0 low; 1 medium; 2 high
  static int computePasswordSecurityLevel(String password) {
    if (password.length < 6) {
      return 0;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasEnglish = hasUppercase || hasLowercase;
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (hasEnglish && hasDigits && hasSpecialCharacters) {
      return 2;
    } else if ((hasEnglish && hasDigits) ||
        (hasEnglish && hasSpecialCharacters) ||
        (hasDigits && hasSpecialCharacters)) {
      return 1;
    } else {
      return 0;
    }
  }

  /// get current account's security level
  static Future<Result> getSecurityLevel() async {
    return await get('/api/v2/users/me/security-level');
  }

  /// list current user's roles
  static Future<Result> listRoles([String? namespace]) async {
    final Result result = await get('/api/v2/users/me/roles' +
        (namespace == null ? "" : "?namespace=" + namespace));
    return result;
  }

  /// list authorized resources that current user's can access
  static Future<Map> listAuthorizedResources(String namespace,
      [String? resourceType]) async {
    Map map = {};
    map.putIfAbsent('namespace', () => namespace);
    if (resourceType != null) {
      map.putIfAbsent('resourceType', () => resourceType);
    }
    final Result result =
        await post('/api/v2/users/resource/authorized', jsonEncode(map));
    return result.data;
  }

  /// get new id token
  static Future<AuthResult> updateIdToken() async {
    final Result result = await post('/api/v2/users/refresh-token', null);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// list applications that current user's can access
  static Future<Result> listApplications(
      [int? page = 1, int? limit = 10]) async {
    return await get('/api/v2/users/me/applications/allowed?page=' +
        page.toString() +
        "&limit=" +
        limit.toString());
  }

  /// list organizations that current user is part of
  static Future<Result> listOrgs() async {
    if (currentUser != null) {
      return await get('/api/v2/users/' + currentUser!.id + "/orgs");
    } else {
      Result result = Result();
      result.code = 500;
      return result;
    }
  }

  /// reset password by first time login token
  static Future<AuthResult> resetPasswordByFirstLoginToken(
      String token, String password) async {
    var body = jsonEncode({'token': token, 'password': Util.encrypt(password)});
    final Result result =
        await post('/api/v2/users/password/reset-by-first-login-token', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = await createUser(result);
    }
    return authResult;
  }

  /// login by wechat auth code
  static Future<AuthResult> loginByWechat(String connId, String code) async {
    return socialLogin("wechatMobile", connId, code);
  }

  /// login by alipay auth code
  static Future<AuthResult> loginByAlipay(String connId, String code) async {
    return socialLogin("alipay", connId, code);
  }

  /// login by apple auth code
  static Future<AuthResult> loginByApple(String code) async {
    var body = jsonEncode({'code': code});
    final Result result = await post(
        'connection/social/apple/' +
            Authing.sUserPoolId +
            '/callback?app_id=' +
            Authing.sAppId,
        jsonEncode(body));
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// general social login method
  static Future<AuthResult> socialLogin(
      String type, String connId, String code) async {
    var body = jsonEncode({'connId': connId, 'code': code});
    final Result result =
        await post('/api/v2/ecConn/' + type + '/authByCode', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// check if phone number or email address can be used for MFA
  static Future<bool> mfaCheck(String? phone, String? email) async {
    Map map = {};
    if (phone != null) {
      map.putIfAbsent('phone', () => phone);
    }
    if (email != null) {
      map.putIfAbsent('email', () => email);
    }
    final Result result =
        await post('/api/v2/applications/mfa/check', jsonEncode(map));
    if (result.code == 200) {
      return result.data["data"];
    }
    return false;
  }

  /// MFA by phone number and SMS verify code
  static Future<AuthResult> mfaVerifyByPhone(String phone, String code) async {
    var body = jsonEncode({'phone': phone, 'code': code});
    final Result result =
        await post('/api/v2/applications/mfa/sms/verify', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// MFA by email address and SMS verify code
  static Future<AuthResult> mfaVerifyByEmail(String email, String code) async {
    var body = jsonEncode({'email': email, 'code': code});
    final Result result =
        await post('/api/v2/applications/mfa/email/verify', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// MFA TOTP (Time-based One Time Password)
  static Future<AuthResult> mfaVerifyByTOTP(String code) async {
    var body = jsonEncode({'authenticatorType': 'totp', 'totp': code});
    final Result result =
        await post('/api/v2/applications/mfa/totp/verify', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// MFA by recovery code
  static Future<AuthResult> mfaVerifyByRecoveryCode(String code) async {
    var body = jsonEncode({'authenticatorType': 'totp', 'recoveryCode': code});
    final Result result =
        await post('/api/v2/applications/mfa/totp/recovery', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// delete account (irreversible)
  static Future<Result> deleteAccount() async {
    return await delete('/api/v2/users/delete');
  }

  /// mark qr code as scanned. web page will show avatar on top
  static Future<Result> markQRCodeScanned(String ticket) async {
    return await post('/api/v2/qrcode/scanned', jsonEncode({'random': ticket}));
  }

  /// login by QR code
  static Future<Result> loginByScannedTicket(String ticket) async {
    return await post('/api/v2/qrcode/confirm', jsonEncode({'random': ticket}));
  }

  /// auth by OIDC code
  static Future<AuthResult> authByCode(
      String code, String codeVerifier, String redirectUrl) async {
    String body = "client_id=" +
        Authing.sAppId +
        "&grant_type=authorization_code" +
        "&code=" +
        code +
        "&code_verifier=" +
        codeVerifier +
        "&redirect_uri=" +
        redirectUrl;
    var url = Uri.parse('https://' + Authing.sHost + '/oidc/token');
    Map<String, String> headers = {
      "x-authing-userpool-id": Authing.sUserPoolId,
      "x-authing-app-id": Authing.sAppId,
      "x-authing-request-from": "sdk-flutter",
      "x-authing-sdk-version": Authing.VERSION,
      "content-type": "application/x-www-form-urlencoded"
    };
    var response = await http.post(url, headers: headers, body: body);
    final Result result = parseResponse(response);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  static Future<User?> createUser(Result result) async {
    if (result.code == 200) {
      currentUser = User.create(result.data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyToken, currentUser!.token);
    } else if (result.code == 1636) {
      currentUser = User();
      currentUser!.mfaToken = result.data["mfaToken"];
    } else if (result.code == 1639) {
      currentUser = User();
      currentUser!.firstTimeLoginToken = result.data["token"];
    }
    return currentUser;
  }

  static Future<Result> get(String endpoint) {
    String url = 'https://' + Authing.sHost + endpoint;
    return request("get", url, null);
  }

  static Future<Result> post(String endpoint, [String? body]) {
    String url = 'https://' + Authing.sHost + endpoint;
    return request("post", url, body);
  }

  static Future<Result> delete(String endpoint, [String? body]) {
    String url = 'https://' + Authing.sHost + endpoint;
    return request("delete", url, body);
  }

  static Future<Result> request(String method, String uri,
      [String? body]) async {
    var url = Uri.parse(uri);
    Map<String, String> headers = {
      "x-authing-userpool-id": Authing.sUserPoolId,
      "x-authing-app-id": Authing.sAppId,
      "x-authing-request-from": "sdk-flutter",
      "x-authing-sdk-version": Authing.VERSION,
      "content-type": "application/json"
    };
    if (currentUser != null) {
      if (currentUser!.mfaToken != null) {
        headers.putIfAbsent(
            "Authorization", () => "Bearer " + currentUser!.mfaToken!);
      } else {
        headers.putIfAbsent(
            "Authorization", () => "Bearer " + currentUser!.token);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(keyToken);
      if (token != null) {
        headers.putIfAbsent("Authorization", () => "Bearer " + token);
      }
    }

    method = method.toLowerCase();
    http.Response? response;
    if (method == 'get') {
      response = await http.get(url, headers: headers);
    } else if (method == 'post') {
      response = await http.post(url, headers: headers, body: body);
    } else if (method == 'delete') {
      response = await http.delete(url, headers: headers, body: body);
    }
    return parseResponse(response);
  }

  static Result parseResponse(response) {
    Result result = Result();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map parsed = jsonDecode(response.body);
      if (parsed.containsKey("code")) {
        result.code = parsed["code"] as int;
      } else {
        result.code = 200;
      }
      if (parsed.containsKey("message")) {
        result.message = parsed["message"] as String;
      }
      if (parsed.containsKey("data")) {
        if (parsed["data"] is Map) {
          result.data = parsed["data"];
        } else {
          result.data = parsed;
        }
      } else {
        result.data = parsed;
      }
    } else {
      result.code = response.statusCode;
      result.message = "network error";
    }
    return result;
  }
}
