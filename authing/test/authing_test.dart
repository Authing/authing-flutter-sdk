import 'package:flutter_test/flutter_test.dart';

import 'package:authing_sdk/authing.dart';
import 'package:authing_sdk/client.dart';
import 'package:authing_sdk/result.dart';

void main() {
  test('login by account', () async {
    Authing.init("60caaf41da89f1954875cee1", "60caaf41df670b771fd08937");
    AuthResult result = await AuthClient.loginByAccount("test", "111111");
    expect(result.code, 200);
    expect(result.user.username, "test");

    AuthResult result2 = await AuthClient.loginByAccount("test", "111111xx");
    expect(result2.code, 2333);
  });
}
