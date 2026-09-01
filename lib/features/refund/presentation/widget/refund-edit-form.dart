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

class RefundEditForm extends ConsumerStatefulWidget {
  final Refund refund;

  const RefundEditForm({super.key, required this.refund});

  @override
  ConsumerState<RefundEditForm> createState() => _RefundEditFormState();
}

class _RefundEditFormState extends ConsumerState<RefundEditForm> {
  Timer? _debounce;
  final _formKey = GlobalKey<ShadFormState>();

  late final TextEditingController amountCtrl;
  late final TextEditingController reasonCtrl;
  final voucherSearchCtrl = TextEditingController();
  late List<TextEditingController> paymentAmountController;
  int? voucherId;
  String paymentType = "CASH";
  late String refundType;

  double totalPaidAmount = 0.0;
  List<RefundItem> refundItems = [];
  List<RefundPayment> refundPayment = [];
  late List<TextEditingController> refundItemQtyController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    // ---- Pre-fill from existing refund ----
    final refund = widget.refund;

    voucherId = refund.voucherId;
    refundType = refund.refundType;
    selectedDate = refund.date;

    amountCtrl = TextEditingController(text: refund.amount.toString());
    reasonCtrl = TextEditingController(text: refund.reason ?? '');
    voucherSearchCtrl.text = refund.voucher!.voucherCode ?? 'alex';

    refundItems = List<RefundItem>.from(refund.refundItems);
    refundItemQtyController = refundItems
        .map((item) => TextEditingController(text: item.quantity.toString()))
        .toList();

    refundPayment = List<RefundPayment>.from(refund.refundPayments);
    paymentAmountController = refundPayment
        .map((e) => TextEditingController(text: e.amount.toString()))
        .toList();

    totalPaidAmount = _calculateTotalPaidAmount();
  }

  void _onAddRefundItemList(VoucherDetailModel voucher) {
    try {
      if (voucher.isRefund == true) throw AlreadyRefunded();
      double totalAmount = 0;
      setState(() {
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
        for (final c in refundItemQtyController) {
          c.dispose();
        }
        refundItemQtyController = voucher.items.map((item) {
          totalAmount += item.price * item.quantity;
          return TextEditingController(text: item.quantity.toString());
        }).toList();

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
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      await ref.read(voucherProvider.notifier).searchVoucher(search: value);
    });
  }

  void _submit() async {
    try {
      if (voucherId == null) throw NotSelectVoucherError();
      if (refundItems.isEmpty) throw AddRefundItemError();
      if (refundPayment.isEmpty) throw AddRefundPaymentError();

      final expensePayment = List.generate(
        refundPayment.length,
        (index) => {
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

      debugPrint(
        "🟡 Refund Update Payload => $payload, ${refundItems.length} items",
      );

      // <-- change to your actual update method
      await ref
          .read(refundProvider.notifier)
          .updateRefund(widget.refund.id, payload)
          .then((success) {
            if (success) {
              ShowToast(
                context,
                description: Text(RefundLocale.editSuccess.getString(context)),
              );
              context.pushReplacementNamed(AppRoute.refund);
              return;
            } else {
              ShowToast(
                context,
                isError: true,
                description: Text(
                  RefundLocale.editFailed.getString(context),
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
          RefundLocale.editFailed.getString(context),
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

    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          Text(
            RefundLocale.selectPayment.getString(context),
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
          _gap(height: 10),

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

          DateSelectorCard(
            formattedDate: formattedDate,
            onTap: _pickDate,
            isDark: isDark,
          ),
          const SizedBox(height: 15),

          GradientSubmitButton(
            onPressed: _submit,
            text: RefundLocale.update.getString(
              context,
            ), // <-- new locale key, or reuse refundCreate
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
