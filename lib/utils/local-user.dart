import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/features/company/data/model/company.dart';
import 'package:pos/features/company/presentation/provider/company.riverpod.dart';
import 'package:pos/features/profile/data/model/user.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/secure-storage.dart';

Future<void> addToUserLocalState(Ref ref) async {
  await _addToUserLocalState(ref);
}

Future<void> addToUserLocalStateWidget(WidgetRef ref) async {
  await _addToUserLocalState(ref);
}

Future<void> _addToUserLocalState(dynamic ref) async {
  final _secureStorage = SecureStorage();
  final userMap = await _secureStorage.getUser();
  if (userMap != null && userMap['company'] != null) {
    final user = User.fromJson(userMap);
    final company = Company.fromJson(
      Map<String, dynamic>.from(userMap['company']),
    );
    ref.read(companyStateProvider.notifier).setCompany(company);
    ref.read(userStateProvider.notifier).setUser(user);
  }
}
