import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/localization/payroll-local.dart';
import 'package:pos/models/user.dart';
import 'package:pos/ui/attendance-list-by-userId.dart';
import 'package:pos/utils/user-search-field.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/utils/app-theme.dart';

class PayrollForm extends ConsumerStatefulWidget {
  final onUserChange;
  const PayrollForm({super.key, required this.onUserChange});

  @override
  ConsumerState<PayrollForm> createState() => _PayrollFormState();
}

class _PayrollFormState extends ConsumerState<PayrollForm> {
  final _formKey = GlobalKey<ShadFormState>();
  Timer? _debounce;
  User? selectedUser;
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final labelColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    //print("type is $");
    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          UserSearchField(
            onUserSelected: (user) => setState(() {
              selectedUser = user;
              widget.onUserChange(user);
            }),
            itemBuilder: (user) => User(
              id: user.id,
              email: user.email,
              role: user.role,
              employeeType: user.employeeType,
              gender: user.gender,
              holidays: user.holidays,
              createdAt: user.createdAt,
            ),
          ),
          const SizedBox(height: 5),
          selectedUser != null
              ? ListTile(
                  title: Text(selectedUser!.email),
                  subtitle: Text(
                    "${selectedUser?.firstName} ${selectedUser?.lastName}",
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
