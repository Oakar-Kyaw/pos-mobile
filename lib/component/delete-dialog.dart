import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/voucher-body.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/localization/payment-data-local.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/payment-icon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void showDeleteDialog(
  BuildContext context, {
  required String title,
  required bool isDark,
  required submit,
  int? paymentDataId,
}) {
  final subColor = isDark ? kTextSubDark : kTextSubLight;
  final progressIndicatorColor = isDark ? kPrimary : kPrimary.withOpacity(0.8);

  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        GeneralScreenLocale.cancel.getString(context),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        GeneralScreenLocale.confirm.getString(context),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
