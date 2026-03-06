import 'package:flutter/material.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/left-bar-accent.dart';
import 'package:pos/utils/voucher-header.dart';

class ExpireDamageCard extends StatelessWidget {
  const ExpireDamageCard({
    super.key,
    required this.inventory,
    required this.textColor,
    required this.subColor,
  });

  final InventoryManagement inventory;
  final Color textColor;
  final Color subColor;

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

  @override
  Widget build(BuildContext context) {
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

          // ── Content ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                VoucherHeader(
                  typeIcon: _typeIcon,
                  inventory: inventory,
                  accent: accent,
                  isConfirmed: isConfirmed,
                  textColor: textColor,
                  subColor: subColor,
                ),

                // Reason / Note
                if (inventory.reason != null || inventory.note != null) ...[
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Text("Reason / Note"),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accent.withOpacity(0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (inventory.reason != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.flag_rounded, size: 12, color: accent),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  inventory.reason!,
                                  style: TextStyle(
                                    fontSize: FontSizeConfig.body(context),
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (inventory.reason != null && inventory.note != null)
                          const SizedBox(height: 6),
                        if (inventory.note != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.notes_rounded,
                                size: 12,
                                color: subColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  inventory.note!,
                                  style: TextStyle(
                                    fontSize: FontSizeConfig.body(context),
                                    color: subColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 168, 167, 167),
                        const Color.fromARGB(255, 85, 84, 84),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Items
                ...inventory.items
                //.take(3)
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
