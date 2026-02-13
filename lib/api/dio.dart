import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pos/localization/error-local.dart';
import 'package:pos/localization/login-local.dart';
import 'package:pos/utils/secure-storage.dart';

class DioService {
  static final DioService _instance = DioService._internal();
  factory DioService() => _instance;

  late Dio _dio;

  DioService._internal() {
    final backendUrl = "${dotenv.env["BACKEND_URL"]}/api/";
    _dio = Dio(
      BaseOptions(
        baseUrl: backendUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final secureStorage = SecureStorage();
          final tokens = await secureStorage.getAcessAndRefreshToken();

          final accessToken = tokens?['accessToken'];

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          //print("access token $accessToken");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final errorMessage = _handleError(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: errorMessage,
              message: errorMessage,
            ),
          );
        },
      ),
    );
  }

  // ================= ERROR HANDLER =================

  _handleError(DioException e) {
    print("Exception is: ${e.response}");
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception("Connection timeout. Please try again.");

      case DioExceptionType.receiveTimeout:
        return Exception("Server is taking too long to respond.");

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String message = data is Map && data['message'] != null
            ? data['message']
            : "Bad Request";

        //print("status code is ${e.response?.data} 😍${e.response?.data}");
        if (statusCode == 400) {
          return message;
        } else if (statusCode == 401) {
          if (message == "Password was wrong.") {
            return LoginScreenLocale.passwordWrong;
          }
          return "Unauthorized. Please login again.";
        } else if (statusCode == 403) {
          return ErrorScreenLocale.unauthorized;
        } else if (statusCode == 404) {
          return LoginScreenLocale.emailNotFound;
        } else if (statusCode == 500) {
          return "Internal server error.";
        } else {
          return "Something went wrong.";
        }

      case DioExceptionType.unknown:
        return "No internet connection.";

      default:
        return "Unexpected error occurred.";
    }
  }

  // ================= HEADERS =================

  void setAuthorization(String token) {
    _dio.options.headers['Authorization'] = token;
  }

  void setContentType(String type) {
    _dio.options.headers['Content-Type'] = type;
  }

  // ================= REQUESTS =================

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return await _dio.get(path, queryParameters: query);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    print("path $path");
    return await _dio.post(path, data: data, queryParameters: query);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    return await _dio.patch(path, data: data, queryParameters: query);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path);
  }
}
