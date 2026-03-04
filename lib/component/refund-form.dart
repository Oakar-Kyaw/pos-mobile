import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/account.api.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/api/refund.api.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/localization/payment-data-local.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/models/refund-item.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/payment-icon.dart';
import 'package:pos/utils/product-search-field.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:pos/utils/voucher-search-field.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'dart:async';

class RefundForm extends ConsumerStatefulWidget {
  const RefundForm({super.key});

  @override
  ConsumerState<RefundForm> createState() => _RefundFormState();
}

class _RefundFormState extends ConsumerState<RefundForm> {
  Timer? _debounce;
  final _formKey = GlobalKey<ShadFormState>();

  final amountCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();
  final voucherSearchCtrl = TextEditingController();

  int? voucherId;
  String paymentType = "CASH";
  int? paymentDataId;
  int? productId;
  String refundType = "FULL";

  List<RefundItem> refundItems = [];

  void _onVoucherSearchChanged(String value) {
    //print("Voucer search: $value");
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      // Call your provider search here
      ref.read(voucherProvider.notifier).searchVoucher(search: value);
    });
  }

  void _onProductSearchChanged(String value) {
    //print("Product search: $value");
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      // Call your provider search here
      ref.read(productProvider.notifier).searchProducts(search: value);
    });
  }

  void _onProductItemChanged(RefundItem item, int quantity) {
    setState(() {
      final index = refundItems.indexWhere(
        (i) => i.productId == item.productId,
      );
      if (index != -1) {
        refundItems[index] = refundItems[index].copyWith(quantity: quantity);
      }
    });
  }

  void _changeAccountType(String? value) {
    if (value == null) return;
    print("Selected payment type: $value");
    PaymentData data = PaymentData.fromJson(jsonDecode(value));
    setState(() {
      paymentType = data.accountType;
      paymentDataId = data.id;
    });
  }

  void _submit() async {
    final payload = {
      "voucherId": voucherId,
      "amount": double.parse(amountCtrl.text),
      "reason": reasonCtrl.text,
      "paymentType": paymentType,
      "paymentDataId": paymentDataId,
      "refundType": refundType,
      "refundItems": refundItems.map((e) => e.toJson()).toList(),
    };

    debugPrint("🟢 Refund Payload => $payload, ${refundItems.length} items");

    ref
        .read(refundProvider.notifier)
        .createRefund(payload)
        .then((success) {
          if (success) {
            ShowToast(
              context,
              description: Text(
                RefundLocale.refundSaveSuccess.getString(context),
                style: TextStyle(fontSize: FontSizeConfig.title(context)),
              ),
            );
          } else {
            ShowToast(
              context,
              description: Text(
                RefundLocale.refundSaveFailed.getString(context),
                style: TextStyle(fontSize: FontSizeConfig.title(context)),
              ),
            );
          }
        })
        .onError((error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $error")));
        });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    amountCtrl.dispose();
    reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final labelColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final progressIndicatorColor = isDark
        ? kPrimary
        : kPrimary.withOpacity(0.8);
    final paymentLists = ref.watch(paymentDataProvider);

    // print("Selected Voucher ID: ${paymentList?[0].id}");
    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Voucher Select
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: _label(context, "Select Voucher", labelColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: VoucherSearchField(
              onSearchChanged: _onVoucherSearchChanged,
              onVoucherSelected: (id) => setState(() => voucherId = id),
            ),
          ),
          _gap(height: 5),

          /// Item Select
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: _label(context, "Select Product Items", labelColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ProductItemSearchField<RefundItem>(
              onSearchChanged: _onProductSearchChanged,
              itemBuilder: (product) => RefundItem(
                id: 0,
                product: product,
                productId: product.id,
                quantity: 1,
                price: product.price,
                createdAt: DateTime.now(),
              ),
              onProductSelected: (refund) =>
                  setState(() => refundItems.add(refund)),
            ),
          ),
          _gap(height: 5),

          /// Selected Items List
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: _label(context, "Refund Items", labelColor),
          ),

          if (refundItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "No items selected for refund.",
                style: TextStyle(color: subColor),
              ),
            )
          else
            ...refundItems.map(
              (item) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: kPrimary.withOpacity(0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item.price.toStringAsFixed(2)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Qty: "),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 60,
                        child: ShadInputFormField(
                          decoration: const ShadDecoration(
                            secondaryFocusedBorder: ShadBorder.none,
                          ),
                          initialValue: item.quantity.toString(),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            final qty = int.tryParse(value);
                            if (qty != null && qty > 0) {
                              _onProductItemChanged(item, qty);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          _gap(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ShadRadioGroup<String>(
              initialValue: refundType,
              alignment: WrapAlignment.center,
              onChanged: (value) => setState(() => refundType = value!),
              spacing: 5,
              items: [
                ShadRadio(label: Text('Full'), value: 'FULL'),
                SizedBox(height: 10),
                ShadRadio(label: Text('Partial'), value: 'PARTIAL'),
              ],
            ),
          ),

          _gap(height: 20),

          /// Refund Amount
          _input(
            context,
            label: RefundLocale.refundAmount.getString(context),
            placeholder: RefundLocale.refundAmountPlaceholder.getString(
              context,
            ),
            controller: amountCtrl,
            labelColor: labelColor,
            keyboardType: TextInputType.number,
          ),

          _gap(height: 20),

          /// Reason
          _input(
            context,
            label: RefundLocale.refundReason.getString(context),
            placeholder: RefundLocale.refundReasonPlaceholder.getString(
              context,
            ),
            controller: reasonCtrl,
            labelColor: labelColor,
            maxLines: 2,
          ),

          _gap(height: 20),

          /// Select Account Label
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10),
            child: _label(context, "Select Account", labelColor),
          ),

          /// ── Account Type ───────────────────
          paymentLists.when(
            data: (paymentList) => Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 5),
              child: ShadSelect<String>(
                minWidth: double.infinity,
                placeholder: Text(
                  PaymentDataLocale.type.getString(context),
                  style: TextStyle(color: subColor),
                ),
                selectedOptionBuilder: (context, value) {
                  final selected = PaymentData.fromJson(jsonDecode(value));
                  return Text(selected.accountName);
                },
                onChanged: _changeAccountType,
                options: paymentList.map(
                  (e) => ShadOption(
                    value: jsonEncode(e),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                paymentIcon(e.accountName),
                                size: 16,
                                color: kPrimary,
                              ),
                              const SizedBox(width: 10),
                              Text(e.accountName),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                e.accountType,
                                style: TextStyle(color: subColor, fontSize: 12),
                              ),
                              Text(
                                " :",
                                style: TextStyle(color: subColor, fontSize: 12),
                              ),
                              const SizedBox(width: 5),

                              Text(
                                e.accountNumber ?? '',
                                style: TextStyle(color: subColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            loading: () => Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(color: progressIndicatorColor),
              ),
            ),
            error: (error, stackTrace) =>
                Text("Error loading payment list: $error"),
          ),

          _gap(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text("Total Refund Amount"),
                const Spacer(),
                Text(
                  "\$${refundItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity))}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _gap(height: 30),

          /// Submit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kSecondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ShadButton(
                  backgroundColor: Colors.transparent,
                  onPressed: _submit,
                  child: const Text(
                    "Create Refund",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gap({double height = 10}) => SizedBox(height: height);

  Widget _label(BuildContext context, String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _input(
    BuildContext context, {
    required String label,
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
        label: _label(context, label, labelColor),
        maxLines: maxLines,
        keyboardType: keyboardType,
        placeholder: Text(placeholder),
      ),
    );
  }
}
