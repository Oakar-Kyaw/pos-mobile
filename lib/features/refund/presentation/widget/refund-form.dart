import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/core/utils/payment-row.dart';
import 'package:pos/core/utils/payment-select.dart';
import 'package:pos/features/refund/data/model/refund-item.dart';
import 'package:pos/features/refund/data/model/refund.dart';
import 'package:pos/features/refund/presentation/provider/refund.api.dart';
import 'package:pos/features/refund/presentation/widget/refund-item-input.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/date-ui.dart';
import 'package:pos/utils/route-constant.dart';
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
  late List<TextEditingController> paymentAmountController;
  late int? voucherId;
  String paymentType = "CASH";
  String refundType = "FULL";

  double totalPaidAmount = 0.0;
  List<RefundItem> refundItems = [];
  final List<RefundPayment> refundPayment = [];
  late List<TextEditingController> refundItemQtyController;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    refundItemQtyController = List.generate(
      refundItems.length,
      (index) =>
          TextEditingController(text: refundItems[index].quantity.toString()),
    );

    paymentAmountController = refundPayment
        .map((e) => TextEditingController(text: e.amount.toString()))
        .toList();
  }

  void _onAddRefundItemList(VoucherDetailModel voucher) {
    try {
      if (voucher.isRefund == true) throw AlreadyRefunded();
      double totalAmount = 0;
      setState(() {
        //clear refundItem first because only one one voucher allow
        refundItems.clear();
        voucherSearchCtrl.text = voucher.voucherCode!;
        voucherId = voucher.id;
        refundItems.addAll(
          voucher.items.map(
            (item) => RefundItem(
              id: item.productId,
              product: item.product!,
              quantity: item.quantity,
              price: item.price,
              avgCostPrice: item.avgCostPrice,
              createdAt: DateTime.now(),
            ),
          ),
        );
        refundItemQtyController.addAll(
          voucher.items.map((item) {
            totalAmount += item.price * item.quantity;
            return TextEditingController(text: item.quantity.toString());
          }),
        );

        amountCtrl.text = totalAmount.toString();
      });
    } on AlreadyRefunded {
      ShowToast(
        context,
        isError: true,
        description: Text(
          RefundLocale.alreadyRefunded.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    } catch (e) {
      ShowToast(
        context,
        isError: true,
        description: Text(
          RefundLocale.failedAddingRefundItem.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    }
  }

  void _addPayment(PaymentData v) {
    setState(() {
      final exists = refundPayment.any((p) => p.paymentDataId == v.id);
      if (exists) return;

      refundPayment.add(
        RefundPayment(
          id: v.id,
          refundId: v.id,
          paymentDataId: v.id,
          amount: 0,
          type: v.accountType,
          paymentData: v,
        ),
      );
      paymentAmountController.add(TextEditingController(text: '0'));
    });
  }

  void _onVoucherSearchChanged(String value) {
    //print("Voucer search: $value");
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      // Call your provider search here
      await ref.read(voucherProvider.notifier).searchVoucher(search: value);
    });
  }

  // void _onProductSearchChanged(String value) {
  //   //print("Product search: $value");
  //   // Cancel previous timer
  //   if (_debounce?.isActive ?? false) _debounce!.cancel();

  //   _debounce = Timer(const Duration(milliseconds: 400), () {
  //     // Call your provider search here
  //     ref.read(productProvider.notifier).searchProducts(search: value);
  //   });
  // }

  // void _onProductItemChanged(RefundItem item, int quantity) {
  //   setState(() {
  //     final index = refundItems.indexWhere(
  //       (i) => i.productId == item.productId,
  //     );
  //     if (index != -1) {
  //       refundItems[index] = refundItems[index].copyWith(quantity: quantity);
  //     }
  //   });
  // }

  // void _changeAccountType(String? value) {
  //   if (value == null) return;
  //   print("Selected payment type: $value");
  //   PaymentData data = PaymentData.fromJson(jsonDecode(value));
  //   setState(() {
  //     paymentType = data.accountType;
  //     paymentDataId = data.id;
  //   });
  // }

  void _submit() async {
    try {
      // print("voucherid. ${DateFormat('yyyy-MM-dd').format(selectedDate)}");

      if (voucherId == null) throw NotSelectVoucherError();

      if (refundItems.isEmpty) throw AddRefundItemError();

      if (refundPayment.isEmpty) throw AddRefundPaymentError();

      final expensePayment = List.generate(
        refundPayment.length,
        (index) => {
          // "id": purchaseItems[index].id,
          "paymentDataId": refundPayment[index].paymentData!.id,
          "amount": double.tryParse(paymentAmountController[index].text) ?? 0,
          "type": refundPayment[index].type,
        },
      );

      final refundItemLists = List.generate(
        refundItems.length,
        (index) => {
          'productId': refundItems[index].product.id,
          'quantity': double.tryParse(refundItemQtyController[index].text) ?? 0,
          'price': refundItems[index].price,
          'avgCostPrice': refundItems[index].avgCostPrice,
        },
      );

      final payload = {
        "voucherId": voucherId,
        "amount": double.parse(amountCtrl.text),
        'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        "reason": reasonCtrl.text,
        "refundType": refundType,
        "refundItems": refundItemLists,
        "refundPayment": expensePayment,
      };

      debugPrint("🟢 Refund Payload => $payload, ${refundItems.length} items");

      await ref.read(refundProvider.notifier).createRefund(payload).then((
        success,
      ) {
        if (success) {
          ShowToast(
            context,
            description: Text(
              RefundLocale.refundSaveSuccess.getString(context),
            ),
          );
          context.pushReplacementNamed(AppRoute.refund);
          return;
        } else {
          ShowToast(
            context,
            isError: true,
            description: Text(
              RefundLocale.refundSaveFailed.getString(context),
              style: TextStyle(color: kRed),
            ),
          );
        }
      });
    } on NotSelectVoucherError {
      ShowToast(
        context,
        isError: true,
        description: Text(
          RefundLocale.refundSelectVoucher.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    } on AddRefundItemError {
      ShowToast(
        context,
        isError: true,
        description: Text(
          RefundLocale.refundNoSelectedItems.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    } on AddRefundPaymentError {
      ShowToast(
        context,
        isError: true,
        description: Text(
          RefundLocale.selectPayment.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    } catch (e) {
      ShowToast(
        context,
        isError: true,
        description: Text(
          RefundLocale.refundSaveFailed.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    }
  }

  void _removeRefundItem(int index) {
    setState(() {
      refundItemQtyController[index].dispose();
      refundItemQtyController.removeAt(index);
      refundItems.removeAt(index);
      amountCtrl.text = _calculateTotalAmount().toString();
    });
  }

  double _calculateTotalPaidAmount() {
    return paymentAmountController.fold<double>(
      0.0,
      (sum, controller) => sum + (double.tryParse(controller.text) ?? 0.0),
    );
  }

  void _removePayment(int index) {
    setState(() {
      paymentAmountController[index].dispose();
      paymentAmountController.removeAt(index);
      refundPayment.removeAt(index);
    });
  }

  double _calculateTotalAmount() {
    double sum = 0.0;
    for (var i = 0; i < refundItems.length; i++) {
      final qty = double.tryParse(refundItemQtyController[i].text) ?? 0.0;
      sum += qty * refundItems[i].price;
    }
    return sum;
  }

  double _calculateUserPaidAmount() {
    try {
      double total = (double.tryParse(amountCtrl.text) ?? 0) - totalPaidAmount;
      if (total < 0) throw Error();
      return total;
    } catch (e) {
      return 0;
    }
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
  void dispose() {
    for (final r in refundItemQtyController) {
      r.dispose();
    }

    for (final p in paymentAmountController) {
      p.dispose();
    }

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
    final formattedDate = DateFormat('dd MMM yyyy').format(selectedDate);
    // final progressIndicatorColor = isDark
    //     ? kPrimary
    //     : kPrimary.withOpacity(0.8);
    // final paymentLists = ref.watch(paymentDataProvider);

    // print("Selected Voucher ID: ${paymentList?[0].id}");
    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Voucher Select
          _label(
            context,
            RefundLocale.refundSelectVoucher.getString(context),
            labelColor,
          ),
          _gap(height: 5),
          VoucherSearchField(
            controller: voucherSearchCtrl,
            onSearchChanged: _onVoucherSearchChanged,
            onVoucherSelected: _onAddRefundItemList,
          ),
          _gap(height: 5),

          /// Selected Items List
          _label(
            context,
            RefundLocale.refundItems.getString(context),
            labelColor,
          ),

          if (refundItems.isEmpty)
            Text(
              RefundLocale.refundNoSelectedItems.getString(context),
              style: TextStyle(color: subColor),
            )
          else
            ...List.generate(refundItems.length, (index) {
              final refund = refundItems[index];
              return RefundItemInput(
                index: index,
                itemName: refund.product.name,
                price: refund.price,
                controller: refundItemQtyController[index],
                validator: (v) {
                  if (v.isEmpty || v == '0') {
                    return RefundLocale.invalidAmount.getString(context);
                  }
                  return null;
                },
                onAmountChanged: (_) {
                  amountCtrl.text = _calculateTotalAmount().toString();
                  setState(() {});
                },

                onRemove: () => _removeRefundItem(index),
              );
            }),
          _gap(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ShadRadioGroup<String>(
              initialValue: refundType,
              alignment: WrapAlignment.center,
              onChanged: (value) => setState(() => refundType = value!),
              spacing: 5,
              items: [
                ShadRadio(
                  label: Text(RefundLocale.refundFull.getString(context)),
                  value: 'FULL',
                ),
                SizedBox(height: 10),
                ShadRadio(
                  label: Text(RefundLocale.refundPartial.getString(context)),
                  value: 'PARTIAL',
                ),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(RefundLocale.leftAmount.getString(context)),
                const Spacer(),
                Text(
                  "${_calculateUserPaidAmount()}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _gap(height: 30),

          //select payment
          Text(
            RefundLocale.selectPayment.getString(context),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),
          //payment select widget
          SizedBox(
            width: double.infinity,
            child: PaymentSelect(
              allPayment: false,
              onChanged: (PaymentData v) => _addPayment(v),
            ),
          ),
          _gap(height: 10),

          //selected payment amount row
          ...List.generate(refundPayment.length, (index) {
            final payment = refundPayment[index];
            return PaymentRow(
              index: index,
              accountName: payment.paymentData!.accountName,
              controller: paymentAmountController[index],
              validator: (v) {
                if (v.isEmpty || v == '0') {
                  return RefundLocale.invalidAmount.getString(context);
                }
                return null;
              },
              onAmountChanged: (_) {
                setState(() {
                  totalPaidAmount = _calculateTotalPaidAmount();
                });
              },
              onRemove: () => _removePayment(index),
            );
          }),
          _gap(height: 10),

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

          /// ── Date Picker ────────────────────
          DateSelectorCard(
            formattedDate: formattedDate,
            onTap: _pickDate,
            isDark: isDark,
          ),
          const SizedBox(height: 15),

          /// Submit Button
          GradientSubmitButton(
            onPressed: _submit,
            text: RefundLocale.refundCreate.getString(context),
            width: double.infinity,
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
    return ShadInputFormField(
      controller: controller,
      label: _label(context, label, labelColor),
      maxLines: maxLines,
      keyboardType: keyboardType,
      placeholder: Text(placeholder),
    );
  }
}
