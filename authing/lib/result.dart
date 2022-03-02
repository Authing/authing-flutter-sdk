import 'package:authing_sdk/oidc/auth_request.dart';

import 'user.dart';

class Result {
  late int code;
  late String message = "";
  late Map data;
}

class AuthResult {
  late int code;
  late String message;
  User? user;
  AuthRequest? authData;

  AuthResult(Result result, {AuthRequest? authRequest}) {
    code = result.code;
    message = result.message;
    authData = authRequest;
  }
}
