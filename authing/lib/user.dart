class User {
  late String id;
  late String phone;
  late String email;
  late String token;
  String? mfaToken;
  String? firstTimeLoginToken;

  late String username;
  late String nickname;
  late String company;
  late String photo;
  late String browser;
  late String device;
  late String name;
  late String givenName;
  late String familyName;
  late String middleName;
  late String profile;
  late String preferredUsername;
  late String website;
  late String gender;
  late String birthdate;
  late String zoneinfo;
  late String locale;
  late String address;
  late String streetAddress;
  late String locality;
  late String region;
  late String postalCode;
  late String city;
  late String province;
  late String country;

  late List customData;

  static User create(Map map) {
    User user = User();
    user.id = map["id"].toString();
    user.phone = map["phone"].toString();
    user.email = map["email"].toString();
    user.token = map["token"].toString();
    if (map.containsKey("mfaToken")) {
      user.mfaToken = map["mfaToken"].toString();
    }

    user.username = map["username"].toString();
    user.nickname = map["nickname"].toString();
    user.company = map["company"].toString();
    user.photo = map["photo"].toString();
    user.browser = map["browser"].toString();
    user.device = map["device"].toString();
    user.name = map["name"].toString();
    user.givenName = map["givenName"].toString();
    user.familyName = map["familyName"].toString();
    user.middleName = map["middleName"].toString();
    user.profile = map["profile"].toString();
    user.preferredUsername = map["preferredUsername"].toString();
    user.website = map["website"].toString();
    user.gender = map["gender"].toString();
    user.birthdate = map["birthdate"].toString();
    user.zoneinfo = map["zoneinfo"].toString();
    user.locale = map["locale"].toString();
    user.address = map["address"].toString();
    user.streetAddress = map["streetAddress"].toString();
    user.locality = map["locality"].toString();
    user.region = map["region"].toString();
    user.postalCode = map["postalCode"].toString();
    user.city = map["city"].toString();
    user.province = map["province"].toString();
    user.token = map["token"].toString();
    user.country = map["country"].toString();
    return user;
  }

  setCustomData(List data) {
    customData = data;
  }
}
