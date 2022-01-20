import 'package:flutter_test/flutter_test.dart';

import 'package:authing_sdk/authing.dart';
import 'package:authing_sdk/client.dart';
import 'package:authing_sdk/result.dart';

// can run all case serially in one go

void main() {
  String pool = "60caaf41da89f1954875cee1";
  String appid = "60caaf41df670b771fd08937";
  Authing.init(pool, appid);

  test('register by email', () async {
    AuthResult result = await AuthClient.registerByEmail("1@1.com", "111111");
    expect(result.code, 200);
    expect(result.user.email, "1@1.com");

    AuthResult result2 = await AuthClient.loginByAccount("1@1.com", "111111");
    expect(result2.code, 200);
    expect(result2.user.email, "1@1.com");

    AuthResult result3 = await AuthClient.registerByEmail("1@1.com", "111111");
    expect(result3.code, 2026);

    AuthResult result4 = await AuthClient.registerByEmail("1", "111111");
    expect(result4.code, 2003);
  });

  test('register by username', () async {
    AuthResult result = await AuthClient.registerByUserName("test1024", "111111");
    expect(result.code, 200);
    expect(result.user.username, "test1024");

    AuthResult result2 = await AuthClient.loginByAccount("test1024", "111111");
    expect(result2.code, 200);
    expect(result2.user.username, "test1024");

    AuthResult result3 = await AuthClient.registerByUserName("test1024", "111111");
    expect(result3.code, 2026);
  });

  test('login by account', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user.username, "ci");

    AuthResult result2 = await AuthClient.loginByAccount("ci", "111111xx");
    expect(result2.code, 2333);
  });

  test('get current user', () async {
    await AuthClient.logout();

    AuthResult result0 = await AuthClient.getCurrentUser();
    expect(result0.code, 2020);

    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user.username, "ci");

    AuthResult result2 = await AuthClient.getCurrentUser();
    expect(result2.code, 200);
    expect(result2.user.username, "ci");
  });

  test('logout', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user.username, "ci");

    AuthResult result2 = await AuthClient.logout();
    expect(result2.code, 200);
    expect(AuthClient.currentUser, null);

    AuthResult result3 = await AuthClient.getCurrentUser();
    expect(result3.code, 2020);
  });

  test('getCustomData', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user.username, "ci");

    AuthResult result2 = await AuthClient.getCustomData(result.user.id);
    expect(result2.code, 200);
    expect(AuthClient.currentUser?.customData[0]["key"], "org");
    expect(AuthClient.currentUser?.customData[0]["value"], "unit_test");
  });

  test('setCustomData', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user.username, "ci");

    AuthResult result2 = await AuthClient.getCustomData(result.user.id);
    expect(result2.code, 200);
    expect(AuthClient.currentUser?.customData[0]["key"], "org");
    expect(AuthClient.currentUser?.customData[0]["value"], "unit_test");

    AuthClient.currentUser?.customData[0]["value"] = "hello";
    AuthResult result3 = await AuthClient.setCustomData(AuthClient.currentUser!.customData);
    expect(result3.code, 200);
    expect(AuthClient.currentUser?.customData[0]["value"], "hello");

    AuthClient.currentUser?.customData[0]["value"] = "unit_test";
    await AuthClient.setCustomData(AuthClient.currentUser!.customData);
  });

  test('updateProfile', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user.username, "ci");

    AuthResult result2 = await AuthClient.updateProfile({
      "username":"hey",
      "nickname":"musk"
    });
    expect(result2.code, 200);
    expect(result2.user.username, "hey");
    expect(result2.user.nickname, "musk");

    AuthResult result3 = await AuthClient.updateProfile({"username":"ci"});
    expect(result3.code, 200);
    expect(result3.user.username, "ci");
  });
}
