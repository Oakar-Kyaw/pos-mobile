import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/delete-icon.dart';
import 'package:pos/features/customer/data/model/customer-model.dart';
import 'package:pos/localization/customer-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/left-bar-accent.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomerCard extends ConsumerWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.textColor,
    required this.subColor,
    this.onDelete,
    this.onEdit,
    this.onDetail,
  });

  final Customer customer;

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
          // ==========================================
          // LEFT ACCENT
          // ==========================================
          LeftAccentBar(accent: accent),

          // ==========================================
          // DELETE
          // ==========================================
          if (onDelete != null) DeleteIcon(onDelete: onDelete),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // HEADER
                // ==========================================
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: accent.withOpacity(.15),
                      child: Icon(
                        Icons.person_rounded,
                        color: accent,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
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
                            customer.email ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: FontSizeConfig.body(context),
                              color: subColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==========================================
                // DIVIDER
                // ==========================================
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

                // ==========================================
                // PHONE
                // ==========================================
                CustomerInfoRow(
                  icon: Icons.phone_outlined,
                  title: CustomerLocale.customerPhone.getString(context),
                  value: customer.phone ?? '-',
                  textColor: textColor,
                  subColor: subColor,
                  accent: accent,
                ),

                const SizedBox(height: 8),

                // ==========================================
                // EMAIL
                // ==========================================
                CustomerInfoRow(
                  icon: Icons.email_outlined,
                  title: CustomerLocale.customerEmail.getString(context),
                  value: customer.email ?? '-',
                  textColor: textColor,
                  subColor: subColor,
                  accent: accent,
                ),

                const SizedBox(height: 8),

                // ==========================================
                // ADDRESS
                // ==========================================
                CustomerInfoRow(
                  icon: Icons.location_on_outlined,
                  title: CustomerLocale.customerAddress.getString(context),
                  value: customer.address ?? '-',
                  textColor: textColor,
                  subColor: subColor,
                  accent: accent,
                ),

                const SizedBox(height: 12),

                // ==========================================
                // CREATED DATE
                // ==========================================
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: subColor,
                    ),

                    const SizedBox(width: 8),
                  ],
                ),

                const SizedBox(height: 14),

                // ==========================================
                // BUTTONS
                // ==========================================
                Row(
                  children: [
                    GradientSubmitButton(
                      width: 150,
                      onPressed: onDetail ?? () {},
                      text: CustomerLocale.customerDetail.getString(context),
                    ),

                    const SizedBox(width: 10),

                    GradientSubmitButton(
                      width: 150,
                      onPressed: onEdit ?? () {},
                      text: CustomerLocale.customerEdit.getString(context),
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

// ======================================================
// CUSTOMER INFO ROW
// ======================================================

class CustomerInfoRow extends StatelessWidget {
  const CustomerInfoRow({
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
        Icon(icon, size: 18, color: accent),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            title,
            style: TextStyle(color: subColor, fontWeight: FontWeight.w500),
          ),
        ),

        const SizedBox(width: 10),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
