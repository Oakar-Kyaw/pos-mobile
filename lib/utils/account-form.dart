import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/account.api.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/models/account.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/localization/payment-data-local.dart';

class AccountForm extends ConsumerStatefulWidget {
  final PaymentData? existedData;
  final VoidCallback? onSaved;
  const AccountForm({super.key, this.existedData, this.onSaved});

  @override
  ConsumerState<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<AccountForm> {
  final _formKey = GlobalKey<ShadFormState>();
  final nameController = TextEditingController();
  final accountNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final balanceController = TextEditingController();

  String accountType = "BANK";
  bool isSubmitting = false;
  int balance = 0;

  @override
  void initState() {
    super.initState();
    _fillForm();
  }

  @override
  void didUpdateWidget(covariant AccountForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.existedData != oldWidget.existedData) {
      _fillForm();
    }
  }

  void _fillForm() {
    final data = widget.existedData;

    if (data == null) return;

    accountNameController.text = data.accountName;
    accountNumberController.text = data.accountNumber!;
    balanceController.text = data.balance.toString();
    accountType = data.accountType;
  }

  Future<void> submit() async {
    if (isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    bool success = false;
    if (widget.existedData == null) {
      success = await ref
          .read(paymentDataProvider.notifier)
          .createAccount(
            accountName: accountNameController.text,
            accountNumber: accountNumberController.text.isEmpty
                ? null
                : accountNumberController.text,
            accountType: accountType,
            balance: double.parse(balanceController.text),
            isActive: true,
          );
    } else if (widget.existedData != null) {
      success = await ref
          .read(paymentDataProvider.notifier)
          .updateAccount(
            id: widget.existedData!.id,
            accountName: accountNameController.text,
            accountNumber: accountNumberController.text.isEmpty
                ? null
                : accountNumberController.text,
            accountType: accountType,
            balance: double.parse(balanceController.text),
            isActive: true,
          );
    }

    if (success) {
      _formKey.currentState!.reset();
      accountNameController.clear();
      accountNumberController.clear();
      balanceController.clear();
      setState(() => accountType = "CASH");

      widget.onSaved?.call(); // notify parent

      ShowToast(
        context,
        description: Text(
          widget.existedData != null
              ? PaymentDataLocale.accountEditSuccess.getString(context)
              : PaymentDataLocale.accountSaveSuccess.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.title(context)),
        ),
      );
    } else {
      ShowToast(
        context,
        description: Text(
          widget.existedData != null
              ? PaymentDataLocale.accountEditFailed.getString(context)
              : PaymentDataLocale.accountSaveFailed.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.title(context)),
        ),
        borderColor: Colors.redAccent,
        action: Icon(Icons.close, color: Colors.redAccent),
      );
    }

    setState(() => isSubmitting = false);
  }

  String? requiredValidator(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return PaymentDataLocale.accountValidationError.getString(context);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final paymentMethodCollections = {
      'CASH': PaymentScreenLocale.paymentCash.getString(context),
      'BANK': PaymentScreenLocale.paymentBank.getString(context),
      'CARD': PaymentScreenLocale.paymentCard.getString(context),
      'EWALLET': PaymentScreenLocale.paymentEWallet.getString(context),
    };

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
          // name
          ShadInputFormField(
            controller: accountNameController,
            validator: (v) => requiredValidator(v, context),
            label: label(PaymentDataLocale.bankName.getString(context)),
            placeholder: placeholder(
              PaymentDataLocale.bankName.getString(context),
            ),
          ),
          SizedBox(height: 20),

          /// ── Account Number ─────────────────
          ShadInputFormField(
            controller: accountNumberController,
            validator: (v) => requiredValidator(v, context),
            keyboardType: TextInputType.number,
            label: label(PaymentDataLocale.accountNumber.getString(context)),
            placeholder: placeholder(
              PaymentDataLocale.accountNumber.getString(context),
            ),
          ),
          const SizedBox(height: 20),

          /// ── Account Balance ─────────────────
          ShadInputFormField(
            controller: balanceController,
            validator: (v) => requiredValidator(v, context),
            keyboardType: TextInputType.number,
            label: label(PaymentDataLocale.balance.getString(context)),
            placeholder: placeholder(
              PaymentDataLocale.balance.getString(context),
            ),
          ),
          const SizedBox(height: 20),

          /// ── Account Type ───────────────────
          ShadSelect<String>(
            minWidth: double.infinity,
            placeholder: Text(
              PaymentDataLocale.type.getString(context),
              style: TextStyle(color: subColor),
            ),
            selectedOptionBuilder: (context, value) =>
                Text(paymentMethodCollections[value]!),
            onChanged: (value) {
              if (value == null) return;
              setState(() => accountType = value);
            },
            options: paymentMethodCollections.entries.map(
              (e) => ShadOption(
                value: e.key,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(_paymentIcon(e.key), size: 16, color: kPrimary),
                      const SizedBox(width: 10),
                      Text(e.value),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ── Submit Button ─────────────────
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPrimary, kSecondary]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ShadButton(
                backgroundColor: Colors.transparent,
                onPressed: isSubmitting ? null : submit,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.existedData != null
                            ? PaymentDataLocale.editButton.getString(context)
                            : PaymentDataLocale.saveButton.getString(context),
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

  IconData _paymentIcon(String type) {
    switch (type) {
      case 'CASH':
        return LucideIcons.banknote;
      case 'BANK':
        return LucideIcons.landmark;
      case 'CARD':
        return LucideIcons.creditCard;
      case 'EWALLET':
        return LucideIcons.wallet;
      default:
        return LucideIcons.circleDollarSign;
    }
  }
}
