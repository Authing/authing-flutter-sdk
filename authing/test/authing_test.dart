import 'package:flutter_test/flutter_test.dart';

import 'package:authing_sdk/authing.dart';
import 'package:authing_sdk/client.dart';
import 'package:authing_sdk/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {

  // on mac, when running test, it will crash without this line
  SharedPreferences.setMockInitialValues({});

  String pool = "60caaf41da89f1954875cee1";
  String appid = "60caaf41df670b771fd08937";
  Authing.init(pool, appid);

  test('register by phone code', () async {
    // change to your testing phone number. fill code after receiving the SMS
    // NOTE: add country code prefix
    String phone = "+86xxx";
    AuthResult result = await AuthClient.registerByPhoneCode(phone, "9314", "111111");
    expect(result.code, 200);
    expect(result.user?.phone, phone);
    expect(result.user?.token != null, true);

    AuthResult result2 = await AuthClient.loginByAccount(phone, "111111");
    expect(result2.code, 200);
    expect(result2.user?.phone, phone);
  });

  test('login by phone code', () async {
    // change to your testing phone number. fill code after receiving the SMS
    // NOTE: add country code prefix
    String phone = "+86xxx";
    AuthResult result = await AuthClient.loginByPhoneCode(phone, "9130");
    expect(result.code, 200);
    expect(result.user?.phone, phone);

    AuthResult result2 = await AuthClient.loginByPhoneCode(phone, "111111");
    expect(result2.code, 2001);
  });

  test('send sms', () async {
    String phone = "136";
    AuthResult result = await AuthClient.sendSms(phone, "+86");
    expect(result.code, 200);
  });

  test('send email', () async {
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

  test('resetPasswordByPhoneCode', () async {
    String phone = "136";
    AuthResult result = await AuthClient.resetPasswordByPhoneCode(phone, "2613", "111111");
    expect(result.code, 200);

    AuthResult result2 = await AuthClient.loginByAccount(phone, "111111");
    expect(result2.code, 200);
    expect(result2.user?.phone, phone);
  });

  test('resetPasswordByEmailCode', () async {
    String email = "x@gmail.com";
    AuthResult result = await AuthClient.resetPasswordByEmailCode(email, "6898", "111111");
    expect(result.code, 200);

    AuthResult result2 = await AuthClient.loginByAccount(email, "111111");
    expect(result2.code, 200);
    expect(result2.user?.email, email);
  });

  test('bindPhone', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    String phone = "136";
    AuthResult result2 = await AuthClient.bindPhone(phone, "6499");
    expect(result2.code, 200);

    AuthResult result3 = await AuthClient.loginByAccount(phone, "111111");
    expect(result3.code, 200);
    expect(result3.user?.phone, phone);
  });

  test('unbindPhone', () async {
    AuthResult result = await AuthClient.loginByAccount("cinophone", "111111");
    expect(result.code, 200);

    AuthResult result2 = await AuthClient.unbindPhone();
    expect(result2.code, 1320005);

    AuthResult result3 = await AuthClient.loginByAccount("ci", "111111");
    expect(result3.code, 200);

    AuthResult result4 = await AuthClient.unbindPhone();
    expect(result4.code, 200);
  });

  test('updatePhone', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);

    String phone = "13632530515";
    AuthResult result2 = await AuthClient.updatePhone(phone, "5564");
    expect(result2.code, 200);

    AuthResult result3 = await AuthClient.loginByAccount(phone, "111111");
    expect(result3.code, 200);
    expect(result3.user?.phone, phone);
  });

  test('bindEmail', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);
    expect(result.user?.username, "ci");

    String email = "maolongdong@gmail.com";
    AuthResult result2 = await AuthClient.bindEmail(email, "3687");
    expect(result2.code, 200);

    AuthResult result3 = await AuthClient.loginByAccount(email, "111111");
    expect(result3.code, 200);
    expect(result3.user?.email, email);
  });

  test('unbindEmail', () async {
    AuthResult result = await AuthClient.loginByAccount("cinophone", "111111");
    expect(result.code, 200);

    AuthResult result2 = await AuthClient.unbindEmail();
    expect(result2.code, 1320009);

    AuthResult result3 = await AuthClient.loginByAccount("ci", "111111");
    expect(result3.code, 200);

    AuthResult result4 = await AuthClient.unbindEmail();
    expect(result4.code, 200);
  });

  test('updateEmail', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);

    String email = "maolongdong@gmail.com";
    AuthResult result2 = await AuthClient.updateEmail(email, "9691");
    expect(result2.code, 200);

    AuthResult result3 = await AuthClient.loginByAccount(email, "111111");
    expect(result3.code, 200);
    expect(result3.user?.email, email);
  });

  test('loginByWechat', () async {
    AuthResult result = await AuthClient.loginByWechat("61d7bba378b4119bcb12590f", "x");
    expect(result.code, 200);
  });

  test('loginByAlipay', () async {
    AuthResult result = await AuthClient.loginByAlipay("6184f4de0b6ae7d51ec98d5f", "x");
    expect(result.code, 200);
  });

  test('loginByApple', () async {
    AuthResult result = await AuthClient.loginByApple("x");
    expect(result.code, 200);
  });

  test('mfaVerifyByPhone', () async {
    Authing.init(pool, "61c173ada0e3aec651b1a1d1");
    AuthResult result = await AuthClient.mfaVerifyByPhone("136", "1234");
    expect(result.code, 200);
  });

  test('mfaVerifyByEmail', () async {
    Authing.init(pool, "61c173ada0e3aec651b1a1d1");
    AuthResult result = await AuthClient.mfaVerifyByEmail("1@gmail.com", "1234");
    expect(result.code, 200);
  });

  test('mfaVerifyByTOTP', () async {
    Authing.init(pool, "61c173ada0e3aec651b1a1d1");
    AuthResult result = await AuthClient.mfaVerifyByTOTP("123456");
    expect(result.code, 200);
  });

  test('mfaVerifyByRecoveryCode', () async {
    Authing.init(pool, "61c173ada0e3aec651b1a1d1");
    AuthResult result = await AuthClient.mfaVerifyByRecoveryCode("123456");
    expect(result.code, 200);
  });

  test('authByCode', () async {
    AuthResult result = await AuthClient.authByCode("P6FENDfGSH72PxgJQk17FoGMWY3oL1G0D2PQ1AfyDeo",
        "fu6IivbcEb7DFCytjLmoAICRtFLbG9zkk5QdDbNd0gG",
        "https://guard.authing/redirect");
    expect(result.code, 200);
    expect(result.user?.accessToken != null, true);
  });

  test('login by scanning QR code', () async {
    AuthResult result = await AuthClient.loginByAccount("ci", "111111");
    expect(result.code, 200);

    String random = "xPkqaoEd0ljqUTqwzoitaEblTJFcbC";
    Result result2 = await AuthClient.markQRCodeScanned(random);
    expect(result2.code, 200);

    result2 = await AuthClient.loginByScannedTicket(random);
    expect(result2.code, 200);
  });
}
