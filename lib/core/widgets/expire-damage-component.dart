import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/localization/inventory-management-local.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/left-bar-accent.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:pos/utils/voucher-header.dart';

class ExpireDamageCard extends ConsumerWidget {
  const ExpireDamageCard({
    super.key,
    required this.pagingController,
    required this.inventory,
    required this.textColor,
    required this.subColor,
    this.onEdit,
    this.onDelete,
    this.onDetail,
  });
  final InventoryManagement inventory;
  final PagingController pagingController;
  final Color textColor;
  final Color subColor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDetail;

  Color get _accentColor {
    switch (inventory.type.toLowerCase()) {
      case 'expire':
        return Colors.orange.shade600;
      case 'damage':
        return Colors.red.shade500;
      default:
        return kPrimary;
    }
  }

  IconData get _typeIcon {
    switch (inventory.type.toLowerCase()) {
      case 'expire':
        return Icons.hourglass_empty_rounded;
      case 'damage':
        return Icons.broken_image_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  void _onConfirm(int index, BuildContext context, WidgetRef ref) async {
    try {
      final success = await ref
          .read(productProvider.notifier)
          .confirmInventoryRecordItem(index: index);
      if (success) {
        pagingController.refresh();
        ShowToast(
          context,
          description: Text(
            InventoryManagementLocale.inventoryPurchaseConfirmSuccess.getString(
              context,
            ),
            style: TextStyle(
              fontSize: FontSizeConfig.title(context),
              color: kGreen,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error is $e");
      ShowToast(
        context,
        isError: true,
        description: Text(
          InventoryManagementLocale.inventoryPurchaseConfirmError.getString(
            context,
          ),
          style: TextStyle(
            fontSize: FontSizeConfig.title(context),
            color: kRed,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _accentColor;
    final isConfirmed = inventory.confirmed;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          LeftAccentBar(accent: accent),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inventory.type == "REQUESTED"
                    ? VoucherHeader(
                        typeIcon: _typeIcon,
                        inventory: inventory,
                        accent: accent,
                        isConfirmed: isConfirmed,
                        textColor: textColor,
                        subColor: subColor,
                        onDelete: onDelete,
                        onDetail: onDetail,
                      )
                    : VoucherHeader(
                        typeIcon: _typeIcon,
                        inventory: inventory,
                        accent: accent,
                        textColor: textColor,
                        subColor: subColor,
                        onDelete: onDelete,
                        onDetail: onDetail,
                      ),

                const SizedBox(height: 12),

                Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 168, 167, 167),
                        Color.fromARGB(255, 85, 84, 84),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ...inventory.items
                    .take(2)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.product.name.toString(),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: FontSizeConfig.body(context),
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.price}',
                              style: TextStyle(
                                fontSize: FontSizeConfig.body(context),
                                color: subColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' x ${item.quantity}',
                              style: TextStyle(
                                fontSize: FontSizeConfig.body(context),
                                color: subColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatAmount(item.totalAmount),
                              style: TextStyle(
                                fontSize: FontSizeConfig.body(context),
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                const SizedBox(height: 12),
                //if edit
                if (onEdit != null && !inventory.confirmed)
                  GradientSubmitButton(
                    onPressed: onEdit!,
                    text: InventoryManagementLocale.editInventory.getString(
                      context,
                    ),
                    width: MediaQuery.of(context).size.width * 0.6,
                  ),
                const SizedBox(height: 12),
                //if type is request then show confirm button
                if (inventory.type == 'REQUESTED' && !inventory.confirmed)
                  GradientSubmitButton(
                    onPressed: () => _onConfirm(inventory.id!, context, ref),
                    text: InventoryManagementLocale.inventoryConfirm.getString(
                      context,
                    ),
                    width: MediaQuery.of(context).size.width * 0.6,
                  ),
                //if type is request then show
                if (inventory.type == 'REQUESTED' && inventory.confirmed)
                  GradientSubmitButton(
                    onPressed: () => {},
                    text: InventoryManagementLocale.inventoryGoToPurchase
                        .getString(context),
                    width: MediaQuery.of(context).size.width * 0.6,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
