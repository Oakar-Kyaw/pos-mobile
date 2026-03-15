import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/user.dart';

class UserAsyncNotifier extends AsyncNotifier<User> {
  final DioService _dio = DioService();

  @override
  Future<User> build() async {
    return getUserById();
  }

  /// Fetch a single user
  Future<User> getUserById({int? userId}) async {
    final url = "v1/users${userId != null ? '/$userId' : ''}";
    final response = await _dio.get(url);
    final data = response.data as Map<String, dynamic>;

    if (data["success"] == true) {
      final items = data["data"];
      return User.fromJson(Map<String, dynamic>.from(items));
    }

    throw Exception("Failed to fetch user");
  }

  /// Create a new user
  Future<bool> postUser(Map<String, dynamic> json) async {
    final url = "v1/users";
    final response = await _dio.post(url, data: json);
    final data = response.data as Map<String, dynamic>;
    print("🤩 Created user data: $data");

    if (data["success"] == true) return true;

    throw Exception("Failed to create user");
  }

  /// Fetch paginated users
  Future<List<User>> getAllUser({
    required int page,
    required int limit,
    int? companyId,
    int? branchId,
  }) async {
    final response = await _dio.get(
      "v1/users",
      query: {"page": page, "limit": limit},
    );
    final data = response.data as Map<String, dynamic>;

    if (data["success"] == true) {
      return User.listFromJson(data["data"]);
    }

    throw Exception("Failed to fetch users");
  }

  /// Fetch users by companyId
  Future<List<User>> getUserByCompanyIdAndBranchId({
    required int companyId,
    int? branchId,
  }) async {
    final response = await _dio.get(
      "v1/users",
      query: {"companyId": companyId, "branchId": branchId},
    );
    final data = response.data as Map<String, dynamic>;

    if (data["success"] == true) {
      return User.listFromJson(data["data"]);
    }

    throw Exception("Failed to fetch users by company");
  }

  /// Search users
  Future<List<User>> searchUser({required String search}) async {
    final response = await _dio.get("v1/users", query: {"search": search});
    final data = response.data as Map<String, dynamic>;

    if (data["success"] == true) {
      return User.listFromJson(data["data"]);
    }

    throw Exception("Failed to search users");
  }
}

/// Riverpod provider for single user
final userProvider = AsyncNotifierProvider<UserAsyncNotifier, User>(
  UserAsyncNotifier.new,
);

/// Riverpod provider for searching users
final searchUserProvider = FutureProvider.family<List<User>?, String>((
  ref,
  search,
) async {
  final notifier = ref.read(userProvider.notifier);
  return notifier.searchUser(search: search);
});

final userByCompanyProvider = FutureProvider.family<List<User>, int>((
  ref,
  companyId,
) async {
  final userApi = ref.read(userProvider.notifier);
  final users = await userApi.getUserByCompanyIdAndBranchId(
    companyId: companyId,
  );
  return users;
});
