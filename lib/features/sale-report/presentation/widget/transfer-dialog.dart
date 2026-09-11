import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/account.api.dart';
import 'package:pos/core/utils/payment-select.dart';
import 'package:pos/features/sale-report/data/model/sale-report.dart'; // TransferType
import 'package:pos/features/sale-report/presentation/provider/sale-report.api.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TransferDialog extends ConsumerStatefulWidget {
  const TransferDialog({super.key});

  @override
  ConsumerState<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<TransferDialog> {
  final TextEditingController _amountController = TextEditingController();
  PaymentData? fromAccount;
  PaymentData? toAccount;
  DateTime selectedDate = DateTime.now();
  TransferType transferType = TransferType.internal;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDate.hour,
          selectedDate.minute,
        );
      });
    }
  }

  bool _validate() {
    if (fromAccount == null || toAccount == null) {
      ShowToast(
        context,
        isError: true,
        description: const Text(
          "Please select both accounts",
          style: TextStyle(color: kRed),
        ),
      );
      return false;
    }
    if (fromAccount!.id == toAccount!.id) {
      ShowToast(
        context,
        isError: true,
        description: const Text(
          "From and To account cannot be the same",
          style: TextStyle(color: kRed),
        ),
      );
      return false;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ShowToast(
        context,
        isError: true,
        description: const Text(
          "Please enter a valid amount",
          style: TextStyle(color: kRed),
        ),
      );
      return false;
    }
    return true;
  }

  void saveTransfer() async {
    debugPrint(
      "selected date is ${selectedDate.toIso8601String().split("T")[0]}",
    );
    if (!_validate()) return;
    setState(() => _isSaving = true);
    try {
      final amount = double.parse(_amountController.text.trim());
      final date = selectedDate.toIso8601String().split("T")[0];

      final result = await ref
          .read(saleReportProvider.notifier)
          .postTransfer(
            from: fromAccount!.id,
            to: toAccount!.id,
            amount: amount,
            date: date,
            transferType: transferType == TransferType.external
                ? "EXTERNAL"
                : "INTERNAL",
          );

      if (result == true) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ShowToast(
            context,
            description: const Text(
              "Transfer created successfully",
              style: TextStyle(color: kGreen),
            ),
          );
        }
      } else {
        ShowToast(
          context,
          isError: true,
          description: const Text(
            "Failed to create transfer",
            style: TextStyle(color: kRed),
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Transfer creation failed';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        errorMessage = data['message']?.toString() ?? errorMessage;
      }
      debugPrint("Transfer Creation Failed 😣 $errorMessage");
      if (mounted) {
        ShowToast(
          context,
          isError: true,
          description: Text(errorMessage, style: const TextStyle(color: kRed)),
        );
      }
    } catch (e) {
      debugPrint("Transfer Creation Failed 😣 ${e.toString()}");
      ShowToast(
        context,
        isError: true,
        description: const Text(
          "Something went wrong",
          style: TextStyle(color: kRed),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onChangeForFromAccount(PaymentData value) {
    debugPrint("value for onChange from account $value");
    setState(() {
      fromAccount = value;
    });
  }

  void _onChangeForToAccount(value) {
    debugPrint("value for onChange to account $value");
    setState(() {
      toAccount = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final paymentAccounts = ref.watch(paymentDataProvider);

    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Transfer",
                style: TextStyle(
                  fontSize: FontSizeConfig.title(context),
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),

              // ── Transfer detail card ────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? kPrimary.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Transfer type (radio) ────────
                    Text(
                      "Transfer Type",
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _TransferTypeOption(
                            label: "Internal",
                            icon: LucideIcons.repeat,
                            isSelected: transferType == TransferType.internal,
                            isDark: isDark,
                            onTap: () => setState(
                              () => transferType = TransferType.internal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TransferTypeOption(
                            label: "External",
                            icon: LucideIcons.externalLink,
                            isSelected: transferType == TransferType.external,
                            isDark: isDark,
                            onTap: () => setState(
                              () => transferType = TransferType.external,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // From account
                    Text(
                      "From Account",
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: PaymentSelect(
                        allPayment: false,
                        onChanged: _onChangeForFromAccount,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // To account
                    Text(
                      "To Account",
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: PaymentSelect(
                        allPayment: false,
                        onChanged: _onChangeForToAccount,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    Text(
                      "Amount",
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ShadInput(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      placeholder: const Text("0.00"),
                    ),
                    const SizedBox(height: 16),

                    // Date
                    Text(
                      "Date",
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                              style: TextStyle(color: textColor),
                            ),
                            Icon(LucideIcons.calendar, color: textColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Save button ───────────────────
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kSecondary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ShadButton(
                    backgroundColor: Colors.transparent,
                    onPressed: _isSaving ? null : saveTransfer,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── Radio-style selectable chip for transfer type ──────
class _TransferTypeOption extends StatelessWidget {
  const _TransferTypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? kTextDark : kTextLight;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? kPrimary : borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 16,
              color: isSelected ? kPrimary : textColor.withOpacity(0.4),
            ),
            const SizedBox(width: 6),
            Icon(
              icon,
              size: 15,
              color: isSelected ? kPrimary : textColor.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? kPrimary : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
