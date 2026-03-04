import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/ui/inventory-form.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/inventory-configuration.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InventoryItemPage extends ConsumerWidget {
  final InventoryActionType type;

  const InventoryItemPage({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = InventoryActionConfig(type, context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: config.title,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // ── Description Banner ──────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(isDark ? 0.15 : 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: kPrimary.withOpacity(isDark ? 0.3 : 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(config.icon, color: kPrimary, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      config.description,
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: subColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const InventoryManagementForm(
                type: InventoryActionType.damaged,
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
