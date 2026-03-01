import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/general-expense.api.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/date-ui.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/localization/general-expense-local.dart';

class GeneralExpenseForm extends ConsumerStatefulWidget {
  final VoidCallback? onSaved;
  const GeneralExpenseForm({super.key, this.onSaved});

  @override
  ConsumerState<GeneralExpenseForm> createState() => _GeneralExpenseFormState();
}

class _GeneralExpenseFormState extends ConsumerState<GeneralExpenseForm> {
  final _formKey = GlobalKey<ShadFormState>();

  final title = TextEditingController();
  final amount = TextEditingController();
  final reason = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String paymentMethod = "Cash";
  bool isSubmitting = false;

  Future<void> submit() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);
    print(
      "Submitting expense: Title: ${title.text}, Amount: ${amount.text}, Reason: ${reason.text}, Date: ${selectedDate?.toIso8601String() ?? 'Not selected'}, Payment Method: $paymentMethod",
    );
    final success = await ref
        .read(generalExpenseProvider.notifier)
        .createExpense(
          title: title.text,
          amount: double.tryParse(amount.text) ?? 0.0,
          reason: reason.text.isEmpty ? null : reason.text,
          date: DateFormat('yyyy-MM-dd').format(selectedDate),
        );
    if (success) {
      // Clear form after successful submission
      // 1️⃣ Reset the form
      _formKey.currentState!.reset();
      title.clear();
      amount.clear();
      reason.clear();
      setState(() => selectedDate = DateTime.now());

      widget.onSaved?.call(); // Notify parent that form was saved

      ShowToast(
        context,
        description: Text(
          GeneralExpenseLocale.expenseSaveSuccess.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.title(context)),
        ),
      );
      setState(() => isSubmitting = false);
    } else {
      ShowToast(
        context,
        description: Text(
          GeneralExpenseLocale.expenseSaveFailed.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.title(context)),
        ),
        borderColor: Colors.redAccent,
        action: Icon(LucideIcons.x, color: Colors.redAccent),
      );
      setState(() => isSubmitting = false);
    }
  }

  String? requiredValidator(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return GeneralExpenseLocale.expenseValidationError.getString(context);
    }
    return null;
  }

  String? amountValidator(String? value, BuildContext context) {
    if (requiredValidator(value, context) != null) {
      return requiredValidator(value, context);
    }
    if (double.tryParse(value!) == null || double.parse(value) <= 0) {
      return GeneralExpenseLocale.expenseAmountValidator.getString(context);
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final formattedDate = DateFormat('EEE, dd MMM yyyy').format(selectedDate);

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: FontSizeConfig.body(context),
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );

    Widget placeholder(String text) =>
        Text(text, style: TextStyle(fontSize: FontSizeConfig.body(context)));

    return ShadForm(
      key: _formKey,
      child: Column(
        children: [
          /// ── Title ─────────────────────────
          ShadInputFormField(
            controller: title,
            validator: (v) => requiredValidator(v, context),
            label: label(GeneralExpenseLocale.expenseTitle.getString(context)),
            placeholder: placeholder(
              GeneralExpenseLocale.expenseTitle.getString(context),
            ),
          ),
          const SizedBox(height: 15),

          /// ── Amount ─────────────────────────
          ShadInputFormField(
            controller: amount,
            validator: (v) => amountValidator(v, context),
            keyboardType: TextInputType.number,
            label: label(GeneralExpenseLocale.expenseAmount.getString(context)),
            placeholder: placeholder(
              GeneralExpenseLocale.expenseAmount.getString(context),
            ),
          ),
          const SizedBox(height: 15),

          /// ── Description ────────────────────
          ShadInputFormField(
            controller: reason,
            maxLines: 2,
            label: label(GeneralExpenseLocale.expenseReason.getString(context)),
            placeholder: placeholder(
              GeneralExpenseLocale.expenseReason.getString(context),
            ),
          ),
          const SizedBox(height: 15),

          /// ── Date Picker ────────────────────
          DateSelectorCard(
            formattedDate: formattedDate,
            onTap: _pickDate,
            isDark: isDark,
          ),
          const SizedBox(height: 15),

          /// ── Submit Button ───────────────────
          isSubmitting
              ? SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, kSecondary],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ShadButton(
                      backgroundColor: Colors.transparent,
                      onPressed: null, // Disable button while submitting
                      child: const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, kSecondary],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ShadButton(
                      backgroundColor: Colors.transparent,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          submit();
                        }
                      },
                      child: Text(
                        GeneralExpenseLocale.expenseButton.getString(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
