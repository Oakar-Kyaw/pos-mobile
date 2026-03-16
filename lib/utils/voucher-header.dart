import 'package:flutter/material.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/utils/badge.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VoucherHeader extends StatelessWidget {
  const VoucherHeader({
    super.key,
    required IconData typeIcon,
    required this.inventory,
    required this.accent,
    required this.isConfirmed,
    required this.textColor,
    required this.subColor,
  }) : _typeIcon = typeIcon;

  final IconData _typeIcon;
  final InventoryManagement inventory;
  final Color accent;
  final bool isConfirmed;
  final Color textColor;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type icon + badge + id + date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badges row
              Row(
                children: [
                  BadgeWidget(
                    icon: _typeIcon,
                    label: inventory.type.toUpperCase(),
                    color: accent,
                  ),
                  const SizedBox(width: 6),
                  BadgeWidget(
                    icon: isConfirmed
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    label: isConfirmed ? 'CONFIRMED' : 'PENDING',
                    color: isConfirmed
                        ? Colors.green.shade600
                        : Colors.amber.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${inventory.id ?? '—'}',
                        style: TextStyle(
                          fontSize: FontSizeConfig.title(context),
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      // Date
                      if (inventory.createdAt != null)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: subColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat(
                                'dd MMM yyyy EEEE',
                              ).format(inventory.createdAt!),
                              style: TextStyle(
                                fontSize: FontSizeConfig.body(context),
                                color: subColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  // Total amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(fontSize: 11, color: subColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatAmount(inventory.totalAmount),
                        style: TextStyle(
                          fontSize: FontSizeConfig.title(context) + 2,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Item count pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.layers_rounded, size: 11, color: accent),
                            const SizedBox(width: 4),
                            Text(
                              '${inventory.items.length} items',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}
