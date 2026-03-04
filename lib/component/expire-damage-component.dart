// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:pos/models/inventory-management.dart';

// class ExpireDamageListComponent extends StatelessWidget {
//   ExpireDamageListComponent({
//     super.key,
//     required this.textColor,
//     required this.subColor,
//     required this.pagingController,
//   });

//   final Color textColor;
//   final Color subColor;
//   PagingController<int, InventoryManagement> pagingController;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
          // ── Left accent bar ──
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [accent, accent.withOpacity(0.3)],
                ),
              ),
            ),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
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
                              _Badge(
                                icon: _typeIcon,
                                label: inventory.type.toUpperCase(),
                                color: accent,
                              ),
                              const SizedBox(width: 6),
                              _Badge(
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
                          Text(
                            '#${inventory.id ?? '—'}',
                            style: TextStyle(
                              fontSize: FontSizeConfig.title(context),
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),

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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.layers_rounded,
                                size: 11,
                                color: accent,
                              ),
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

                // Reason / Note
                if (inventory.reason != null || inventory.note != null) ...[
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
                        Colors.grey.shade200,
                        Colors.grey.shade100,
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
                            maxLines: 1,
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
                          'x${item.quantity}',
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

                // "and X more" if items > 3
                if (inventory.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '+ ${inventory.items.length - 3} more items',
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: accent,
                        fontWeight: FontWeight.w600,
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

////////////////////////////////////////////////////////////////
/// Badge
////////////////////////////////////////////////////////////////

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
