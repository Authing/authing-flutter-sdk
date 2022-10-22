import 'package:authing_sdk_v3/oidc/auth_request.dart';
import 'user.dart';

class Result {
  late int statusCode;
  int? apiCode;
  late String message = "";
  late Map data;
}

class AuthResult {
  late int statusCode;
  int? apiCode;
  late String message;
  late Map data;
  User? user;

  AuthResult(Result result) {
    statusCode = result.statusCode;
    apiCode = result.apiCode;
    message = result.message;
    data = result.data;
  }
}
