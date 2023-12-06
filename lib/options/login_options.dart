class LoginOptions {
  String? scope;
  String? tenantId;
  Map? customData;
  bool? autoRegister;
  String? context;
  String? passwordEncryptType;
  String? clientIp;

  Map setValues(Map body) {
    Map options = {};

    if (scope != null) {
      options['scope'] =
          scope;
    } else {
      options['scope'] = 'openid profile username email phone offline_access roles external_id extended_fields tenant_id';
    }
    if (passwordEncryptType != null) {
      options['passwordEncryptType'] = passwordEncryptType;
    }
    if (tenantId != null) {
      options['tenantId'] = tenantId;
    }
    if (autoRegister != null) {
      options['autoRegister'] = autoRegister;
    }
    if (customData != null) {
      options['customData'] = customData;
    }
    if (context != null) {
      options['context'] = context;
    }
    if (options.isNotEmpty) {
      body['options'] = options;
    }
    return body;
  }
}