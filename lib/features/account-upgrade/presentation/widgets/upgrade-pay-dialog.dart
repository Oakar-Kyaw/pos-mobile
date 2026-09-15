import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/utils/photo-widget.dart';
import 'package:pos/features/account-upgrade/domain/entites/plan.dart';
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
    //print("🤬 clear");
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
    print(
      "Edgett is $type $amount ${widget.plan.id} $imageFile ${widget.plan.durationDays} ${now}",
    );
  }

  @override
  Widget build(BuildContext context) {
    //print("🤖 card type is $type");
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        "Pay with Kpay, Wave or Card",
        style: TextStyle(fontSize: FontSizeConfig.title(context)),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              text: "End Date: ",
              children: [
                TextSpan(
                  text: DateFormat('dd MMM yyyy, EEEE').format(endDate),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          ShadRadioGroup<String>(
            onChanged: (value) => {
              setState(() {
                type = value!;
              }),
            },
            items: [
              ShadRadio(label: Text('Kpay or WavePay'), value: 'EWALLET'),
              SizedBox(height: 10),
              ShadRadio(label: Text('Card'), value: 'CARD'),
            ],
          ),

          SizedBox(height: 20),
          type == 'EWALLET'
              ? EWalletWidget(
                  image: imageFile,
                  uploadPhoto: () async {
                    uploadPhoto();
                  },
                  onChangedAmount: (String v) {
                    if (v.isEmpty) return;
                    final amountNumber = double.tryParse(v);
                    onChangedAmount(amountNumber!);
                  },
                  onConfirm: () => onConfirm(),
                  clearPhoto: () => clearPhoto(),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
