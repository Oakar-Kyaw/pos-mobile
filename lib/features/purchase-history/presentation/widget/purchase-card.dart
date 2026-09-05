import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/widgets/delete-icon.dart';
import 'package:pos/core/widgets/detail-icon.dart';
import 'package:pos/features/purchase-history/data/model/purchase.dart';
import 'package:pos/localization/purchase-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/left-bar-accent.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PurchaseCard extends ConsumerWidget {
  const PurchaseCard({
    super.key,
    required this.purchase,
    required this.textColor,
    required this.subColor,
    this.onDelete,
    this.onEdit,
    this.onSuccess,
    this.onDetail,
  });

  final Purchase purchase;
  final Color textColor;
  final Color subColor;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onSuccess;
  final VoidCallback? onDetail;

  Color get _accentColor {
    switch (purchase.status.toUpperCase()) {
      case 'RECEIVED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return kPrimary;
    }
  }

  IconData get _statusIcon {
    switch (purchase.status.toUpperCase()) {
      case 'RECEIVED':
        return Icons.check_circle_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      case 'PENDING':
        return Icons.pending_actions_rounded;
      default:
        return Icons.shopping_cart_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _accentColor;

    final totalAmount = purchase.purchaseItems.fold<double>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    print("on success $onSuccess");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
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
                /// Header
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: accent.withOpacity(.15),
                      child: Icon(_statusIcon, color: accent, size: 18),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            purchase.supplier?.name ?? '-',
                            style: TextStyle(
                              fontSize: FontSizeConfig.title(context),
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            purchase.status,
                            style: TextStyle(
                              fontSize: FontSizeConfig.body(context),
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DetailIcon(onDetail: onDetail),

                    if (onDelete != null) DeleteIcon(onDelete: onDelete),
                  ],
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

                /// Purchase Items
                ...purchase.purchaseItems
                    .take(2)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                item.product?.name ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: FontSizeConfig.body(context),
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            Text(
                              "${item.quantity} x ${formatAmount(item.price)}",
                              style: TextStyle(
                                color: subColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                if (purchase.purchaseItems.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "+ ${purchase.purchaseItems.length - 2} more items",
                      style: TextStyle(
                        color: subColor,
                        fontSize: FontSizeConfig.body(context),
                      ),
                    ),
                  ),

                PurchasePriceRow(
                  title: PurchaseLocale.purchaseDeliveryFee.getString(context),
                  subColor: subColor,
                  totalAmount: formatAmount(purchase.deliveryFee),
                  accent: accent,
                ),

                const SizedBox(height: 5),

                PurchasePriceRow(
                  title: PurchaseLocale.purchaseTotalAmount.getString(context),
                  subColor: subColor,
                  totalAmount: formatAmount(totalAmount),
                  accent: accent,
                ),

                const SizedBox(height: 5),

                PurchasePriceRow(
                  title: PurchaseLocale.purchaseOrderDate.getString(context),
                  subColor: subColor,
                  totalAmount: DateFormat(
                    'yyyy-MM-dd HH:mm',
                  ).format(purchase.orderDate),
                  accent: accent,
                ),

                const SizedBox(height: 10),

                if (_accentColor == Colors.green) ...[
                  PurchasePriceRow(
                    title: PurchaseLocale.purchaseReceivedDate.getString(
                      context,
                    ),
                    subColor: subColor,
                    totalAmount: purchase.receivedDate != null
                        ? DateFormat(
                            'yyyy-MM-dd E HH:mm',
                          ).format(purchase.receivedDate!.toLocal())
                        : "null",
                    accent: accent,
                  ),

                  const SizedBox(height: 5),
                ],

                Row(
                  children: [
                    purchase.status.toUpperCase() == "SUCCESS"
                        ? const SizedBox()
                        : GradientSubmitButton(
                            width: MediaQuery.of(context).size.width * 0.2,
                            onPressed: onEdit ?? () {},
                            text: PurchaseLocale.purchaseEdit.getString(
                              context,
                            ),
                          ),

                    const SizedBox(width: 10),
                    purchase.status.toUpperCase() == "SUCCESS"
                        ? const SizedBox()
                        : GradientSubmitButton(
                            onPressed: onSuccess ?? () {},
                            text: PurchaseLocale.purchaseSuccess.getString(
                              context,
                            ),
                            width: MediaQuery.of(context).size.width * 0.4,
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PurchasePriceRow extends StatelessWidget {
  const PurchasePriceRow({
    super.key,
    required this.title,
    required this.subColor,
    required this.totalAmount,
    required this.accent,
  });
  final String title;
  final Color subColor;
  final String totalAmount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: subColor, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          totalAmount,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.bold,
            fontSize: FontSizeConfig.title(context),
          ),
        ),
      ],
    );
  }
}
