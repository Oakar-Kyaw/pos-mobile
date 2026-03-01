import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final storage = new FlutterSecureStorage();

  Future<void> saveStaySigned(bool staySigned) async {
    // Convert map to JSON string
    String jsonString = jsonEncode(staySigned);
    //print("save login data: $jsonString");
    await storage.write(key: "isStaySigned", value: jsonString);
  }

  Future<bool> getStaySigned() async {
    // Convert map to JSON string
    String? jsonString = await storage.read(key: "isStaySigned");
    // print("getLogin data is: $jsonString");
    if (jsonString != null) {
      final isStaySigned = jsonDecode(jsonString);
      return isStaySigned;
    }
    return false;
  }

  Future<void> saveLogin(bool isLogin) async {
    // Convert map to JSON string
    String jsonString = jsonEncode(isLogin);
    //print("save login data: $jsonString");
    await storage.write(key: "isLogin", value: jsonString);
  }

  Future<bool> getLogin() async {
    // Convert map to JSON string
    String? jsonString = await storage.read(key: "isLogin");
    // print("getLogin data is: $jsonString");
    if (jsonString != null) {
      final isStaySigned = jsonDecode(jsonString);
      return isStaySigned;
    }
    return false;
  }

  ///save dark and light theme
  Future<void> saveTheme(bool isDarkTheme) async {
    // Convert map to JSON string
    String jsonString = jsonEncode(isDarkTheme);
    //print("save login data: $jsonString");
    await storage.write(key: "isDarkTheme", value: jsonString);
  }

  Future<bool> getTheme() async {
    // Convert map to JSON string
    String? jsonString = await storage.read(key: "isDarkTheme");
    // print("getLogin data is: $jsonString");
    if (jsonString != null) {
      final isDarkTheme = jsonDecode(jsonString);
      return isDarkTheme;
    }
    return false;
  }

  Future<void> saveLanguageSetting(String languageCode) async {
    // Convert map to JSON string
    String jsonString = jsonEncode(languageCode);
    //print("save login data: $jsonString");
    await storage.write(key: "isLanguageSetting", value: jsonString);
  }

  Future<String> getLanguageSetting() async {
    // Convert map to JSON string
    String? jsonString = await storage.read(key: "isLanguageSetting");
    // print("getLogin data is: $jsonString");
    if (jsonString != null) {
      final isLanguageSetting = jsonDecode(jsonString);
      return isLanguageSetting;
    }
    return "en"; // Default language if not set
  }

  Future<void> saveLoginData(data) async {
    // Convert map to JSON string
    String jsonString = jsonEncode(data);
    //print("save login data: $jsonString");
    await storage.write(key: "user", value: jsonString);
  }

  getLoginData() async {
    String? jsonString = await storage.read(key: "user");
    // print("getLogin data is: $jsonString");
    if (jsonString != null) {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      // return User.fromJson(map);
    }
    return null;
  }

  Future<void> saveAcessAndRefreshToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Convert map to JSON string
    String jsonString = jsonEncode({
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    });
    //print("save login data: $jsonString");
    await storage.write(key: "arToken", value: jsonString);
  }

  Future<Map<String, dynamic>?> getAcessAndRefreshToken() async {
    // Convert map to JSON string
    String? jsonString = await storage.read(key: "arToken");
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  Future readUserFullData() async {
    String? jsonString = await storage.read(key: "userFullData");
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  Future<void> saveCurrency({required int id, required String code}) async {
    // Convert map to JSON string
    String jsonString = jsonEncode({"id": id, "code": code});
    //print("save login data: $jsonString");
    await storage.write(key: "currency", value: jsonString);
  }

  Future<Map<String, dynamic>> getCurrency() async {
    // Convert map to JSON string
    String? jsonString = await storage.read(key: "currency");
    // print("getLogin data is: $jsonString");
    if (jsonString != null) {
      final currency = jsonDecode(jsonString);
      return currency;
    }
    return {};
  }

  Future<void> saveCartTotalNumber({required int numb}) async {
    // Convert map to JSON string
    String jsonString = jsonEncode(numb);
    print("numberis : $numb, $jsonString");
    //print("save login data: $jsonString");
    await storage.write(key: "cartNotiNumber", value: jsonString);
  }

  Future<int> getCartTotalNumber() async {
    // Convert map to JSON string
    String? jsonString = await storage.read(key: "cartNotiNumber");
    // print("getLogin data is: $jsonString");
    if (jsonString != null) {
      final numb = jsonDecode(jsonString);
      return numb;
    }
    return 0;
  }

  Future<void> deleteLoginData() async {
    await storage.delete(key: "userFullData");
    await storage.delete(key: "user");
    await storage.write(key: "isLogin", value: jsonEncode(false));
    await storage.write(key: "isStaySigned", value: jsonEncode(false));
  }
}
