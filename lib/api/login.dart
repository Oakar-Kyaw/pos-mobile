import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/core/provider.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/utils/local-user.dart';
import 'package:pos/utils/secure-storage.dart';

class LoginAsyncNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  late DioService _dio;
  final _secureStorage = SecureStorage();
  @override
  Future<Map<String, dynamic>?> build() async {
    _dio = ref.watch(dioServiceProvider);
    return null;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = "auth/login";
    final response = await _dio.post(
      url,
      data: {"email": email, "password": password},
    );
    final Map<String, dynamic> data = response.data;
    if (data["success"] == true) {
      final loginData = data["data"];
      final user = data["user"];
      final accessTokenData = data["access_token"];
      final refreshTokenData = data["refresh_token"];
      await _secureStorage.saveLoginData(loginData);
      await _secureStorage.saveUser(user);
      await _secureStorage.saveAcessAndRefreshToken(
        accessToken: accessTokenData,
        refreshToken: refreshTokenData,
      );
      await _secureStorage.saveLogin(true);
      await addToUserLocalState(ref);
      ref.read(checkLoginProvider.notifier).login();

      // final companyMap = user is Map ? user['company'] : null;
      // if (companyMap != null) {
      //   final company = Company.fromJson(
      //     Map<String, dynamic>.from(companyMap),
      //   );
      //   ref.read(companyStateProvider.notifier).setCompany(company);
      // }
      return {"success": true};
    }

    throw Exception(data["message"] ?? "Failed to login");
  }
}

final loginProvider = AsyncNotifierProvider(LoginAsyncNotifier.new);
