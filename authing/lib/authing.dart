library authing;

import 'client.dart';
import 'config.dart';
import 'result.dart';

class Authing {
  static const String VERSION = "1.1.10";

  static String sUserPoolId = "";
  static String sAppId = "";

  static String sHost = "core.authing.cn";
  static String sPublicKey =
      "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4xKeUgQ+Aoz7TLfAfs9+paePb5KIofVthEopwrXFkp8OCeocaTHt9ICjTT2QeJh6cZaDaArfZ873GPUn00eOIZ7Ae+TiA2BKHbCvloW3w5Lnqm70iSsUi5Fmu9/2+68GZRH9L7Mlh8cFksCicW2Y2W2uMGKl64GDcIq3au+aqJQIDAQAB";
  static String redirectUrl =
      "https://console.authing.cn/console/get-started/" + Authing.sAppId;
  static Config config = Config();

  static Future<void> init(String userPoolId, String appId) async {
    sUserPoolId = userPoolId;
    sAppId = appId;

    await requestPublicConfig();
  }

  static void setOnPremiseInfo(String host, String publicKey) {
    sHost = host;
    sPublicKey = publicKey;
  }

  static Future<void> requestPublicConfig() async {
    String url = "https://" +
        "console" +
        sHost +
        "/api/v2/applications/" +
        sAppId +
        "/public-config";

    final Result result = await AuthClient.request("get", url);
    config = Config.create(result.data);
  }
}
