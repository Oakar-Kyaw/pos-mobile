import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/utils/payment-row.dart';
import 'package:pos/core/utils/payment-select.dart';
import 'package:pos/features/general-expense/data/model/general-expense.dart';
import 'package:pos/features/general-expense/presentation/provider/general-expense.api.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/date-ui.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
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
  final List<GeneralExpensePayment> generalExpensePayment = [];
  final TextEditingController _title = TextEditingController();
  final TextEditingController _reason = TextEditingController();
  late List<TextEditingController> paymentAmountController;
  double totalAmount = 0.0; // Initialize total amount to 0.0

  DateTime selectedDate = DateTime.now();
  String paymentMethod = "Cash";
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    paymentAmountController = generalExpensePayment
        .map((e) => TextEditingController(text: e.amount.toString()))
        .toList();
  }

  @override
  void dispose() {
    for (final c in paymentAmountController) {
      c.dispose();
    }
    _title.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);
    final expensePayment = List.generate(
      generalExpensePayment.length,
      (index) => {
        // "id": purchaseItems[index].id,
        "paymentDataId": generalExpensePayment[index].paymentData!.id,
        "amount": double.tryParse(paymentAmountController[index].text) ?? 0,
        "type": generalExpensePayment[index].type,
      },
    );
    print(
      "Submitting expense: Title: ${_title.text}, Reason: ${_reason.text}, Date: ${selectedDate.toIso8601String()}, Payment Method: $expensePayment",
    );

    final success = await ref
        .read(generalExpenseProvider.notifier)
        .createExpense(
          title: _title.text,
          amount: totalAmount,
          reason: _reason.text.isEmpty ? null : _reason.text,
          date: DateFormat('yyyy-MM-dd').format(selectedDate),
          payments: expensePayment,
        );
    if (success) {
      // Clear form after successful submission
      // 1️⃣ Reset the form
      _formKey.currentState!.reset();
      _title.clear();
      _reason.clear();
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

  void _addPayment(PaymentData v) {
    setState(() {
      final exists = generalExpensePayment.any((p) => p.paymentDataId == v.id);
      if (exists) return;

      generalExpensePayment.add(
        GeneralExpensePayment(
          id: v.id,
          generalExpenseId: v.id,
          paymentDataId: v.id,
          amount: 0,
          type: v.accountType,
          paymentData: v,
        ),
      );
      paymentAmountController.add(TextEditingController(text: '0'));

      totalAmount = _calculateTotalAmount();
    });
  }

  void _removePayment(int index) {
    setState(() {
      paymentAmountController[index].dispose();
      paymentAmountController.removeAt(index);
      generalExpensePayment.removeAt(index);
    });
  }

  double _calculateTotalAmount() {
    return paymentAmountController.fold<double>(
      0.0,
      (sum, controller) => sum + (double.tryParse(controller.text) ?? 0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final formattedDate = DateFormat('dd MMM yyyy').format(selectedDate);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── Title ─────────────────────────
          ShadInputFormField(
            controller: _title,
            validator: (v) => requiredValidator(v, context),
            label: label(GeneralExpenseLocale.expenseTitle.getString(context)),
            placeholder: placeholder(
              GeneralExpenseLocale.expenseTitle.getString(context),
            ),
          ),
          const SizedBox(height: 15),

          Text(
            PaymentScreenLocale.selectPaymentAccount.getString(context),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: PaymentSelect(
              allPayment: false,
              onChanged: (PaymentData v) => _addPayment(v),
            ),
          ),

          ...List.generate(generalExpensePayment.length, (index) {
            final payment = generalExpensePayment[index];
            return PaymentRow(
              index: index,
              accountName: payment.paymentData!.accountName,
              controller: paymentAmountController[index],
              validator: (v) {
                if (v.isEmpty || v == '0') {
                  return GeneralExpenseLocale.expenseAmountValidator.getString(
                    context,
                  );
                }
                return null;
              },
              onAmountChanged: (_) {
                setState(() {
                  totalAmount = _calculateTotalAmount();
                });
              },
              onRemove: () => _removePayment(index),
            );
          }),
          const SizedBox(height: 20),

          Text(
            "${GeneralExpenseLocale.expenseAmount.getString(context)} - ${formatAmount(totalAmount)}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// ── Description ────────────────────
          ShadInputFormField(
            controller: _reason,
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
