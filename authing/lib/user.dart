class User {
  late String id;
  late String username;
  late String phone;
  late String email;

  static User create(Map map) {
    User user = User();
    user.id = map["id"].toString();
    user.username = map["username"].toString();
    user.email = map["email"].toString();
    user.phone = map["phone"].toString();
    return user;
  }
}