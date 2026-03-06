import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/user.dart';

class UserAsyncNotifier extends AsyncNotifier<User> {
  final DioService _dio = DioService();

  @override
  Future<User> build() async {
    return await getUserById();
  }

  /// Fetch a single user
  Future<User> getUserById({int? userId}) async {
    final url = "v1/users${userId != null ? '/$userId' : ''}";
    final response = await _dio.get(url);
    final Map<String, dynamic> data = response.data;

    if (data["success"] == true) {
      final items = data["data"];
      User user = User.fromJson(Map<String, dynamic>.from(items));
      return user;
    }

    throw Exception("Failed to fetch user");
  }

  /// Create a new user
  Future<bool> postUser(Map<String, dynamic> json) async {
    final url = "v1/users";
    final response = await _dio.post(url, data: json);
    final Map<String, dynamic> data = response.data;
    print("🤩 Created user data: $data");

    if (data["success"] == true) {
      return true;
    }

    throw Exception("Failed to create user");
  }

  Future<List<User>> getAllUser({required int page, required int limit}) async {
    final url = "v1/users";
    print("API CALL 🚀 page=$page");
    final response = await _dio.get(url, query: {"page": page, "limit": limit});
    final data = response.data;
    //  print("data is 🥸 $data");
    if (data["success"] == true) {
      return User.listFromJson(data["data"]);
    }

    throw Exception("Failed to create user");
  }
}

/// Riverpod provider
final userProvider = AsyncNotifierProvider<UserAsyncNotifier, User>(
  UserAsyncNotifier.new,
);
