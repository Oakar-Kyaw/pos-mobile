import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EWalletWidget extends ConsumerWidget {
  final File? image;
  final Function clearPhoto;
  final Function uploadPhoto;
  final Function onChangedAmount;
  final VoidCallback onConfirm;
  const EWalletWidget({
    super.key,
    required this.clearPhoto,
    required this.uploadPhoto,
    required this.onChangedAmount,
    required this.onConfirm,
    this.image,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Please copy Phone Number",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text("+1 234 567 890", style: TextStyle(fontSize: 16)),
            IconButton(
              icon: Icon(Icons.copy, size: 18),
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: "+1 234 567 890")),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: kGreenSecondary,
          ),
          child: Text(
            "Upload your screenshot that has been transferred to my phone account",
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ShadInputFormField(
            onChanged: (v) => onChangedAmount(v),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        //picker
        ImagePickerWidget(
          image: image,
          clearPhoto: clearPhoto,
          uploadPhoto: uploadPhoto,
          subColor: subColor,
        ),
        const SizedBox(height: 20),

        GradientSubmitButton(
          onPressed: onConfirm,
          text: "Confirm",
          width: double.infinity,
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  const ImagePickerWidget({
    super.key,
    required this.image,
    required this.clearPhoto,
    required this.uploadPhoto,
    required this.subColor,
  });

  final File? image;
  final Function clearPhoto;
  final Function uploadPhoto;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: image != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    image!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => clearPhoto(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: () => uploadPhoto(),
              child: DottedBorder(
                options: RectDottedBorderOptions(
                  color: kPrimary.withOpacity(0.4),
                  dashPattern: const [6, 4],
                  strokeWidth: 1.5,
                  padding: const EdgeInsets.all(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.imagePlus,
                          size: 26,
                          color: kPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload photo',
                        style: TextStyle(
                          color: subColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
