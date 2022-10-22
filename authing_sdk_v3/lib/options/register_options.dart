import 'dart:core';

class RegisterOptions {
  Map? profile;
  String? phonePassCodeForInformationCompletion;
  String? emailPassCodeForInformationCompletion;
  String? context;
  String? passwordEncryptType;

  Map setValues(Map body) {
    Map options = {};

    if (phonePassCodeForInformationCompletion != null) {
      options['phonePassCodeForInformationCompletion'] = phonePassCodeForInformationCompletion;
    }
    if (emailPassCodeForInformationCompletion != null) {
      options['emailPassCodeForInformationCompletion'] = emailPassCodeForInformationCompletion;
    }
    if (passwordEncryptType != null) {
      options['passwordEncryptType'] = passwordEncryptType;
    }
    if (context != null) {
      options['context'] = context;
    }
    if (options.isNotEmpty) {
      body['options'] = options;
    }
    if (profile != null) {
      body['profile'] = profile;
    }
    return body;
  }

}