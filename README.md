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
authing_sdk_v3: ^1.0.1
```

## SDK initialization

Upon App start, call:

```dart
import 'package:authing_sdk_v3/authing.dart';

Authing.init(String userPoolId, String appId)
```