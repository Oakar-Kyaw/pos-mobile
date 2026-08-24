import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Widget customGap({double height = 20}) => SizedBox(height: height);

Widget customLabel(BuildContext context, String key, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      key.getString(context),
      style: TextStyle(
        fontSize: FontSizeConfig.body(context),
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );
}

Widget customInput(
  BuildContext context, {
  required dynamic label,
  required String placeholder,
  required TextEditingController controller,
  required Color labelColor,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ShadInputFormField(
      controller: controller,
      label: customLabel(context, label, labelColor),
      maxLines: maxLines,
      keyboardType: keyboardType,
      placeholder: Text(
        placeholder.getString(context),
        style: TextStyle(fontSize: FontSizeConfig.body(context)),
      ),
    ),
  );
}
