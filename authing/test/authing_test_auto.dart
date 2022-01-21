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

  test('updatePassword', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user.username, "ci");

    AuthResult result1 = await AuthClient.updatePassword("222222", "123456");
    expect(result1.code, 1320011);

    AuthResult result2 = await AuthClient.updatePassword("222222", "111111");
    expect(result2.code, 200);

    AuthResult result3 = await AuthClient.loginByAccount("ci", "222222");
    expect(result3.code, 200);

    AuthResult result4 = await AuthClient.updatePassword("111111", "222222");
    expect(result4.code, 200);
  });

  test('getSecurityLevel', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user.username, "ci");

    Result result1 = await AuthClient.getSecurityLevel();
    expect(result1.code, 200);
    expect(result1.data["score"], 75);
    expect(result1.data["passwordSecurityLevel"], 1);
  });

  test('listAuthorizedResources', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user.username, "ci");

    Map result1 = await AuthClient.listAuthorizedResources("default");
    expect(result1["totalCount"], 2);
    expect(result1["list"][0]["code"], "ci:*");
    expect(result1["list"][0]["type"], "DATA");
    expect(result1["list"][1]["code"], "super:*");
    expect(result1["list"][1]["type"], "API");

    result1 = await AuthClient.listAuthorizedResources("default", "DATA");
    expect(result1["totalCount"], 1);
    expect(result1["list"][0]["code"], "ci:*");
    expect(result1["list"][0]["type"], "DATA");

    AuthResult result2 = await AuthClient.loginByAccount("cinophone", "111111");
    expect(result2.code, 200);

    Map result3 = await AuthClient.listAuthorizedResources("default");
    expect(result3["totalCount"], 0);
  });

  test('listApplications', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user.username, "ci");

    Result result1 = await AuthClient.listApplications();
    expect(result1.code, 200);
    expect(result1.data["totalCount"], 5);
    expect(result1.data["list"][0]["id"], "61ae0c9807451d6f30226bd4");

    AuthResult result2 = await AuthClient.loginByAccount("cinophone", "111111");
    expect(result2.code, 200);

    Result result3 = await AuthClient.listApplications();
    expect(result3.data["totalCount"], 1);
  });
}
