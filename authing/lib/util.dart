import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:authing_sdk/config.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

import 'authing.dart';

class Util {
  static String encrypt(String content) {
    String pk = "-----BEGIN PUBLIC KEY-----\n" +
        Authing.sPublicKey +
        "\n" +
        "-----END PUBLIC KEY-----";
    RSAPublicKey publicKey = RSAKeyParser().parse(pk) as RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    return encrypter.encrypt(content).base64;
  }

  static String getRandomString(int length) {
    String chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(_rnd.nextInt(chars.length))));
  }

  static String getLangHeader() {
    String language = ui.window.locale.languageCode;
    return ((language.isNotEmpty) && language.contains("zh"))
        ? "zh-CN"
        : "en-US";
  }

  static String generateCodeChallenge(String codeVerifier) {
    var bytes = latin1.encode(codeVerifier);
    var digest = sha256.convert(bytes);

    String base64Str = Base64Encoder.urlSafe().convert(digest.bytes);

    return base64Str.replaceAll("=", "");
  }

  static bool isIP(String? str, [/*<String | int>*/ version]) {
    RegExp _ipv4Maybe =
        RegExp(r'^(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)\.(\d?\d?\d)$');
    RegExp _ipv6 =
        RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$');

    version = version.toString();
    if (version == 'null') {
      return isIP(str, 4) || isIP(str, 6);
    } else if (version == '4') {
      if (!_ipv4Maybe.hasMatch(str!)) {
        return false;
      }
      var parts = str.split('.');
      parts.sort((a, b) => int.parse(a) - int.parse(b));
      return int.parse(parts[3]) <= 255;
    }
    return version == '6' && _ipv6.hasMatch(str!);
  }

  static String getHost(Config config) {
    if (Util.isIP(Authing.sHost)) {
      return Authing.sHost;
    } else {
      return config.identifier + ".authing.cn";
    }
  }
}
