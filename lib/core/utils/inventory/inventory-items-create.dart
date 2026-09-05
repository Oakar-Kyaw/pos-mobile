import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/inventory/inventory-form.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/inventory-configuration.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InventoryItemPage extends ConsumerWidget {
  final String type;

  const InventoryItemPage({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = InventoryActionConfig(type, context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    //print("type of item 🤬 is $type");
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: InventoryManagementForm(inventoryType: type),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
