import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/customer/presentation/page/customer-list.dart';
import 'package:pos/localization/customer-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/inventory-configuration.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final editingCustomerIdProvider = StateProvider<int?>((ref) => null);

class CustomerPage extends ConsumerStatefulWidget {
  const CustomerPage({super.key});

  @override
  ConsumerState<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends ConsumerState<CustomerPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;

    final config = InventoryActionConfig('Customer', context);

    return Scaffold(
      backgroundColor: bgColor,

      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: CustomerLocale.customerManagementTitle.getString(context),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ==========================
            /// CREATE CUSTOMER BUTTON
            /// ==========================
            GradientSubmitButton(
              onPressed: () {
                context.pushNamed(AppRoute.customerCreate);
              },
              text: CustomerLocale.customerCreate.getString(context),
              width: 150,
            ),

            const SizedBox(height: 20),

            /// ==========================
            /// CUSTOMER LIST
            /// ==========================
            const Expanded(child: CustomerLists()),
          ],
        ),
      ),
    );
  }
}
