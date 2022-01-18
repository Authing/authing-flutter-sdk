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

## login by account and password

```dart
AuthResult result = await AuthClient.loginByAccount("your account", "your password");
User user = result.user; // get user info
```

> Note: account can be one of username, phone number or email