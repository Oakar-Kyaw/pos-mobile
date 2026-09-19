import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:pos/features/printer/presentation/provider/printer-provider.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/features/voucher/presentation/widgets/receipt-generator.dart';
import 'package:pos/localization/company-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ReceiptVoucherWidget extends ConsumerStatefulWidget {
  const ReceiptVoucherWidget({
    super.key,
    required this.voucher,
    this.showPrintButton = true,
  });

  final VoucherDetailModel voucher;
  final bool showPrintButton;

  @override
  ConsumerState<ReceiptVoucherWidget> createState() =>
      _ReceiptVoucherWidgetState();
}

class _ReceiptVoucherWidgetState extends ConsumerState<ReceiptVoucherWidget> {
  bool _isPrinting = false;

  static const TextStyle _companyTitleStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle _bodyStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 13,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle _boldBodyStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle _largeTotalStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  Future<void> _printReceipt() async {
    setState(() {
      _isPrinting = true;
    });

    try {
      final bytes = await generateReceiptBytes(
        context,
        widget.voucher,
        PaperSize.mm58,
      );

      await ref
          .read(printerProvider.notifier)
          .printTest(PrinterType.bluetooth, bytes);
    } catch (e) {
      debugPrint('Printing error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final voucher = widget.voucher;
    final company = voucher.company;
    final customer = voucher.customer;
    final createdAt = voucher.createdAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((company?.name ?? '').isNotEmpty)
            Text(
              company?.name ?? '',
              textAlign: TextAlign.center,
              style: _companyTitleStyle,
            ),

          if ((company?.phone ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "${CompanyRegisterScreenLocal.companyPhone.getString(context)}: "
              "${company?.phone ?? ''}",
              textAlign: TextAlign.center,
              style: _bodyStyle,
            ),
          ],

          if ((company?.address ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              "${CompanyRegisterScreenLocal.companyAddress.getString(context)}: "
              "${company?.address ?? ''}",
              textAlign: TextAlign.center,
              maxLines: 4,
              style: _bodyStyle,
            ),
          ],

          const SizedBox(height: 6),

          Text(
            "${VoucherScreenLocale.receiptNo.getString(context)}: "
            "${voucher.voucherCode}",
            style: _bodyStyle,
          ),

          Text(
            "${VoucherScreenLocale.receiptDate.getString(context)}: "
            "${createdAt != null ? DateFormat('d MMM yyyy').format(createdAt) : '-'}",
            style: _bodyStyle,
          ),

          Text(
            "${VoucherScreenLocale.customerName.getString(context)}: "
            "${customer?.name ?? '-'}"
            "(${customer?.phone ?? '-'})",
            style: _bodyStyle,
          ),

          _dashedDivider(),

          Row(
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  VoucherScreenLocale.item.getString(context),
                  style: _boldBodyStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  VoucherScreenLocale.quantity.getString(context),
                  textAlign: TextAlign.center,
                  style: _boldBodyStyle,
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  VoucherScreenLocale.amount.getString(context),
                  textAlign: TextAlign.right,
                  style: _boldBodyStyle,
                ),
              ),
            ],
          ),

          _dashedDivider(),

          ...voucher.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                          item.name,
                          style: _bodyStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "${item.quantity}",
                          textAlign: TextAlign.center,
                          style: _bodyStyle,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          formatAmount(item.price * item.quantity),
                          textAlign: TextAlign.right,
                          style: _bodyStyle,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "   x ${formatAmount(item.price)}",
                    style: _bodyStyle.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

          _dashedDivider(),

          _totalRow(
            VoucherScreenLocale.subtotal.getString(context),
            formatAmount(voucher.subTotal),
            style: _boldBodyStyle,
          ),

          if (voucher.tax > 0)
            _totalRow(
              VoucherScreenLocale.tax.getString(context),
              formatAmount(voucher.tax),
              style: _bodyStyle,
            ),

          if ((voucher.packagingFee ?? 0) > 0)
            _totalRow(
              PaymentScreenLocale.packagingFee.getString(context),
              formatAmount(voucher.packagingFee ?? 0),
              style: _bodyStyle,
            ),

          if (voucher.discountAmount > 0)
            _totalRow(
              PaymentScreenLocale.paymentVoucherDiscountAmount.getString(
                context,
              ),
              "-${formatAmount(voucher.discountAmount)}",
              style: _bodyStyle,
            )
          else if (voucher.discountPercent > 0)
            _totalRow(
              PaymentScreenLocale.paymentVoucherDiscountPercent.getString(
                context,
              ),
              "-${formatAmount(voucher.discountPercent)}%",
              style: _bodyStyle,
            ),

          _dashedDivider(thickness: 2),

          _totalRow(
            VoucherScreenLocale.total.getString(context),
            formatAmount(voucher.total),
            style: _largeTotalStyle,
          ),

          _dashedDivider(),

          Text(
            VoucherScreenLocale.thankYouMessage.getString(context),
            textAlign: TextAlign.center,
            style: _boldBodyStyle,
          ),

          if (widget.showPrintButton) ...[
            const SizedBox(height: 24),
            ShadButton(
              onPressed: _isPrinting ? null : _printReceipt,
              child: _isPrinting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(VoucherScreenLocale.printReceipt.getString(context)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dashedDivider({double thickness = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 4.0;
          const dashSpace = 3.0;

          final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
              .floor();

          return Flex(
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: thickness,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black54),
                ),
              );
            }).expand((w) => [w, const SizedBox(width: dashSpace)]).toList(),
          );
        },
      ),
    );
  }

  Widget _totalRow(String label, String value, {required TextStyle style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: style, overflow: TextOverflow.ellipsis),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }
}
