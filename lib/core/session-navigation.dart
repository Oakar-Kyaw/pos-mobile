// core/session.dart
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/localization/login-local.dart';
import 'package:pos/riverpod/company.riverpod.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/utils/go-router.dart';
import 'package:pos/utils/secure-storage.dart';

class Session {
  final Ref ref;
  final SecureStorage secureStorage;
  Session({required this.ref, required this.secureStorage});

  bool _isShowingDialog = false;

  Future<void> sessionExpired() async {
    if (_isShowingDialog) return;
    _isShowingDialog = true;

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _isShowingDialog = false;
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(LoginScreenLocale.sessionExpired.getString(context)),
        content: Text(
          LoginScreenLocale.sessionExpiredDescription.getString(context),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await secureStorage.deleteLoginData();
              await secureStorage.saveAcessAndRefreshToken(
                accessToken: '',
                refreshToken: '',
              );
              ref.read(checkLoginProvider.notifier).logout();
              ref.read(companyStateProvider.notifier).clear();
              if (ctx.mounted) ctx.go('/login');
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    _isShowingDialog = false;
  }
}
