library authing_sdk_v3;

import 'client.dart';
import 'config.dart';
import 'result.dart';

class Authing {
  static const String VERSION = "1.1.10";

  static String sUserPoolId = "";
  static String sAppId = "";

  static String sHost = "core.authing.cn";
  static String sRASPublicKey =
      "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4xKeUgQ+Aoz7TLfAfs9+paePb5KIofVthEopwrXFkp8OCeocaTHt9ICjTT2QeJh6cZaDaArfZ873GPUn00eOIZ7Ae+TiA2BKHbCvloW3w5Lnqm70iSsUi5Fmu9/2+68GZRH9L7Mlh8cFksCicW2Y2W2uMGKl64GDcIq3au+aqJQIDAQAB";
  static String sSM2PublicKey = "042bc07187cc3bdcfe63b37902eead6dc400734d386e8e2be05d26159bce3259ae602c608052204079e5f49c12ef3296df8ceeff6314b45e2cf110dd58e96a47e4";
  static String redirectUrl =
      "https://console.authing.cn/console/get-started/" + Authing.sAppId;
  static Config config = Config();

  static Future<void> init(String userPoolId, String appId) async {
    sUserPoolId = userPoolId;
    sAppId = appId;

    await requestPublicConfig();
  }

  static void setOnPremiseInfo(String host, {String? rasPublicKey, String? sm2PublicKey}) {
    sHost = host;
    if (rasPublicKey != null) {
      sRASPublicKey = rasPublicKey;
    }
    if (sm2PublicKey != null) {
      sSM2PublicKey = sm2PublicKey;
    }
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
