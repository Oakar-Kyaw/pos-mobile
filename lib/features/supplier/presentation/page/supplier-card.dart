import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/delete-icon.dart';
import 'package:pos/features/supplier/data/model/supplier.dart';
import 'package:pos/localization/supplier-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/left-bar-accent.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SupplierCard extends ConsumerWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    required this.textColor,
    required this.subColor,
    this.onDelete,
    this.onEdit,
    this.onDetail,
  });

  final Supplier supplier;

  final Color textColor;
  final Color subColor;

  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDetail;

  Color get _accentColor {
    return kPrimary;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = _accentColor;

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
          // ============================================
          // LEFT ACCENT
          // ============================================
          LeftAccentBar(accent: accent),

          // ============================================
          // DELETE
          // ============================================
          if (onDelete != null) DeleteIcon(onDelete: onDelete),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // HEADER
                // ============================================
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: accent.withOpacity(.15),
                      child: Icon(LucideIcons.truck, color: accent, size: 21),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: FontSizeConfig.title(context),
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            SupplierLocale.supplierManagementTitle.getString(
                              context,
                            ),
                            style: TextStyle(
                              fontSize: FontSizeConfig.body(context),
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ============================================
                // DIVIDER
                // ============================================
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

                const SizedBox(height: 14),

                // ============================================
                // PHONE
                // ============================================
                if (supplier.phone != null && supplier.phone!.isNotEmpty)
                  SupplierInfoRow(
                    icon: LucideIcons.phone,
                    title: SupplierLocale.supplierPhone.getString(context),
                    value: supplier.phone!,
                    textColor: textColor,
                    subColor: subColor,
                    accent: accent,
                  ),

                if (supplier.phone != null && supplier.phone!.isNotEmpty)
                  const SizedBox(height: 10),

                // ============================================
                // EMAIL
                // ============================================
                if (supplier.email != null && supplier.email!.isNotEmpty)
                  SupplierInfoRow(
                    icon: LucideIcons.mail,
                    title: SupplierLocale.supplierEmail.getString(context),
                    value: supplier.email!,
                    textColor: textColor,
                    subColor: subColor,
                    accent: accent,
                  ),

                if (supplier.email != null && supplier.email!.isNotEmpty)
                  const SizedBox(height: 10),

                // ============================================
                // ADDRESS
                // ============================================
                if (supplier.address != null && supplier.address!.isNotEmpty)
                  SupplierInfoRow(
                    icon: LucideIcons.mapPin,
                    title: SupplierLocale.supplierAddress.getString(context),
                    value: supplier.address!,
                    textColor: textColor,
                    subColor: subColor,
                    accent: accent,
                  ),

                const SizedBox(height: 14),

                // ============================================
                // COMPANY / BRANCH
                // ============================================
                // Row(
                //   children: [
                //     if (supplier.companyId != null)
                //       Expanded(
                //         child: SupplierInfoRow(
                //           icon: LucideIcons.building2,
                //           title: SupplierLocale.supplierCompany.getString(
                //             context,
                //           ),
                //           value: supplier.companyId.toString(),
                //           textColor: textColor,
                //           subColor: subColor,
                //           accent: accent,
                //         ),
                //       ),

                //     if (supplier.branchId != null)
                //       Expanded(
                //         child: SupplierInfoRow(
                //           icon: LucideIcons.store,
                //           title: SupplierLocale.supplierBranch.getString(
                //             context,
                //           ),
                //           value: supplier.branchId.toString(),
                //           textColor: textColor,
                //           subColor: subColor,
                //           accent: accent,
                //         ),
                //       ),
                //   ],
                // ),
                const SizedBox(height: 16),

                // ============================================
                // BUTTONS
                // ============================================
                // Row(
                //   children: [
                //     Expanded(
                //       child: GradientSubmitButton(
                //         onPressed: onDetail ?? () {},
                //         text: SupplierLocale.supplierDetail
                //             .getString(context),
                //       ),
                //     ),

                //     const SizedBox(width: 10),

                //     Expanded(
                //       child: GradientSubmitButton(
                //         onPressed: onEdit ?? () {},
                //         text: SupplierLocale.supplierEdit
                //             .getString(context),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUPPLIER INFO ROW
// ============================================================

class SupplierInfoRow extends StatelessWidget {
  const SupplierInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.textColor,
    required this.subColor,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String value;

  final Color textColor;
  final Color subColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: accent.withOpacity(.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: accent),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  color: subColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
