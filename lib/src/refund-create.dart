import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/refund-form.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RefundCreatePage extends ConsumerWidget {
  const RefundCreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: RefundLocale.refundForm.getString(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? kPrimary.withOpacity(0.1)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const RefundForm(),
        ),
      ),
    );
  }
}
