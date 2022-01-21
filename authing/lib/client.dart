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
    if (result.code == 200) {
      authResult.user = User.create(result.data);
    }
    return authResult;
  }

  static Future<AuthResult> registerByUserName(
      String username, String password) async {
    var body = jsonEncode({'username': username, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/register/username', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = User.create(result.data);
    }
    return authResult;
  }

  static Future<AuthResult> registerByPhoneCode(
      String phone, String code, String password) async {
    var body = jsonEncode({'phone': phone, 'code': code, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/register/phone-code', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = User.create(result.data);
    }
    return authResult;
  }

  static Future<AuthResult> loginByAccount(
      String account, String password) async {
    var body = jsonEncode({'account': account, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/login/account', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> loginByPhoneCode(
      String phone, String code) async {
    var body = jsonEncode({'phone': phone, 'code': code});
    final Result result = await post('/api/v2/login/phone-code', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> loginByLDAP(
      String username, String password) async {
    var body = jsonEncode({'username': username, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/login/ldap', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> loginByAD(
      String username, String password) async {
    var body = jsonEncode({'username': username, 'password': Util.encrypt(password)});
    final Result result = await post('/api/v2/login/ad', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> getCurrentUser() async {
    final Result result = await get('/api/v2/users/me');
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = User.create(result.data);
    }
    return authResult;
  }

  static Future<AuthResult> logout() async {
    final Result result = await get('/api/v2/logout?app_id=' + Authing.sAppId);
    currentUser = null;
    return AuthResult(result);
  }

  static Future<AuthResult> sendSms(String phone, [String? phoneCountryCode]) async {
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
    final Result result = await get('/api/v2/udfs/values?targetType=USER&targetId=' + userId);
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

  static Future<AuthResult> resetPasswordByPhoneCode(String phone, String code, String password) async {
    var body = jsonEncode({'phone': phone, 'code': code, 'newPassword': Util.encrypt(password)});
    final Result result = await post('/api/v2/password/reset/sms', body);
    return AuthResult(result);
  }

  static Future<AuthResult> resetPasswordByEmailCode(String email, String code, String password) async {
    var body = jsonEncode({'email': email, 'code': code, 'newPassword': Util.encrypt(password)});
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

  static Future<AuthResult> updatePassword(String newPassword, [String? oldPassword]) async {
    Map map = {};
    map.putIfAbsent('newPassword', () => Util.encrypt(newPassword));
    if (oldPassword != null) {
      map.putIfAbsent('oldPassword', () => Util.encrypt(oldPassword));
    }
    final Result result = await post('/api/v2/password/update', jsonEncode(map));
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> bindPhone(
      String phone, String code) async {
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
      [String? oldPhone, String? oldPhoneCode, String? phoneCountryCode, String? oldPhoneCountryCode]) async {
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
    final Result result = await post('/api/v2/users/phone/update', jsonEncode(map));
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> bindEmail(
      String email, String code) async {
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
    final Result result = await post('/api/v2/users/email/update', jsonEncode(map));
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = createUser(result);
    }
    return authResult;
  }

  static Future<AuthResult> link(String primaryUserToken, String secondaryUserToken) async {
    var body = jsonEncode({'primaryUserToken': primaryUserToken, 'secondaryUserToken': secondaryUserToken});
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

  static Future<Result> getSecurityLevel() async {
    return await get('/api/v2/users/me/security-level');
  }

  static Future<Map> listAuthorizedResources(String namespace, [String? resourceType]) async {
    Map map = {};
    map.putIfAbsent('namespace', () => namespace);
    if (resourceType != null) {
      map.putIfAbsent('resourceType', () => resourceType);
    }
    final Result result = await post('/api/v2/users/resource/authorized', jsonEncode(map));
    return result.data;
  }

  static Future<Result> listApplications([int? page = 1, int? limit = 10]) async {
    return await get('/api/v2/users/me/applications/allowed?page=' + page.toString() + "&limit=" + limit.toString());
  }

  static User createUser(Result result) {
    currentUser = User.create(result.data);
    return currentUser!;
  }

  static Future<Result> get(String endpoint) {
    return request("get", endpoint, null);
  }

  static Future<Result> post(String endpoint, [String? body]) {
    return request("post", endpoint, body);
  }

  static Future<Result> request(
      String method, String endpoint, [String? body]) async {
    var url = Uri.parse('https://' + Authing.sHost + endpoint);
    Map<String, String> headers = {
      "x-authing-userpool-id": Authing.sUserPoolId,
      "x-authing-app-id": Authing.sAppId,
      "x-authing-request-from": "SDK@Flutter@" + Authing.VERSION,
      "content-type": "application/json"
    };
    if (currentUser != null) {
      headers.putIfAbsent("Authorization", () => "Bearer " + currentUser!.token);
    }
    var response = method.toLowerCase() == "get" ? await http.get(url, headers: headers) : await http.post(url, headers: headers, body: body);
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
