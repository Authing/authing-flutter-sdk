<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# Getting started

## Add dependency

in your pubspec.yaml, add the following dependency:

```yaml
authing_sdk: ^1.0.0
```

## SDK initialization

Upon App start, call:

```dart
import 'package:authing_sdk/authing.dart';

Authing.init("user_pool_id", "app_id");
```

where *user_pool_id* is your Authing user pool id and *app_id* is your Authing app id

## On-premise deployment

for on-premise deployments, after calling init, call:

```dart
Authing.setOnPremiseInfo(String host, String publicKey)
```

where *host* is your own domain, e.g. mycompany.com and *publicKey* is your organization's public key.

Contact Authing sales if you have any questions.

<br>

# Authentication API

for all authentication APIs, you should import:

```dart
import 'package:authing_sdk/client.dart';
```

<br>

## Register by email

Register a new user by email. The email is case insensitive and must be unique within a given user pool. After registration, emailVerified is false.

```dart
AuthClient.registerByEmail(String email, String password);
```

**params**

* *email*

* *password* clear text password

**example**

```dart
AuthResult result = await AuthClient.registerByEmail("x@example.com", "strong");
User user = result.user;
```

**error**

* 2003 if email address is mal-formatted
* 2026 if email has been registered already

<br>

## Register by user name

Register a new user by user name. User name is case sensitive and must be unique within a given user pool.

```dart
AuthClient.registerByUserName(String username, String password);
```

**params**

* *username*

* *password* clear text password

**example**

```dart
AuthResult result = await AuthClient.registerByUserName("nextgeneration", "strong");
User user = result.user;
```

**error**

* 2026 if email has been registered already

<br>

## Register by phone code

Register a new user by phone number and a verification code. Phone number must be unique within a given user pool.

Must call [sendSms](#send-sms-code) method to get an SMS verification code before calling this method.

```dart
AuthClient.registerByPhoneCode(String phone, String code, String password);
```

**params**

* *phone* phone number

* *code* SMS code

* *password* clear text password

**example**

```dart
AuthResult result = await AuthClient.registerByPhoneCode("13012345678", "1121", "strong");
User user = result.user;
```

**error**

* 2001 if verification code is incorrect
* 2026 if phone number has been registered already

<br>

## Login by account and password

```dart
AuthClient.loginByAccount(String account, String password);
```

**params**

* *account* can be one of the following: phone number / email / user name

* *password* clear text password

**example**

```dart
AuthResult result = await AuthClient.loginByAccount("your account", "your password");
User user = result.user; // user info
```

**error**

* 2333 incorrect credential

<br>

## Login by phone code

login by phone number and a verification code. Must call [sendSms](#send-sms-code) method to get an SMS verification code before calling this method.

```dart
AuthClient.loginByPhoneCode(String account, String code);
```

**params**

* *account* can be one of the following: phone number / email / user name

* *code* SMS code

**example**

```dart
AuthResult result = await AuthClient.loginByPhoneCode("13012345678", "1234");
User user = result.user; // get user info
```

**error**

* 2001 if verification code is incorrect

<br>

## Get current user

Get current user information. Must log in first.

```dart
AuthClient.getCurrentUser();
```

**example**

```dart
AuthResult result = await AuthClient.getCurrentUser();
User user = result.user; // user info
```

**error**

* 2020 must login first

<br>

## Logout

Logout user.

```dart
AuthClient.logout();
```

**example**

```dart
AuthResult result = await AuthClient.logout();
var code = result.code;
```

**error**

* 1010001 if token is invalid or expired

<br>

## Send SMS code

Send an SMS verification code

```dart
AuthClient.sendSms(String phone, Sting? phoneCountryCode);
```

**params**

* *phone* phone number to receive the code

* *phoneCountryCode* phone country code starts with +. Optional

**example**

```dart
AuthResult result = await AuthClient.sendSms("13012345678", "+86");
var code = result.code;
```

**error**

* 500 phone number is mal-formatted

<br>

## Update password

Update user password. Must log in first. In case user didn't set a password (e.g. registered by phone code or social connections), the old password parameter should be omitted.

```dart
AuthClient.updatePassword(String newPassword, [String? oldPassword]);
```

**params**

* *newPassword* new password in clear text

* *oldPassword* old password in clear text. Optional

**example**

```dart
AuthResult result = await AuthClient.updatePassword("newPassword", "oldPassword");
var code = result.code;
```

**error**

* 2020 must login first
* 1320011 old password is incorrect

<br>