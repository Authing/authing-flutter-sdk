import 'authing.dart';
import 'util.dart';
import 'user.dart';
import 'result.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthClient {
  static Future<AuthResult> loginByAccount(
      String account, String password) async {
    String encryptedPassword = Util.encrypt(password);
    var body = jsonEncode({'account': account, 'password': encryptedPassword});
    final Result result = await post('/api/v2/login/account', body);
    AuthResult authResult = AuthResult(result);
    if (result.code == 200) {
      authResult.user = User.create(result.data);
      print(authResult.user.id);
    }
    return authResult;
  }

  static Future<Result> post(
      String endpoint, String body) async {
    var url = Uri.parse('https://' + Authing.sHost + endpoint);
    var response = await http.post(url,
        headers: {
          "x-authing-userpool-id": Authing.sUserPoolId,
          "x-authing-app-id": Authing.sAppId,
          "x-authing-request-from": "SDK@Flutter@" + Authing.VERSION,
          "content-type": "application/json"
        },
        body: body);
    Result result = Result();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map parsed = jsonDecode(response.body);
      if (parsed.containsKey("code")) {
        result.code = parsed["code"] as int;
      }
      if (parsed.containsKey("message")) {
        result.message = parsed["message"] as String;
      }
      if (parsed.containsKey("data")) {
        result.data = parsed["data"];
      }
    } else {
      result.code = response.statusCode;
      result.message = "network error";
    }
    return result;
  }
}
