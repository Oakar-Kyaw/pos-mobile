import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/supplier/presentation/page/supplier-list.dart';
import 'package:pos/localization/supplier-local.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SupplierPage extends ConsumerStatefulWidget {
  const SupplierPage({super.key});

  @override
  ConsumerState<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends ConsumerState<SupplierPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("SupplierPage disposed 🤩");

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;

    final user = ref.watch(userStateProvider);

    return Scaffold(
      backgroundColor: bgColor,

      // ==========================================
      // APP BAR
      // ==========================================
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(LucideIcons.arrowLeft),
        ),

        title: SupplierLocale.supplierManagementTitle.getString(context),
      ),

      // ==========================================
      // BODY
      // ==========================================
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==========================================
            // CREATE SUPPLIER BUTTON
            // ==========================================
            GradientSubmitButton(
              onPressed: () {
                context.pushNamed(AppRoute.supplierCreate);
              },

              text: SupplierLocale.supplierCreate.getString(context),

              width: 100,
            ),

            const SizedBox(height: 20),

            // ==========================================
            // SUPPLIER LIST
            // ==========================================
            Expanded(child: SupplierItemLists()),
          ],
        ),
      ),
    );
  }
}
