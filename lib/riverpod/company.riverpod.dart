import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/models/company.dart';

class CompanyNotifier extends Notifier<Company?> {
  @override
  Company? build() {
    return null;
  }

  void setCompany(Company company) {
    state = company;
  }

  void clear() {
    state = null;
  }
}

final companyStateProvider = NotifierProvider<CompanyNotifier, Company?>(
  CompanyNotifier.new,
);
