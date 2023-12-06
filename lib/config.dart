class Config {
  late List<String> redirectUris;
  late String identifier;

  static Config create(Map map) {
    Config config = Config();

    if (map["redirectUris"] is List) {
      config.redirectUris = List<String>.from(map["redirectUris"]);
    }

    config.identifier = map["identifier"].toString();

    return config;
  }
}
