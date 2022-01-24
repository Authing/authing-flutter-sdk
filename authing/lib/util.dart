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
}
