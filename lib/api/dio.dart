import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pos/core/session-navigation.dart';
import 'package:pos/localization/error-local.dart';
import 'package:pos/localization/login-local.dart';
import 'package:pos/utils/secure-storage.dart';
import 'package:pos/utils/time-util.dart';

class DioService {
  // =============================================================
  // DEPENDENCIES
  // =============================================================

  final Session session;
  final SecureStorage _secureStorage;

  // =============================================================
  // DIO
  // =============================================================

  late Dio _dio;

  // =============================================================
  // REFRESH LOCK
  //
  // If multiple API requests receive 401 at the same time,
  // only ONE refresh request will be sent.
  //
  // Other requests will wait for this Future.
  // =============================================================

  Completer<String?>? _refreshCompleter;

  // =============================================================
  // CONSTRUCTOR
  // =============================================================

  DioService({required this.session, required SecureStorage secureStorage})
    : _secureStorage = secureStorage {
    _initializeDio();
  }

  // =============================================================
  // INITIALIZE DIO
  // =============================================================

  void _initializeDio() {
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
        // =======================================================
        // ON REQUEST
        // =======================================================
        onRequest: (options, handler) async {
          try {
            final tokens = await _secureStorage.getAcessAndRefreshToken();

            final language = await _secureStorage.getLanguageSetting();

            final timezone = await TimezoneUtil.getTimezone();

            final accessToken = tokens?['accessToken'];

            // ---------------------------------------------------
            // ACCESS TOKEN
            // ---------------------------------------------------

            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }

            // ---------------------------------------------------
            // LANGUAGE
            // ---------------------------------------------------

            options.headers['Accept-Language'] = language;

            // ---------------------------------------------------
            // TIMEZONE
            // ---------------------------------------------------

            options.headers['x-timezone'] = timezone;

            return handler.next(options);
          } catch (error) {
            print("Request interceptor error: $error");

            return handler.next(options);
          }
        },

        // =======================================================
        // ON RESPONSE
        // =======================================================
        onResponse: (response, handler) {
          return handler.next(response);
        },

        // =======================================================
        // ON ERROR
        // =======================================================
        onError: (DioException e, handler) async {
          final statusCode = e.response?.statusCode;

          print(
            "Dio Error: "
            "$statusCode "
            "${e.requestOptions.path} "
            "${e.response}",
          );

          // =====================================================
          // 401 UNAUTHORIZED
          // =====================================================

          if (statusCode == 401) {
            print("Access token expired 🔐");

            // ---------------------------------------------------
            // IMPORTANT:
            //
            // If the refresh endpoint itself returns 401,
            // DO NOT try to refresh again.
            // ---------------------------------------------------

            if (_isRefreshRequest(e.requestOptions)) {
              print("Refresh endpoint returned 401.");

              await session.sessionExpired();

              return handler.reject(e);
            }

            try {
              // -------------------------------------------------
              // REFRESH ACCESS TOKEN
              // -------------------------------------------------

              final newAccessToken = await _refreshAccessToken();

              // -------------------------------------------------
              // REFRESH FAILED
              // -------------------------------------------------

              if (newAccessToken == null || newAccessToken.isEmpty) {
                print("Could not refresh access token.");

                return handler.reject(e);
              }

              // -------------------------------------------------
              // UPDATE ORIGINAL REQUEST
              // -------------------------------------------------

              e.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              print("Retrying original request 🔄");

              // -------------------------------------------------
              // RETRY ORIGINAL REQUEST
              // -------------------------------------------------

              final response = await _dio.fetch(e.requestOptions);

              return handler.resolve(response);
            } catch (error) {
              print("Refresh/retry error: $error");

              return handler.reject(e);
            }
          }

          // =====================================================
          // NORMAL ERROR
          // =====================================================

          final errorMessage = _handleError(e);

          print("API error: ${e.response} ");

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,

              response: e.response,

              type: e.type,

              error: errorMessage,

              message: errorMessage.toString(),
            ),
          );
        },
      ),
    );
  }

  // =============================================================
  // CHECK WHETHER REQUEST IS REFRESH REQUEST
  // =============================================================

  bool _isRefreshRequest(RequestOptions options) {
    return options.path.contains('/auth/refresh');
  }

  // =============================================================
  // REFRESH ACCESS TOKEN
  // =============================================================

  Future<String?> _refreshAccessToken() async {
    // ===========================================================
    // ANOTHER REQUEST IS ALREADY REFRESHING
    // ===========================================================

    if (_refreshCompleter != null) {
      print(
        "Refresh already running. "
        "Waiting for existing refresh...",
      );

      return await _refreshCompleter!.future;
    }

    // ===========================================================
    // CREATE REFRESH LOCK
    // ===========================================================

    _refreshCompleter = Completer<String?>();

    try {
      // =========================================================
      // GET STORED TOKENS
      // =========================================================

      final tokens = await _secureStorage.getAcessAndRefreshToken();

      final refreshToken = tokens?['refreshToken'];

      // =========================================================
      // REFRESH TOKEN DOES NOT EXIST
      // =========================================================

      if (refreshToken == null || refreshToken.isEmpty) {
        print("Refresh token does not exist.");

        await session.sessionExpired();

        _completeRefresh(null);

        return null;
      }

      print("Refreshing access token 🔄");

      // =========================================================
      // IMPORTANT
      //
      // Use a separate Dio instance.
      //
      // This prevents /auth/refresh from going through the
      // interceptor and causing an infinite refresh loop.
      // =========================================================

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,

          connectTimeout: const Duration(seconds: 15),

          receiveTimeout: const Duration(seconds: 15),

          headers: {
            'Content-Type': 'application/json',

            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      // =========================================================
      // CALL REFRESH API
      // =========================================================

      final response = await refreshDio.get('/auth/refresh');

      print(
        "Refresh response: "
        "${response.data}",
      );

      // =========================================================
      // RESPONSE DATA
      // =========================================================

      final data = response.data;

      if (data is! Map) {
        print("Invalid refresh response.");

        await session.sessionExpired();

        _completeRefresh(null);

        return null;
      }

      // =========================================================
      // GET NEW TOKENS
      //
      // Your backend returns:
      //
      // access_token
      // refresh_token
      // =========================================================

      final newAccessToken = data['access_token']?.toString();

      final newRefreshToken = data['refresh_token']?.toString();

      // =========================================================
      // NEW ACCESS TOKEN MISSING
      // =========================================================

      if (newAccessToken == null || newAccessToken.isEmpty) {
        print("New access token was not returned.");

        await session.sessionExpired();

        _completeRefresh(null);

        return null;
      }

      // =========================================================
      // SAVE NEW TOKENS FIRST
      // =========================================================

      await _secureStorage.saveAcessAndRefreshToken(
        accessToken: newAccessToken,

        // If backend doesn't rotate the refresh token,
        // keep the old refresh token.
        refreshToken: newRefreshToken ?? refreshToken,
      );

      print("Access token refreshed successfully ✅");

      // =========================================================
      // COMPLETE WAITING REQUESTS
      // =========================================================

      _completeRefresh(newAccessToken);

      return newAccessToken;
    } catch (e) {
      // =========================================================
      // REFRESH FAILED
      // =========================================================

      print("Refresh token request failed: $e");

      // ---------------------------------------------------------
      // Session expired
      // ---------------------------------------------------------

      try {
        await session.sessionExpired();
      } catch (sessionError) {
        print(
          "Session expired error: "
          "$sessionError",
        );
      }

      // ---------------------------------------------------------
      // Wake up requests waiting for refresh
      // ---------------------------------------------------------

      _completeRefresh(null);

      return null;
    } finally {
      // =========================================================
      // RELEASE REFRESH LOCK
      // =========================================================

      _refreshCompleter = null;
    }
  }

  // =============================================================
  // COMPLETE REFRESH
  // =============================================================

  void _completeRefresh(String? accessToken) {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete(accessToken);
    }
  }

  // =============================================================
  // ERROR HANDLER
  // =============================================================

  dynamic _handleError(DioException e) {
    print("Exception is: $e");

    switch (e.type) {
      // =========================================================
      // CONNECTION TIMEOUT
      // =========================================================

      case DioExceptionType.connectionTimeout:
        return Exception("Connection timeout. Please try again.");

      // =========================================================
      // RECEIVE TIMEOUT
      // =========================================================

      case DioExceptionType.receiveTimeout:
        return Exception("Server is taking too long to respond.");

      // =========================================================
      // BAD RESPONSE
      // =========================================================

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;

        final data = e.response?.data;

        debugPrint("🤬 dioexception ${data}");

        String message = data is Map && data['message'] != null
            ? data['message'].toString()
            : "Bad Request";

        // if message exist
        if (message.isNotEmpty) {
          return message;
        }
        // -------------------------------------------------------
        // 400
        // -------------------------------------------------------

        if (statusCode == 400) {
          return message;
        }

        // -------------------------------------------------------
        // 401
        // -------------------------------------------------------

        if (statusCode == 401) {
          if (message == "Password was wrong.") {
            return LoginScreenLocale.passwordWrong;
          }

          return "Unauthorized. Please login again.";
        }

        // -------------------------------------------------------
        // 403
        // -------------------------------------------------------

        if (statusCode == 403) {
          return ErrorScreenLocale.unauthorized;
        }

        // -------------------------------------------------------
        // 404
        // -------------------------------------------------------

        if (statusCode == 404) {
          return LoginScreenLocale.emailNotFound;
        }

        // -------------------------------------------------------
        // 409
        // -------------------------------------------------------

        if (statusCode == 409) {
          return "Data already Exists";
        }

        // -------------------------------------------------------
        // 500
        // -------------------------------------------------------

        if (statusCode == 500) {
          return "Internal server error.";
        }

        return "Something went wrong.";

      // =========================================================
      // UNKNOWN / NETWORK ERROR
      // =========================================================

      case DioExceptionType.unknown:
        return "Server Error";

      // =========================================================
      // OTHER
      // =========================================================

      default:
        return "Unexpected error occurred.";
    }
  }

  // =============================================================
  // HEADERS
  // =============================================================

  void setAuthorization(String token) {
    _dio.options.headers['Authorization'] = token;
  }

  void setContentType(String type) {
    _dio.options.headers['Content-Type'] = type;
  }

  // =============================================================
  // GET
  // =============================================================

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return await _dio.get(path, queryParameters: query);
  }

  // =============================================================
  // POST
  // =============================================================

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    print("POST path: $path");

    return await _dio.post(path, data: data, queryParameters: query);
  }

  // =============================================================
  // PATCH
  // =============================================================

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
  }) async {
    return await _dio.patch(path, data: data, queryParameters: query);
  }

  // =============================================================
  // DELETE
  // =============================================================

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }
}
