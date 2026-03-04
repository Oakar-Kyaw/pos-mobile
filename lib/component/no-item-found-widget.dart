import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NoItemFoundWidget extends StatelessWidget {
  const NoItemFoundWidget({super.key, required this.subColor});

  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.ticket, color: kPrimary, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            VoucherScreenLocale.noItems.getString(context),
            style: TextStyle(color: subColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
