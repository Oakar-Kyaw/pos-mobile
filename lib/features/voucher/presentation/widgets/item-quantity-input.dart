import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QtyInputField extends StatefulWidget {
  const QtyInputField({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.textColor,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final Color? textColor;

  @override
  State<QtyInputField> createState() => _QtyInputFieldState();
}

class _QtyInputFieldState extends State<QtyInputField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.quantity.toString(),
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant QtyInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // +/- button တွေက quantity ကို ပြင်ရင်, user မရိုက်နေချိန်မှာသာ
    // input ကို sync ပြန်လုပ်ပါ (ရိုက်နေတုန်း cursor ခုန်မသွားစေရန်)
    final external = widget.quantity.toString();
    if (oldWidget.quantity != widget.quantity &&
        !_focusNode.hasFocus &&
        _controller.text != external) {
      _controller.text = external;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 1) {
      // မမှန်ရင် ဟောင်းတန်ဖိုးကို ပြန်ထည့်ပါ
      _controller.text = widget.quantity.toString();
      return;
    }
    if (parsed != widget.quantity) {
      widget.onChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: widget.textColor,
          fontSize: 15,
        ),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4),
          border: UnderlineInputBorder(),
        ),
        onSubmitted: _submit,
        onTapOutside: (_) {
          _focusNode.unfocus();
          _submit(_controller.text);
        },
      ),
    );
  }
}
