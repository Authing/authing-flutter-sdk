import 'dart:convert';

import 'package:authing_sdk_v3/oidc/auth_request.dart';
import 'package:authing_sdk_v3/oidc/oidc_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'options/register_options.dart';
import 'options/login_options.dart';
import 'authing.dart';
import 'result.dart';
import 'user.dart';
import 'util.dart';

class AuthClient {
  static const String keyToken = "authing_access_token";
  static User? currentUser;

  /// register a new user by email address and a password.
  static Future<AuthResult> registerByEmail(String email, String password, [RegisterOptions? options]) async {

    var body = {
      'connection': 'PASSWORD',
      'passwordPayload': {'email': email, 'password': Util.encrypt(password, encryptType: options?.passwordEncryptType)},
    };

    var jsonBody = jsonEncode(body);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(body));
    }
    final Result result = await post('/api/v3/signup', jsonBody);
    // AuthResult authResult = AuthResult(result);
    // authResult.user = await createUser(result);
    return AuthResult(result);
  }

  /// register a new user by email address and a passcode.
  static Future<AuthResult> registerByEmailCode(String email, String passCode, [RegisterOptions? options]) async {

    var body = {
      'connection': 'PASSCODE',
      'passCodePayload': {'email': email, 'passCode': passCode},
    };
    var jsonBody = jsonEncode(body);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(body));
    }
    final Result result = await post('/api/v3/signup', jsonBody);
    // AuthResult authResult = AuthResult(result);
    // authResult.user = await createUser(result);
    return AuthResult(result);
  }

  /// register a new user by phone number and an SMS verification code.
  static Future<AuthResult> registerByPhoneCode(
      String phone, String passCode, [String? phoneCountryCode, RegisterOptions? options]) async {

    Map map = {};
    map.putIfAbsent('phone', () => phone);
    map.putIfAbsent('passCode', () => passCode);
    if (phoneCountryCode != null) {
      map.putIfAbsent('phoneCountryCode', () => phoneCountryCode);
    }
    var body = {
      'connection': 'PASSCODE',
      'passCodePayload': map,
    };

    var jsonBody = jsonEncode(body);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(body));
    }
    final Result result = await post('/api/v3/signup', jsonBody);
    // AuthResult authResult = AuthResult(result);
    // authResult.user = await createUser(result);
    return AuthResult(result);
  }

  /// register a new user by username and a password.
  static Future<AuthResult> registerByUsername(String username, String password, [RegisterOptions? options]) async {

    var body = {
      'connection': 'PASSWORD',
      'passwordPayload': {'username': username, 'password': Util.encrypt(password, encryptType: options?.passwordEncryptType)},
    };
    var jsonBody = jsonEncode(body);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(body));
    }
    final Result result = await post('/api/v3/signup', jsonBody);
    // AuthResult authResult = AuthResult(result);
    // authResult.user = await createUser(result);
    return AuthResult(result);
  }

  /// login by email and password.
  static Future<AuthResult> loginByEmail(String email, String password, [LoginOptions? options]) async {

    var body = {
      'connection': 'PASSWORD',
      'passwordPayload': {'email': email, 'password': Util.encrypt(password, encryptType: options?.passwordEncryptType)},
    };
    var jsonBody = jsonEncode(body);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(body));
    }
    final Result result = await post('/api/v3/signin', jsonBody);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// login by email address and a passcode.
  static Future<AuthResult> loginByEmailCode(String email, String passCode, [LoginOptions? options]) async {

    var body = {
      'connection': 'PASSCODE',
      'passCodePayload': {'email': email, 'passCode': passCode},
    };
    var jsonBody = jsonEncode(body);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(body));
    }
    final Result result = await post('/api/v3/signin', jsonBody);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// login by phone number and an SMS verification code.
  static Future<AuthResult> loginByPhoneCode(
      String phone, String passCode, [String? phoneCountryCode, LoginOptions? options]) async {

    Map map = {};
    map.putIfAbsent('phone', () => phone);
    map.putIfAbsent('passCode', () => passCode);
    if (phoneCountryCode != null) {
      map.putIfAbsent('phoneCountryCode', () => phoneCountryCode);
    }
    var body = {
      'connection': 'PASSCODE',
      'passCodePayload': map,
    };
    var jsonBody = jsonEncode(body);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(body));
    }
    final Result result = await post('/api/v3/signin', jsonBody);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// login by username and a password.
  static Future<AuthResult> loginByUsername(String username, String password, [LoginOptions? options]) async {

    var body = {
      'connection': 'PASSWORD',
      'passwordPayload': {'username': username, 'password': Util.encrypt(password, encryptType: options?.passwordEncryptType)},
    };
    var jsonBody = jsonEncode(body);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(body));
    }
    final Result result = await post('/api/v3/signin', jsonBody);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// login by account and password.
  static Future<AuthResult> loginByAccount(String account, String password, [LoginOptions? options]) async {

    var body = {
      'connection': 'PASSWORD',
      'passwordPayload': {'account': account, 'password': Util.encrypt(password, encryptType: options?.passwordEncryptType)},
    };
    var jsonBody = jsonEncode(body);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(body));
    }
    final Result result = await post('/api/v3/signin', jsonBody);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// login by ThirdPart.
  static Future<AuthResult> loginByThirdPart(String code, String connection, String extIdpConnidentifier, [LoginOptions? options]) async {

    Map map = {};
    map.putIfAbsent('connection', () => connection);
    map.putIfAbsent('extIdpConnidentifier', () => extIdpConnidentifier);

    if (connection == 'apple') {
      map.putIfAbsent('applePayload', () => {'code': code});
    } else if (connection == 'wechat') {
      map.putIfAbsent('wechatPayload', () => {'code': code});
    } else if (connection == 'wechatwork') {
      map.putIfAbsent('wechatworkPayload', () => {'code': code});
    } else if (connection == 'wechatwork_agency') {
      map.putIfAbsent('wechatworkAgencyPayload', () => {'code': code});
    } else if (connection == 'lark_internal') {
      map.putIfAbsent('larkInternalPayload', () => {'code': code});
    } else if (connection == 'lark_public') {
      map.putIfAbsent('larkPublicPayload', () => {'code': code});
    } else if (connection == 'google') {
      map.putIfAbsent('googlePayload', () => {'code': code});
    } else if (connection == 'alipay') {
      map.putIfAbsent('alipayPayload', () => {'code': code});
    }
    var jsonBody = jsonEncode(map);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(map));
    }
    final Result result = await post('/api/v3/signin-by-mobile', jsonBody);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// login by YiDun.
  static Future<AuthResult> loginByOneAuth(String token, String accessToken, String extIdpConnidentifier, [LoginOptions? options]) async {

    Map map = {};
    map.putIfAbsent('connection', () => 'yidun');
    map.putIfAbsent('extIdpConnidentifier', () => extIdpConnidentifier);
    map.putIfAbsent('yidunPayload', () => {'token': token, 'accessToken': accessToken});

    var jsonBody = jsonEncode(map);
    if (options != null) {
      jsonBody = jsonEncode(options.setValues(map));
    }
    final Result result = await post('/api/v3/signin-by-mobile', jsonBody);
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);
    return authResult;
  }

  /// get current logged in user's profile.
  static Future<AuthResult> getCurrentUser([bool? customData, bool? identities]) async {
    bool customDataBool = customData == null ? false : true;
    bool identitiesBool = identities == null ? false : true;
    final Result result = await get('api/v3/get-profile?withCustomData=' + customDataBool.toString() + '?withIdentities=' + identitiesBool.toString());
    AuthResult authResult = AuthResult(result);
    authResult.user = await createUser(result);

    return authResult;
  }

  /// send an SMS code.
  static Future<AuthResult> sendSms(String phone, String channel,
      [String? phoneCountryCode]) async {
    Map map = {};
    map.putIfAbsent('phoneNumber', () => phone);
    map.putIfAbsent('channel', () => channel);
    if (phoneCountryCode != null) {
      map.putIfAbsent('phoneCountryCode', () => phoneCountryCode);
    }
    final Result result = await post('/api/v3/send-sms', jsonEncode(map));
    return AuthResult(result);
  }

  /// send an email.
  static Future<AuthResult> sendEmail(String email, String channel) async {
    Map map = {};
    map.putIfAbsent('email', () => email);
    map.putIfAbsent('channel', () => channel);
    final Result result = await post('/api/v3/send-email', jsonEncode(map));
    return AuthResult(result);
  }

  /// Scan QRCode
  static Future<AuthResult> markQRCodeScanned(String qrcodeId) async {
    Map map = {};
    map.putIfAbsent('qrcodeId', () => qrcodeId);
    map.putIfAbsent('action', () => 'SCAN');
    final Result result = await post('/api/v3/change-qrcode-status', jsonEncode(map));
    return AuthResult(result);
  }

  /// Cancel Scan QRCode
  static Future<AuthResult> cancelByScannedTicket(String qrcodeId) async {
    Map map = {};
    map.putIfAbsent('qrcodeId', () => qrcodeId);
    map.putIfAbsent('action', () => 'CANCEL');
    final Result result = await post('/api/v3/change-qrcode-status', jsonEncode(map));
    return AuthResult(result);
  }

  /// Login by QRCode
  static Future<AuthResult> loginByScannedTicket(String ticket) async {
    Map map = {};
    map.putIfAbsent('ticket', () => ticket);
    final Result result = await post('/api/v3/exchange-tokenset-with-qrcode-ticket', jsonEncode(map));
    return AuthResult(result);
  }

  /// set user's custom data.
  static Future<AuthResult> updateProfile(Map object) async {
    final Result result = await post('/api/v3/update-profile', jsonEncode(object));
    return AuthResult(result);
  }

  /// bind phone to current user.
  static Future<AuthResult> bindPhone(String phoneNumber, String passCode, [String? phoneCountryCode]) async {
    Map map = {};
    map.putIfAbsent('phoneNumber', () => phoneNumber);
    map.putIfAbsent('passCode', () => passCode);
    if (phoneCountryCode != null) {
      map.putIfAbsent('phoneCountryCode', () => phoneCountryCode);
    }
    final Result result = await post('/api/v3/bind-phone', jsonEncode(map));
    return AuthResult(result);
  }

  /// unbind current user's phone number.
  static Future<AuthResult> unbindPhone() async {
    final Result result = await post('/api/v3/unbind-phone');
    AuthResult authResult = AuthResult(result);
    return authResult;
  }

  /// 2230 same phone number
  /// 1320004 phone already bind
  static Future<AuthResult> updatePhone(String newPhoneNumber, String newPhonePassCode,
      [String? oldPhoneNumber,
        String? oldPhonePassCode,
        String? newPhoneCountryCode,
        String? oldPhoneCountryCode]) async {
    Map map = {};
    map.putIfAbsent('newPhoneNumber', () => newPhoneNumber);
    map.putIfAbsent('newPhonePassCode', () => newPhonePassCode);
    if (oldPhoneNumber != null && oldPhonePassCode != null) {
      map.putIfAbsent('oldPhoneNumber', () => oldPhoneNumber);
      map.putIfAbsent('oldPhonePassCode', () => oldPhonePassCode);
    }
    if (newPhoneCountryCode != null) {
      map.putIfAbsent('newPhoneCountryCode', () => newPhoneCountryCode);
    }
    if (oldPhoneCountryCode != null) {
      map.putIfAbsent('oldPhoneCountryCode', () => oldPhoneCountryCode);
    }
    var body = {
      'verifyMethod': 'PHONE_PASSCODE',
      'phonePassCodePayload': map
    };
    final Result tokenResult =
    await post('/api/v3/verify-update-phone-request', jsonEncode(body));
    if (tokenResult.statusCode == 200) {
      final Result result =
      await post('/api/v3/update-phone', jsonEncode(tokenResult.data['updatePhoneToken']));
      AuthResult authResult = AuthResult(result);
      return authResult;
    } else {
      return AuthResult(tokenResult);
    }
  }

  /// bind email to current user.
  static Future<AuthResult> bindEmail(String email, String passCode) async {
    Map map = {};
    map.putIfAbsent('email', () => email);
    map.putIfAbsent('passCode', () => passCode);

    final Result result = await post('/api/v3/bind-email', jsonEncode(map));
    return AuthResult(result);
  }

  /// unbind email to current user.
  static Future<AuthResult> unbindEmail() async {
    final Result result = await post('/api/v3/unbind-email');
    return AuthResult(result);
  }

  /// update current user's email address.
  static Future<AuthResult> updateEmail(String newEmail, String newEmailPassCode,
      [String? oldEmail, String? oldEmailPassCode]) async {
    Map map = {};
    map.putIfAbsent('newEmail', () => newEmail);
    map.putIfAbsent('newEmailPassCode', () => newEmailPassCode);
    if (oldEmail != null && oldEmailPassCode != null) {
      map.putIfAbsent('oldEmail', () => oldEmail);
      map.putIfAbsent('oldEmailCode', () => oldEmailPassCode);
    }

    var body = {
      'verifyMethod': 'EMAIL_PASSCODE',
      'emailPassCodePayload': map
    };
    final Result tokenResult =
    await post('/api/v3/verify-update-email-request', jsonEncode(body));
    if (tokenResult.statusCode == 200) {
      final Result result =
      await post('/api/v3/update-email', jsonEncode(tokenResult.data['updateEmailToken']));
      AuthResult authResult = AuthResult(result);
      return authResult;
    } else {
      return AuthResult(tokenResult);
    }
  }

  /// update current user's password.
  static Future<AuthResult> updatePassword(String newPassword,
      [String? oldPassword, String? passwordEncryptType]) async {
    Map map = {};
    map.putIfAbsent('newPassword', () => Util.encrypt(newPassword, encryptType: passwordEncryptType));
    if (oldPassword != null) {
      map.putIfAbsent('oldPassword', () => Util.encrypt(oldPassword, encryptType: passwordEncryptType));
    }
    if (passwordEncryptType != null) {
      map.putIfAbsent('passwordEncryptType', () => passwordEncryptType);
    }
    final Result result =
    await post('/api/v3/update-password', jsonEncode(map));
    AuthResult authResult = AuthResult(result);
    return authResult;
  }

  /// reset password by phone number and an SMS code.
  static Future<AuthResult> resetPasswordByPhone(
      String phoneNumber, String passCode, String password, [String? phoneCountryCode, String? passwordEncryptType]) async {
    Map map = {};
    map.putIfAbsent('phoneNumber', () => phoneNumber);
    map.putIfAbsent('passCode', () => passCode);
    if (phoneCountryCode != null) {
      map.putIfAbsent('phoneCountryCode', () => phoneCountryCode);
    }
    var body = {
      'verifyMethod': 'PHONE_PASSCODE',
      'phonePassCodePayload': map
    };
    final Result tokenResult =
    await post('/api/v3/verify-reset-password-request', jsonEncode(body));
    if (tokenResult.statusCode == 200) {
      var resultBody = {
        'passwordResetToken': tokenResult.data['passwordResetToken'],
        'password': Util.encrypt(password, encryptType: passwordEncryptType)
      };
      final Result result =
      await post('/api/v3/reset-password',
          jsonEncode(resultBody));
      AuthResult authResult = AuthResult(result);
      return authResult;
    } else {
      return AuthResult(tokenResult);
    }
  }

  /// reset password by email and an email code.
  static Future<AuthResult> resetPasswordByEmailCode(
      String email, String passCode, String password, [String? passwordEncryptType]) async {
    Map map = {};
    map.putIfAbsent('email', () => email);
    map.putIfAbsent('passCode', () => passCode);
    var body = {
      'verifyMethod': 'EMAIL_PASSCODE',
      'emailPassCodePayload': map
    };
    final Result tokenResult =
    await post('/api/v3/verify-reset-password-request', jsonEncode(body));
    if (tokenResult.statusCode == 200) {
      var resultBody = {
        'passwordResetToken': tokenResult.data['passwordResetToken'],
        'password': Util.encrypt(password, encryptType: passwordEncryptType)
      };
      final Result result =
      await post('/api/v3/reset-password',
          jsonEncode(resultBody));
      AuthResult authResult = AuthResult(result);
      return authResult;
    } else {
      return AuthResult(tokenResult);
    }
  }

  /// delete account by phone number and an SMS code.
  static Future<AuthResult> deleteAccountByPhone(
      String phoneNumber, String passCode, [String? phoneCountryCode]) async {
    Map map = {};
    map.putIfAbsent('phoneNumber', () => phoneNumber);
    map.putIfAbsent('passCode', () => passCode);
    if (phoneCountryCode != null) {
      map.putIfAbsent('phoneCountryCode', () => phoneCountryCode);
    }
    var body = {
      'verifyMethod': 'PHONE_PASSCODE',
      'phonePassCodePayload': map
    };
    final Result tokenResult =
    await post('/api/v3/verify-delete-account-request', jsonEncode(body));
    if (tokenResult.statusCode == 200) {
      var resultBody = {
        'deleteAccountToken': tokenResult.data['deleteAccountToken'],
      };
      final Result result =
      await post('/api/v3/delete-account',
          jsonEncode(resultBody));
      AuthResult authResult = AuthResult(result);
      return authResult;
    } else {
      return AuthResult(tokenResult);
    }
  }

  /// reset password by email.
  static Future<AuthResult> deleteAccountByEmail(
      String email, String passCode) async {
    Map map = {};
    map.putIfAbsent('email', () => email);
    map.putIfAbsent('passCode', () => passCode);

    var body = {
      'verifyMethod': 'EMAIL_PASSCODE',
      'emailPassCodePayload': map
    };
    final Result tokenResult =
    await post('/api/v3/verify-delete-account-request', jsonEncode(body));
    if (tokenResult.statusCode == 200) {
      var resultBody = {
        'deleteAccountToken': tokenResult.data['deleteAccountToken'],
      };
      final Result result =
      await post('/api/v3/delete-account',
          jsonEncode(resultBody));
      AuthResult authResult = AuthResult(result);
      return authResult;
    } else {
      return AuthResult(tokenResult);
    }
  }

  /// delete account by password.
  static Future<AuthResult> deleteAccountByPassword(
      String password, [String? passwordEncryptType]) async {
    Map map = {};
    map.putIfAbsent('password', () => Util.encrypt(password, encryptType: passwordEncryptType));
    if (passwordEncryptType != null) {
      map.putIfAbsent('passwordEncryptType', () => passwordEncryptType);
    }
    var body = {
      'verifyMethod': 'PASSWORD',
      'passwordPayload': map
    };
    final Result tokenResult =
    await post('/api/v3/verify-delete-account-request', jsonEncode(body));
    if (tokenResult.statusCode == 200) {
      var resultBody = {
        'deleteAccountToken': tokenResult.data['deleteAccountToken'],
      };
      final Result result =
      await post('/api/v3/delete-account',
          jsonEncode(resultBody));
      AuthResult authResult = AuthResult(result);
      return authResult;
    } else {
      return AuthResult(tokenResult);
    }
  }

  /// logout.
  static Future<AuthResult> logout() async {
    Map map = {};
    map.putIfAbsent('client_id', () => Authing.sAppId);
    map.putIfAbsent('token', () => currentUser?.accessToken);
    final Result result = await post('/oidc/token/revocation', jsonEncode(map));
    currentUser = null;
    return AuthResult(result);
  }

  /// get login history.
  static Future<AuthResult> getLoginHistory(int page, int limit, [bool? success, String? start, String? end]) async {
    String successStr = success == null ? '' : '&success=' + success.toString();
    String startStr = start == null ? '' : "&start=" + start;
    String endStr = end == null ? '' : "&end=" + end;

    final Result result = await get('/api/v3/get-my-login-history?appId=' + Authing.sAppId + '&page=' + page.toString() + '&limit=' + limit.toString() + successStr + startStr + endStr);
    AuthResult authResult = AuthResult(result);
    return authResult;
  }

  /// get logged Apps
  static Future<Result> getLoggedApps() async {
    return await get('/api/v3/get-my-logged-in-apps');
  }

  /// get accessible Apps
  static Future<Result> getAccessibleApps() async {
    return await get('/api/v3/get-my-accessible-apps');
  }

  /// get tenant List
  static Future<Result> getTenantList() async {
    return await get('/api/v3/get-my-tenant-list');
  }

  /// list current user's roles
  static Future<Result> getRoleList([String? namespace]) async {
    final Result result = await get('/api/v3/get-my-role-list' +
        (namespace == null ? "" : "?namespace=" + namespace));
    return result;
  }

  /// get group List
  static Future<Result> getGroupList() async {
    return await get('/api/v3/get-my-group-list');
  }

  /// get department List
  static Future<AuthResult> getDepartmentList(int page, int limit, [bool? withCustomData, String? sortBy, String? orderBy]) async {
    String withCustomDataStr = withCustomData == null ? 'false' : withCustomData.toString();
    String sortByStr = sortBy ?? 'JoinDepartmentAt';
    String orderByStr = orderBy ?? 'Desc';

    final Result result = await get('/api/v3/get-my-department-list?page=' + page.toString() + '&limit=' + limit.toString() + '&withCustomData=' + withCustomDataStr + '&sortBy=' + sortByStr + '&orderBy=' + orderByStr);
    AuthResult authResult = AuthResult(result);
    return authResult;
  }

  /// get authorized resources
  static Future<Result> getAuthorizedResources([String? namespace, String? resourceType]) async {
    final Result result = await get('/api/v3/get-my-authorized-resources' +
        (namespace == null ? "" : "?namespace=" + namespace) + (resourceType == null ? "" : "?resourceType=" + resourceType));
    return result;
  }

  /// mfa bind Email
  static Future<AuthResult> mfaBindEmail(String email, String passCode) async {

    var body = {
      'factorType': 'EMAIL',
      'profile': {'email': email},
    };
    var jsonBody = jsonEncode(body);
    final Result tokenResult = await post('/api/v3/send-enroll-factor-request', jsonBody);
    if (tokenResult.statusCode == 200) {
      var resultBody = {
        'factorType': 'EMAIL',
        'enrollmentToken': tokenResult.data['enrollmentToken'],
        'enrollmentData': {'passCode': passCode}
      };
      final Result result =
      await post('/api/v3/enroll-factor',
          jsonEncode(resultBody));
      AuthResult authResult = AuthResult(result);
      return authResult;
    } else {
      return AuthResult(tokenResult);
    }
  }

  /// mfa bind phone
  static Future<AuthResult> mfaBindPhone(String phoneNumber, String passCode, [String? phoneCountryCode]) async {
    Map map = {};
    map.putIfAbsent('phoneNumber', () => phoneNumber);
    if (phoneCountryCode != null) {
      map.putIfAbsent('phoneCountryCode', () => phoneCountryCode);
    }
    var body = {
      'factorType': 'SMS',
      'profile': map,
    };
    var jsonBody = jsonEncode(body);
    final Result tokenResult = await post('/api/v3/send-enroll-factor-request', jsonBody);
    if (tokenResult.statusCode == 200) {
      var resultBody = {
        'factorType': 'SMS',
        'enrollmentToken': tokenResult.data['enrollmentToken'],
        'enrollmentData': {'passCode': passCode}
      };
      final Result result =
      await post('/api/v3/enroll-factor',
          jsonEncode(resultBody));
      AuthResult authResult = AuthResult(result);
      return authResult;
    } else {
      return AuthResult(tokenResult);
    }
  }

  /// mfa bind OTP
  static Future<AuthResult> mfaBindOTP(String passCode) async {
    var body = {
      'factorType': 'OTP',
    };
    var jsonBody = jsonEncode(body);
    final Result tokenResult = await post('/api/v3/send-enroll-factor-request', jsonBody);
    if (tokenResult.statusCode == 200) {
      var resultBody = {
        'factorType': 'OTP',
        'enrollmentToken': tokenResult.data['enrollmentToken'],
        'enrollmentData': {'passCode': passCode}
      };
      final Result result =
      await post('/api/v3/enroll-factor',
          jsonEncode(resultBody));
      AuthResult authResult = AuthResult(result);
      return authResult;
    } else {
      return AuthResult(tokenResult);
    }
  }

  /// mfa Unbind Factor
  static Future<Result> mfaUnbindFactor(String factorId) async {
    return await get('/api/v3/reset-factor' + factorId);
  }

  /// mfa Get Enrolled Factors List
  static Future<Result> mfaGetEnrolledFactorsList() async {
    return await get('/api/v3/list-enrolled-factors');
  }

  /// mfa Get Enrolled Bind Factor
  static Future<Result> mfaGetEnrolledBindFactor(String factorId) async {
    return await get('/api/v3/get-factors?factorId=' + factorId);
  }

  /// mfa Get Factors List To Enroll
  static Future<Result> mfaGetFactorsListToEnroll() async {
    return await get('/api/v3/list-factors-to-enroll');
  }

  /// get Security Info
  static Future<Result> getSecurityInfo() async {
    return await get('/api/v3/get-security-info');
  }

  /// get system config
  static Future<Result> getSystemConfig() async {
    return await get('/api/v3/system');
  }


  static Future<User?> createUser(Result result) async {
    if (result.statusCode == 200) {
      currentUser = User.create(result.data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyToken, currentUser!.token);
    } else if (result.statusCode == 1636) {
      currentUser = User();
      currentUser!.mfaToken = result.data["mfaToken"];
    } else if (result.statusCode == 1639) {
      currentUser = User();
      currentUser!.firstTimeLoginToken = result.data["token"];
    }
    return currentUser;
  }

  static Future<Result> get(String endpoint) {
    String url = 'https://' + Authing.sHost + endpoint;
    return request("get", url, null);
  }

  static Future<Result> post(String endpoint, [String? body]) {
    String url = 'https://' + Authing.sHost + endpoint;
    return request("post", url, body);
  }

  static Future<Result> delete(String endpoint, [String? body]) {
    String url = 'https://' + Authing.sHost + endpoint;
    return request("delete", url, body);
  }

  static Future<Result> request(String method, String uri,
      [String? body]) async {
    var url = Uri.parse(uri);
    Map<String, String> headers = {
      "x-authing-userpool-id": Authing.sUserPoolId,
      "x-authing-app-id": Authing.sAppId,
      "x-authing-request-from": "sdk-flutter",
      "x-authing-sdk-version": Authing.VERSION,
      "content-type": "application/json",
      "x-authing-lang": Util.getLangHeader()
    };
    if (currentUser != null) {
      if (currentUser!.mfaToken != null) {
        headers.putIfAbsent(
            "Authorization", () => "Bearer " + currentUser!.mfaToken!);
      } else {
        headers.putIfAbsent(
            "Authorization", () => "Bearer " + currentUser!.accessToken);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(keyToken);
      if (token != null && token != "null") {
        headers.putIfAbsent("Authorization", () => "Bearer " + token);
      }
    }

    method = method.toLowerCase();
    http.Response? response;
    if (method == 'get') {
      response = await http.get(url, headers: headers);
    } else if (method == 'post') {
      response = await http.post(url, headers: headers, body: body);
    } else if (method == 'delete') {
      response = await http.delete(url, headers: headers, body: body);
    }
    return parseResponse(response);
  }

  static Result parseResponse(response) {
    Result result = Result();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map parsed = jsonDecode(response.body);
      if (parsed.containsKey("statusCode")) {
        result.statusCode = parsed["statusCode"] as int;
      } else {
        result.statusCode = 200;
      }
      if (parsed.containsKey("apiCode")) {
        result.apiCode = parsed["apiCode"] as int;
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
      result.statusCode = response.statusCode;
      result.message = "network error";
    }
    return result;
  }
}
