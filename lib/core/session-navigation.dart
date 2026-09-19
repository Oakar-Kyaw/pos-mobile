import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/core/utils/confirm-dialog.dart';
import 'package:pos/features/company/presentation/provider/company.riverpod.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/localization/login-local.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/utils/go-router.dart';
import 'package:pos/utils/secure-storage.dart';

class Session {
  final Ref ref;
  final SecureStorage secureStorage;

  Session({required this.ref, required this.secureStorage});

  bool _isShowingDialog = false;
  bool _isShowingSubscriptionDialog = false;

  Future<void> sessionExpired() async {
    debugPrint("🚨🚨🚨 SESSION EXPIRED CALLED 🚨🚨🚨");
    debugPrint(StackTrace.current.toString());

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

              if (ctx.mounted) {
                ctx.go('/login');
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );

    _isShowingDialog = false;
  }

  Future<void> subscriptionExpired() async {
    if (_isShowingSubscriptionDialog) return;
    _isShowingSubscriptionDialog = true;

    final context = rootNavigatorKey.currentContext;

    if (context == null) {
      _isShowingSubscriptionDialog = false;
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: GeneralScreenLocale.subscriptionExpired.getString(context),
      content: GeneralScreenLocale.subscriptionExpiredDescription.getString(
        context,
      ),
      confirmLabel: GeneralScreenLocale.subscribe.getString(context),
      cancelLabel: "",
      // GeneralScreenLocale.later.getString(context),
    );

    if (confirmed == true && context.mounted) {
      context.go('/account-upgrade');
    }

    _isShowingSubscriptionDialog = false;
  }
}
