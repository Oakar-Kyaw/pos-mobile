import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/utils/internet-status.proivder.dart';
import 'package:pos/localization/home-local.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class NoInternetBanner extends ConsumerWidget {
  final Widget child;
  const NoInternetBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<bool>>(internetServiceProvider, (prev, next) {
      final hasInternet = next.value ?? true;
      final messenger = scaffoldMessengerKey.currentState;
      if (messenger == null) return;

      messenger.hideCurrentSnackBar();
      if (hasInternet) return;

      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.fixed,
          duration: Duration(days: 1),
          content: _NoInternetText(),
        ),
      );
    });

    return child;
  }
}

class _NoInternetText extends StatelessWidget {
  const _NoInternetText();

  @override
  Widget build(BuildContext context) {
    // ဒီ context က Localizations ကို ကြည့်နေလို့ locale ပြောင်းရင် rebuild ဖြစ်မယ်
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_off, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(
          HomeScreenLocale.noInternet.getString(context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
