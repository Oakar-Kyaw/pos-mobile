import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/utils/photo-widget.dart';
import 'package:pos/features/account-upgrade/domain/entites/plan.dart';
import 'package:pos/localization/account-upgrade.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AccountUpgradeDialog extends ConsumerStatefulWidget {
  final Plan plan;
  const AccountUpgradeDialog({super.key, required this.plan});

  @override
  ConsumerState<AccountUpgradeDialog> createState() =>
      _AccountUpgradeDialogState();
}

class _AccountUpgradeDialogState extends ConsumerState<AccountUpgradeDialog> {
  String type = "CARD";
  double amount = 0;
  final now = DateTime.now();
  late DateTime endDate;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    endDate = DateTime(now.year, now.month + widget.plan.month, now.day);
    amount = double.tryParse(widget.plan.priceMMK) ?? 0.0;
  }

  void uploadPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        imageFile = File(result.files.single.path!);
      });
    }
  }

  void clearPhoto() {
    setState(() {
      imageFile = null;
    });
  }

  void onChangedAmount(double v) {
    setState(() {
      amount = v;
    });
  }

  void onConfirm() {
    debugPrint(
      "Confirmed: type=$type, amount=$amount, planId=${widget.plan.id}, image=$imageFile, durationDays=${widget.plan.durationDays}, createdAt=$now",
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        AccountUpgradeScreenLocale.payHeader.getString(context),
        style: TextStyle(fontSize: FontSizeConfig.title(context)),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                text: AccountUpgradeScreenLocale.endDate.getString(context),
                children: [
                  TextSpan(
                    text: DateFormat('dd MMM yyyy, EEEE').format(endDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ShadRadioGroup<String>(
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    type = value;
                  });
                }
              },
              items: [
                ShadRadio(
                  label: Text(
                    AccountUpgradeScreenLocale.eWalletOption.getString(context),
                  ),
                  value: 'EWALLET',
                ),
                const SizedBox(height: 10),
                ShadRadio(
                  label: Text(
                    AccountUpgradeScreenLocale.cardOption.getString(context),
                  ),
                  value: 'CARD',
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (type == 'EWALLET')
              EWalletWidget(
                image: imageFile,
                uploadPhoto: uploadPhoto,
                onChangedAmount: (String v) {
                  if (v.isEmpty) return;
                  final amountNumber = double.tryParse(v);
                  if (amountNumber != null) {
                    onChangedAmount(amountNumber);
                  }
                },
                onConfirm: onConfirm,
                clearPhoto: clearPhoto,
              ),
          ],
        ),
      ),
    );
  }
}
