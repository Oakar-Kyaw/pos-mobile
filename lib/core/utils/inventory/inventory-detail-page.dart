import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/inventory-management-local.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InventoryDetailPage extends ConsumerStatefulWidget {
  final InventoryManagement inventory;

  const InventoryDetailPage({super.key, required this.inventory});

  @override
  ConsumerState<InventoryDetailPage> createState() =>
      _InventoryDetailPageState();
}

class _InventoryDetailPageState extends ConsumerState<InventoryDetailPage> {
  Color _accentColor(String type) {
    switch (type.toLowerCase()) {
      case 'expired':
        return Colors.orange.shade600;
      case 'damaged':
        return Colors.red.shade500;
      default:
        return kPrimary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'expired':
        return Icons.hourglass_empty_rounded;
      case 'damaged':
        return Icons.broken_image_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final inventory = widget.inventory;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    final user = ref.watch(userStateProvider);
    final canManage =
        user != null && (isAdmin(user.role) || isManager(user.role));

    final accent = _accentColor(inventory.type);
    final isConfirmed = inventory.confirmed;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: InventoryManagementLocale.inventoryDetail.getString(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _typeIcon(inventory.type),
                          color: accent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inventory.type.toUpperCase(),
                              style: TextStyle(
                                color: accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Information',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  //only show status when type is "REQUESTED"
                  if (inventory.type == "REQUESTED")
                    _InfoRow(
                      label: 'Status',
                      value: isConfirmed == true ? 'Confirmed' : 'Pending',
                      textColor: textColor,
                      subColor: subColor,
                      valueColor: isConfirmed == true
                          ? Colors.green
                          : Colors.orange,
                      valueWeight: FontWeight.w600,
                    ),
                  const SizedBox(height: 16),
                  ...List.generate(inventory.items.length, (index) {
                    final item = inventory.items[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.product.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${item.quantity} pcs',
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                            ),
                            const SizedBox(height: 14),
                            _PriceRow(
                              label: InventoryManagementLocale
                                  .inventorySellingPrice
                                  .getString(context),
                              value: '${item.price}',
                              textColor: textColor,
                              subColor: subColor,
                            ),
                            const SizedBox(height: 10),
                            _PriceRow(
                              label: InventoryManagementLocale
                                  .inventoryCostPrice
                                  .getString(context),
                              value: '${item.costPrice}',
                              textColor: textColor,
                              subColor: subColor,
                            ),
                            const SizedBox(height: 12),
                            _PriceRow(
                              label: InventoryManagementLocale
                                  .inventoryTotalAmount
                                  .getString(context),
                              value: '${item.totalAmount}',
                              textColor: textColor,
                              subColor: subColor,
                              isTotal: true,
                              accent: accent,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  if (inventory.reason != null &&
                      inventory.reason!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: InventoryManagementLocale.inventoryReason
                          .getString(context),
                      value: inventory.reason!,
                      textColor: textColor,
                      subColor: subColor,
                    ),

                    //note
                    if (inventory.note != null &&
                        inventory.note!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _InfoRow(
                        label: InventoryManagementLocale.inventoryReason
                            .getString(context),
                        value: inventory.note!,
                        textColor: textColor,
                        subColor: subColor,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color subColor;
  final Color? valueColor;
  final FontWeight? valueWeight;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.subColor,
    this.valueColor,
    this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: subColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? textColor,
              fontSize: 15,
              fontWeight: valueWeight ?? FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color subColor;
  final bool isTotal;
  final Color? accent;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.subColor,
    this.isTotal = false,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: subColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isTotal ? accent : textColor,
              fontSize: isTotal ? 15 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
