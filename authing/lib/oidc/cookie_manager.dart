import 'dart:io';

class CookieManager {
  static final CookieManager _cookieManager = CookieManager._internal();
  factory CookieManager() => _cookieManager;
  CookieManager._internal();

  static final Map<String, Cookie> cookies = {};

  addCookies(HttpClientResponse response) {
    List<String>? cookies = response.headers["set-cookie"];
    print(cookies);
    if (cookies?.isEmpty == false) {
      cookies?.forEach((element) {
        List<String> data = element.split(";");
        String head = data[0];
        List<String> parts = head.split("=");
        if (parts.length > 1) {
          Cookie cookie = Cookie(parts[0].trim(), parts[1].trim());
          // CookieManager.
          CookieManager().addCookie(cookie);
        }
      });
    }
  }

  addCookie(Cookie cookie) {
    cookies[cookie.name] = cookie;
  }

  String getCookie() {
    String cookieStr = "";
    cookies.forEach((key, value) {
      print("--key, value--${key} ${value}");
      Cookie cookie = cookies[key] as Cookie;
      cookieStr += cookie.name + "=" + cookie.value + ";";
    });
    return cookieStr;
  }
}

class Cookie {
  String name;
  String value;

  Cookie(this.name, this.value);
}
