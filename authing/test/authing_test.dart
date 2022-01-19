import 'package:flutter_test/flutter_test.dart';

import 'package:authing_sdk/authing.dart';
import 'package:authing_sdk/client.dart';
import 'package:authing_sdk/result.dart';

void main() {
  String pool = "60caaf41da89f1954875cee1";
  String appid = "60caaf41df670b771fd08937";

  test('register by email', () async {
    Authing.init(pool, appid);
    AuthResult result = await AuthClient.registerByEmail("1@1.com", "111111");
    expect(result.code, 200);
    expect(result.user.email, "1@1.com");

    AuthResult result2 = await AuthClient.loginByAccount("1@1.com", "111111");
    expect(result2.code, 200);
    expect(result2.user.email, "1@1.com");
  });

  test('register by username', () async {
    Authing.init(pool, appid);
    AuthResult result = await AuthClient.registerByUserName("test1024", "111111");
    expect(result.code, 200);
    expect(result.user.username, "test1024");

    AuthResult result2 = await AuthClient.loginByAccount("test1024", "111111");
    expect(result2.code, 200);
    expect(result2.user.username, "test1024");
  });

  test('register by phone code', () async {
    Authing.init(pool, appid);

    // change to your testing phone number. fill code after receiving the SMS
    // NOTE: add country code prefix
    String phone = "+86xxx";
    AuthResult result = await AuthClient.registerByPhoneCode(phone, "9314", "111111");
    expect(result.code, 200);
    expect(result.user.phone, phone);

    AuthResult result2 = await AuthClient.loginByAccount(phone, "111111");
    expect(result2.code, 200);
    expect(result2.user.phone, phone);
  });

  test('login by account', () async {
    Authing.init(pool, appid);
    AuthResult result = await AuthClient.loginByAccount("test", "111111");
    expect(result.code, 200);
    expect(result.user.username, "test");

    AuthResult result2 = await AuthClient.loginByAccount("test", "111111xx");
    expect(result2.code, 2333);
  });

  test('login by phone code', () async {
    Authing.init(pool, appid);

    // change to your testing phone number. fill code after receiving the SMS
    // NOTE: add country code prefix
    String phone = "+86xxx";
    AuthResult result = await AuthClient.loginByPhoneCode(phone, "9130");
    expect(result.code, 200);
    expect(result.user.phone, phone);

    AuthResult result2 = await AuthClient.loginByPhoneCode(phone, "111111");
    expect(result2.code, 2001);
  });

  test('get current user', () async {
    Authing.init(pool, appid);

    AuthResult result0 = await AuthClient.getCurrentUser();
    expect(result0.code, 2020);

    AuthResult result = await AuthClient.loginByAccount("test", "111111");
    expect(result.code, 200);
    expect(result.user.username, "test");

    AuthResult result2 = await AuthClient.getCurrentUser();
    expect(result2.code, 200);
    expect(result2.user.username, "test");
  });

  test('logout', () async {
    Authing.init(pool, appid);

    AuthResult result = await AuthClient.loginByAccount("test", "111111");
    expect(result.code, 200);
    expect(result.user.username, "test");

    AuthResult result2 = await AuthClient.logout();
    expect(result2.code, 200);
    expect(AuthClient.currentUser, null);

    AuthResult result3 = await AuthClient.getCurrentUser();
    expect(result3.code, 2020);
  });

  test('send sms', () async {
    Authing.init(pool, appid);

    String phone = "+86xxx";
    AuthResult result = await AuthClient.sendSms(phone);
    expect(result.code, 200);
  });

  test('send email', () async {
    Authing.init(pool, appid);

    String email = "your_email";
    AuthResult result = await AuthClient.sendEmail(email, "RESET_PASSWORD");
    expect(result.code, 200);
    result = await AuthClient.sendEmail(email, "VERIFY_EMAIL");
    expect(result.code, 200);
    result = await AuthClient.sendEmail(email, "CHANGE_EMAIL");
    expect(result.code, 200);
    result = await AuthClient.sendEmail(email, "MFA_VERIFY");
    expect(result.code, 200);
  });
}
