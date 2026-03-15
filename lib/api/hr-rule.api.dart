import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/dio.dart';
import 'package:pos/models/hr-rule.dart';

class HrRuleAsyncNotifier extends AsyncNotifier<List<HrRule>> {
  final DioService _dio = DioService();

  @override
  Future<List<HrRule>> build() async {
    return await getHrRules();
  }

  /// -------- GET ALL HR RULES --------
  Future<List<HrRule>> getHrRules() async {
    final url = "v1/hr-rules";

    final response = await _dio.get(url);

    final data = response.data as Map<String, dynamic>;

    if (data["success"] == true) {
      final items = data["data"] as List;
      return HrRule.listFromJson(items);
    }

    throw Exception("Failed to fetch HR rules");
  }

  /// -------- GET HR RULE BY ID --------
  Future<HrRule> getHrRuleById(int id) async {
    final url = "v1/hr-rules/$id";

    final response = await _dio.get(url);
    final data = response.data as Map<String, dynamic>;

    if (data["success"] == true) {
      return HrRule.fromJson(Map<String, dynamic>.from(data["data"]));
    }

    throw Exception("Failed to fetch HR rule");
  }

  /// -------- CREATE HR RULE --------
  Future<Map<String, dynamic>> createHrRule(Map<String, dynamic> body) async {
    final url = "v1/hr-rules";

    final response = await _dio.post(url, data: body);

    final data = response.data;

    if (data["success"] == true) {
      await refresh();
      return {"success": true};
    }

    throw Exception("Failed to create HR rule");
  }

  /// -------- UPDATE HR RULE --------
  Future<void> updateHrRule({
    required int id,
    String? name,
    String? description,
    String? ruleType,
    double? amount,
  }) async {
    final url = "v1/hr-rules/$id";

    final response = await _dio.patch(
      url,
      data: {
        "name": name,
        "description": description,
        "ruleType": ruleType,
        "amount": amount,
      },
    );

    final data = response.data;

    if (data["success"] != true) {
      throw Exception("Failed to update HR rule");
    }

    await refresh();
  }

  /// -------- DELETE HR RULE --------
  Future<void> deleteHrRule(int id) async {
    final url = "v1/hr-rules/$id";

    final response = await _dio.delete(url);

    final data = response.data;

    if (data["success"] != true) {
      throw Exception("Failed to delete HR rule");
    }

    await refresh();
  }

  /// -------- SEARCH --------
  Future<void> searchHrRule(String search) async {
    state = const AsyncLoading();

    try {
      final result = await getHrRules();
      state = AsyncData(result);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  /// -------- REFRESH --------
  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final result = await getHrRules();
      state = AsyncData(result);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

final hrRuleProvider = AsyncNotifierProvider<HrRuleAsyncNotifier, List<HrRule>>(
  HrRuleAsyncNotifier.new,
);
