import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/core/utils/payment-select.dart';
import 'package:pos/features/general-expense/data/model/general-expense.dart';
import 'package:pos/features/general-expense/presentation/provider/general-expense.api.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/date-ui.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/localization/general-expense-local.dart';

class GeneralExpenseEditForm extends ConsumerStatefulWidget {
  final GeneralExpense expense;
  final VoidCallback? onSaved;

  const GeneralExpenseEditForm({
    super.key,
    required this.expense,
    this.onSaved,
  });

  @override
  ConsumerState<GeneralExpenseEditForm> createState() =>
      _GeneralExpenseEditFormState();
}

class _GeneralExpenseEditFormState
    extends ConsumerState<GeneralExpenseEditForm> {
  final _formKey = GlobalKey<ShadFormState>();
  late final List<GeneralExpensePayment> generalExpensePayment;
  late final TextEditingController _title;
  late final TextEditingController _reason;
  late final List<TextEditingController> paymentAmountController;
  double totalAmount = 0.0;

  late DateTime selectedDate;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    // ── existing data ကို field တွေထဲ pre-fill လုပ်မယ် ──
    _title = TextEditingController(text: expense.title);
    _reason = TextEditingController(text: expense.reason ?? '');
    selectedDate = expense.date;

    generalExpensePayment = List<GeneralExpensePayment>.from(
      expense.generalExpensePayment,
    );

    paymentAmountController = generalExpensePayment
        .map((e) => TextEditingController(text: e.amount.toString()))
        .toList();

    totalAmount = _calculateTotalAmount();
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
    try {
      if (isSubmitting) return;
      setState(() => isSubmitting = true);
      if (generalExpensePayment.isEmpty) {
        throw generalExpensePaymentNotExistError();
      }

      final expensePayment = List.generate(
        generalExpensePayment.length,
        (index) => {
          "paymentDataId": generalExpensePayment[index].paymentDataId,
          "amount": double.tryParse(paymentAmountController[index].text) ?? 0.0,
          "type": generalExpensePayment[index].type,
        },
      );

      print(
        "Updating expense #${widget.expense.id}: Title: ${_title.text}, Reason: ${_reason.text}, Date: ${selectedDate.toIso8601String()}, Payment Method: $expensePayment",
      );

      final success = await ref
          .read(generalExpenseProvider.notifier)
          .updateExpense(
            id: widget.expense.id,
            title: _title.text,
            amount: totalAmount,
            reason: _reason.text.isEmpty ? null : _reason.text,
            date: selectedDate,
            payments: expensePayment,
          );

      if (success) {
        context.pushReplacement(AppRoute.generalExpense);

        ShowToast(
          context,
          description: Text(
            GeneralExpenseLocale.editSuccess.getString(context),
            style: TextStyle(fontSize: FontSizeConfig.title(context)),
          ),
        );
        setState(() => isSubmitting = false);
      } else {
        ShowToast(
          context,
          description: Text(
            GeneralExpenseLocale.editFail.getString(context),
            style: TextStyle(
              fontSize: FontSizeConfig.title(context),
              color: kRed,
            ),
          ),
          borderColor: Colors.redAccent,
          action: Icon(LucideIcons.x, color: Colors.redAccent),
        );
        setState(() => isSubmitting = false);
      }
    } on generalExpensePaymentNotExistError {
      ShowToast(
        context,
        description: Text(
          GeneralExpenseLocale.pleaseSelectPaymentAccount.getString(context),
          style: TextStyle(
            fontSize: FontSizeConfig.title(context),
            color: kRed,
          ),
        ),
        isError: true,
        borderColor: Colors.redAccent,
        action: Icon(LucideIcons.x, color: Colors.redAccent),
      );
      setState(() => isSubmitting = false);
    } catch (e) {
      ShowToast(
        context,
        description: Text(
          GeneralExpenseLocale.editFail.getString(context),
          style: TextStyle(
            fontSize: FontSizeConfig.title(context),
            color: kRed,
          ),
        ),
        isError: true,
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
          generalExpenseId: widget.expense.id,
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
      totalAmount = _calculateTotalAmount();
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
            return Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      payment.paymentData?.accountName ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 9,
                    child: ShadInputFormField(
                      id: 'payment_$index',
                      validator: (v) {
                        if (v.isEmpty || v == '0') {
                          return GeneralExpenseLocale.expenseAmountValidator
                              .getString(context);
                        }
                        return null;
                      },
                      controller: paymentAmountController[index],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {
                        setState(() {
                          totalAmount = _calculateTotalAmount();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => _removePayment(index),
                    icon: const Icon(
                      LucideIcons.trash2,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Remove',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          Text(
            "${GeneralExpenseLocale.expenseAmount.getString(context)} - ${formatAmount(totalAmount)}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          ShadInputFormField(
            controller: _reason,
            maxLines: 2,
            label: label(GeneralExpenseLocale.expenseReason.getString(context)),
            placeholder: placeholder(
              GeneralExpenseLocale.expenseReason.getString(context),
            ),
          ),
          const SizedBox(height: 15),

          DateSelectorCard(
            formattedDate: formattedDate,
            onTap: _pickDate,
            isDark: isDark,
          ),
          const SizedBox(height: 15),

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
                      onPressed: null,
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
                        GeneralExpenseLocale.editExpenseButton.getString(
                          context,
                        ),
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
