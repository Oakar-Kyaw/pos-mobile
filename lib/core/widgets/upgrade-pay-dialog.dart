import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/utils/photo-widget.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AccountUpgradeDialog extends ConsumerStatefulWidget {
  const AccountUpgradeDialog({super.key});

  @override
  ConsumerState<AccountUpgradeDialog> createState() =>
      _AccountUpgradeDialogState();
}

class _AccountUpgradeDialogState extends ConsumerState<AccountUpgradeDialog> {
  String type = "card";
  File? imageFile;

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
          ShadRadioGroup<String>(
            onChanged: (value) => {
              setState(() {
                type = value!;
              }),
            },
            items: [
              ShadRadio(label: Text('Kpay or WavePay'), value: 'ewallet'),
              SizedBox(height: 10),
              ShadRadio(label: Text('Card'), value: 'card'),
            ],
          ),
          SizedBox(height: 20),

          SizedBox(height: 20),
          type == 'ewallet'
              ? EWalletWidget(
                  image: imageFile,
                  uploadPhoto: () async {
                    uploadPhoto();
                  },
                  clearPhoto: () => clearPhoto(),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
