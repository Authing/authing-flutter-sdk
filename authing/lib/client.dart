import 'authing.dart';
import 'util.dart';
import 'user.dart';
import 'result.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthClient {
  static User? currentUser;

  static Future<AuthResult> registerByEmail(
      String email, String password) async {
    var body = jsonEncode({'email': email, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/register/email', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = User.create(result.data);
    return authResult;
  }

  static Future<AuthResult> registerByUserName(
      String username, String password) async {
    var body =
        jsonEncode({'username': username, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/register/username', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = User.create(result.data);
    return authResult;
  }

  static Future<AuthResult> registerByPhoneCode(
      String phone, String code, String password) async {
    var body = jsonEncode(
        {'phone': phone, 'code': code, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/register/phone-code', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = User.create(result.data);
    return authResult;
  }

  static Future<AuthResult> loginByAccount(
      String account, String password) async {
    var body =
        jsonEncode({'account': account, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/login/account', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = createUser(result);
    return authResult;
  }

  static Future<AuthResult> loginByPhoneCode(String phone, String code) async {
    var body = jsonEncode({'phone': phone, 'code': code});
    final Result result = await post('/api/v2/login/phone-code', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = createUser(result);
    return authResult;
  }

  static Future<AuthResult> loginByLDAP(
      String username, String password) async {
    var body =
        jsonEncode({'username': username, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/login/ldap', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = createUser(result);
    return authResult;
  }

  static Future<AuthResult> loginByAD(String username, String password) async {
    var body =
        jsonEncode({'username': username, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/login/ad', body);
    AuthResult authResult = AuthResult(result);
    authResult.user = createUser(result);
    return authResult;
  }

  static Future<AuthResult> getCurrentUser() async {
    final Result result = await get('/api/v2/users/me');
    AuthResult authResult = AuthResult(result);
    authResult.user = User.create(result.data);
    return authResult;
  }

  static Future<AuthResult> logout() async {
    final Result result = await get('/api/v2/logout?app_id=' + Authing.sAppId);
    currentUser = null;
    return AuthResult(result);
  }

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

  static Future<AuthResult> sendEmail(String email, String scene) async {
    var body = jsonEncode({'email': email, 'scene': scene});
    final Result result = await post('/api/v2/email/send', body);
    return AuthResult(result);
  }

  static Future<AuthResult> getCustomData(String userId) async {
    final Result result =
        await get('/api/v2/udfs/values?targetType=USER&targetId=' + userId);
    if (result.data["data"] is List) {
      currentUser?.setCustomData(result.data["data"] as List);
    }
    return AuthResult(result);
  }

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

  static Future<AuthResult> resetPasswordByPhoneCode(
      String phone, String code, String password) async {
    var body = jsonEncode(
        {'phone': phone, 'code': code, 'newPassword': Util.encrypt(password)});
    final Result result = await post('/api/v2/password/reset/sms', body);
    return AuthResult(result);
  }

  static Future<AuthResult> resetPasswordByEmailCode(
      String email, String code, String password) async {
    var body = jsonEncode(
        {'email': email, 'code': code, 'newPassword': Util.encrypt(password)});
    final Result result = await post('/api/v2/password/reset/email', body);
    return AuthResult(result);
  }

  static Future<AuthResult> updateProfile(Map map) async {
    var body = jsonEncode(map);
    final Result result = await post('/api/v2/users/profile/update', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

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
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> bindPhone(String phone, String code) async {
    var body = jsonEncode({'phone': phone, 'phoneCode': code});
    final Result result = await post('/api/v2/users/phone/bind', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> unbindPhone() async {
    final Result result = await post('/api/v2/users/phone/unbind');
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  // 2230 same phone number
  // 1320004 phone already bind
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
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> bindEmail(String email, String code) async {
    var body = jsonEncode({'email': email, 'emailCode': code});
    final Result result = await post('/api/v2/users/email/bind', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  // 1320009 no email
  // 1320010 no other login method
  static Future<AuthResult> unbindEmail() async {
    final Result result = await post('/api/v2/users/email/unbind');
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

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
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> link(
      String primaryUserToken, String secondaryUserToken) async {
    var body = jsonEncode({
      'primaryUserToken': primaryUserToken,
      'secondaryUserToken': secondaryUserToken
    });
    final Result result = await post('/api/v2/users/link', jsonEncode(body));
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> unlink(String provider) async {
    Map map = {};
    map.putIfAbsent('provider', () => provider);
    if (currentUser != null) {
      map.putIfAbsent('primaryUserToken', () => currentUser!.token);
    }
    final Result result = await post('/api/v2/users/unlink', jsonEncode(map));
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  // 0 low; 1 medium; 2 high
  static int computedPasswordSecurityLevel(String password) {
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

  static Future<Result> getSecurityLevel() async {
    return await get('/api/v2/users/me/security-level');
  }

  static Future<Result> listRoles([String? namespace]) async {
    final Result result = await get('/api/v2/users/me/roles' +
        (namespace == null ? "" : "?namespace=" + namespace));
    return result;
  }

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

  static Future<Result> listApplications(
      [int? page = 1, int? limit = 10]) async {
    return await get('/api/v2/users/me/applications/allowed?page=' +
        page.toString() +
        "&limit=" +
        limit.toString());
  }

  // TODO admin required
  static Future<Result> listOrgs() async {
    if (currentUser != null) {
      return await get('/api/v2/users/' + currentUser!.id + "/orgs");
    } else {
      Result result = Result();
      result.code = 500;
      return result;
    }
  }

  static Future<AuthResult> resetPasswordByFirstLoginToken(
      String token, String password) async {
    var body = jsonEncode({'token': token, 'password': Util.encrypt(password)});
    final Result result = await post(
        '/api/v2/users/password/reset-by-first-login-token', jsonEncode(body));
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> loginByWechat(String connId, String code) async {
    return socialLogin("wechatMobile", connId, code);
  }

  static Future<AuthResult> loginByAlipay(String connId, String code) async {
    return socialLogin("alipay", connId, code);
  }

  static Future<AuthResult> loginByApple(String code) async {
    var body = jsonEncode({'code': code});
    final Result result = await post(
        'connection/social/apple/' +
            Authing.sUserPoolId +
            '/callback?app_id=' +
            Authing.sAppId,
        jsonEncode(body));
    AuthResult authResult = AuthResult(result);
    authResult.user = createUser(result);
    return authResult;
  }

  static Future<AuthResult> socialLogin(
      String type, String connId, String code) async {
    var body = jsonEncode({'connId': connId, 'code': code});
    final Result result =
        await post('/api/v2/ecConn/' + type + '/authByCode', jsonEncode(body));
    AuthResult authResult = AuthResult(result);
    authResult.user = createUser(result);
    return authResult;
  }

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

  static Future<AuthResult> mfaVerifyByPhone(String phone, String code) async {
    var body = jsonEncode({'phone': phone, 'code': code});
    final Result result =
        await post('/api/v2/applications/mfa/sms/verify', jsonEncode(body));
    AuthResult authResult = AuthResult(result);
    authResult.user = createUser(result);
    return authResult;
  }

  static Future<AuthResult> mfaVerifyByEmail(String email, String code) async {
    var body = jsonEncode({'email': email, 'code': code});
    final Result result =
        await post('/api/v2/applications/mfa/email/verify', jsonEncode(body));
    AuthResult authResult = AuthResult(result);
    authResult.user = createUser(result);
    return authResult;
  }

  static Future<AuthResult> mfaVerifyByOTP(String code) async {
    var body = jsonEncode({'authenticatorType': 'totp', 'totp': code});
    final Result result =
        await post('/api/v2/applications/mfa/totp/verify', jsonEncode(body));
    AuthResult authResult = AuthResult(result);
    authResult.user = createUser(result);
    return authResult;
  }

  static Future<AuthResult> mfaVerifyByRecoveryCode(String code) async {
    var body = jsonEncode({'authenticatorType': 'totp', 'recoveryCode': code});
    final Result result =
        await post('/api/v2/applications/mfa/totp/recovery', jsonEncode(body));
    AuthResult authResult = AuthResult(result);
    authResult.user = createUser(result);
    return authResult;
  }

  static User? createUser(Result result) {
    if (result.code == 200) {
      currentUser = User.create(result.data);
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
    return request("get", endpoint, null);
  }

  static Future<Result> post(String endpoint, [String? body]) {
    return request("post", endpoint, body);
  }

  static Future<Result> request(String method, String endpoint,
      [String? body]) async {
    var url = Uri.parse('https://' + Authing.sHost + endpoint);
    Map<String, String> headers = {
      "x-authing-userpool-id": Authing.sUserPoolId,
      "x-authing-app-id": Authing.sAppId,
      "x-authing-request-from": "SDK@Flutter",
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
    }
    var response = method.toLowerCase() == "get"
        ? await http.get(url, headers: headers)
        : await http.post(url, headers: headers, body: body);
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
