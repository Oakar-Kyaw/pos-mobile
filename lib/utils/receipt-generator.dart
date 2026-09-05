import 'package:flutter/material.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/utils/myanmar-safe-printer.dart';
import 'package:thermal_unicode_print/thermal_unicode_print.dart';
import 'package:pos/localization/receipt-local.dart';

Future<List<int>> generateReceiptBytes(
  BuildContext context,
  VoucherDetailModel voucher,
  PaperSize paperSize,
) async {
  final profile = await CapabilityProfile.load();
  final paperSizes = paperSize;
  final generator = Generator(paperSizes, profile);

  // Initialize the renderer: 384 dots for 58mm paper size
  const renderer = ThermalUnicodeRenderer(dotsWidth: 384);

  // Define clean, tight reusable styles for your Padauk font

  const TextStyle companyTitleStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  const TextStyle bodyStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 22,
    fontWeight: FontWeight.normal,
  );

  const TextStyle boldBodyStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  const TextStyle largeTotalStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  // Custom tight cell padding configuration to fix your height issue
  const EdgeInsets cellPadding = EdgeInsets.symmetric(vertical: 1.0);

  List<int> bytes = [];
  bytes += generator.reset();

  // Company Name
  if ((voucher.company?.name ?? '').isNotEmpty) {
    bytes += await renderer.textLine(
      generator,
      voucher.company!.name,
      align: TextAlign.center,
      style: companyTitleStyle,
      padding: cellPadding,
    );
  }

  // Contact Info
  if ((voucher.company?.phone ?? '').isNotEmpty) {
    bytes += await renderer.textLine(
      generator,
      "${ReceiptScreenLocale.receiptPhone.getString(context)}: ${voucher.company!.phone!}",
      style: bodyStyle,
      padding: cellPadding,
    );
  }
  if ((voucher.company?.address ?? '').isNotEmpty) {
    bytes += await renderer.textLine(
      generator,
      "${ReceiptScreenLocale.receiptAddress.getString(context)}: ${voucher.company!.address!}",
      style: bodyStyle,
      padding: cellPadding,
    );
  }
  bytes += await renderer.textLine(
    generator,
    "${ReceiptScreenLocale.receiptNo.getString(context)}: ${voucher.voucherCode}",
    style: bodyStyle,
    padding: cellPadding,
  );
  bytes += await renderer.textLine(
    generator,
    "${ReceiptScreenLocale.receiptDate.getString(context)}: ${DateTime.now().toIso8601String().substring(0, 16).replaceFirst('T', ' ')}",
    style: bodyStyle,
    padding: cellPadding,
  );

  bytes += await renderer.divider(
    generator,
    thickness: 1.0,
    verticalPadding: 2.0,
  );

  // Table Columns Header (Width out of 12 grid mapped directly to flex ratios)
  bytes += await renderer.row(generator, [
    ThermalCell(
      ReceiptScreenLocale.receiptItemName.getString(context),
      flex: 6,
      bold: true,
    ),
    ThermalCell(
      ReceiptScreenLocale.receiptItemQty.getString(context),
      flex: 2,
      align: TextAlign.center,
      bold: true,
    ),
    ThermalCell(
      ReceiptScreenLocale.receiptItemAmount.getString(context),
      flex: 4,
      align: TextAlign.right,
      bold: true,
    ),
  ], style: boldBodyStyle);

  bytes += await renderer.divider(
    generator,
    thickness: 1.0,
    verticalPadding: 2.0,
  );

  // Cart Items Loop
  for (final item in voucher.items) {
    bytes += await renderer.row(generator, [
      ThermalCell(item.name, flex: 6),
      ThermalCell("${item.quantity}", flex: 2, align: TextAlign.center),
      ThermalCell(
        formatAmount(item.price * item.quantity),
        flex: 4,
        align: TextAlign.right,
      ),
    ], style: bodyStyle);

    // Print the dynamic unit item price tag sub-line directly below the row tightly
    bytes += await renderer.textLine(
      generator,
      "   x ${formatAmount(item.price)}",
      style: bodyStyle,
      padding: EdgeInsets.zero,
    );
  }

  bytes += await renderer.divider(
    generator,
    thickness: 1.0,
    verticalPadding: 2.0,
  );

  // Financial Breakdown Section
  bytes += await _renderTotalRow(
    renderer,
    generator,
    boldBodyStyle,
    ReceiptScreenLocale.receiptSubtotal.getString(context),
    formatAmount(voucher.subTotal),
  );

  if (voucher.tax > 0) {
    bytes += await _renderTotalRow(
      renderer,
      generator,
      bodyStyle,
      ReceiptScreenLocale.receiptTax.getString(context),
      formatAmount(voucher.tax),
    );
  }
  if (voucher.deliveryFee > 0) {
    bytes += await _renderTotalRow(
      renderer,
      generator,
      bodyStyle,
      ReceiptScreenLocale.receiptDeliveryFee.getString(context),
      formatAmount(voucher.deliveryFee),
    );
  }
  if (voucher.discountAmount > 0) {
    bytes += await _renderTotalRow(
      renderer,
      generator,
      bodyStyle,
      ReceiptScreenLocale.receiptDiscount.getString(context),
      "-${formatAmount(voucher.discountAmount)}",
    );
  }
  if (voucher.discountPercent > 0) {
    bytes += await _renderTotalRow(
      renderer,
      generator,
      bodyStyle,
      ReceiptScreenLocale.receiptDiscount.getString(context),
      "-${formatAmount(voucher.discountPercent)}%",
    );
  }

  bytes += await renderer.divider(
    generator,
    thickness: 2.0,
    verticalPadding: 4.0,
  );

  // Grand Total Block (Using larger scalable font configuration cleanly)
  bytes += await renderer.row(generator, [
    ThermalCell(
      ReceiptScreenLocale.receiptTotal.getString(context),
      flex: 6,
      bold: true,
    ),
    ThermalCell(
      formatAmount(voucher.total),
      flex: 6,
      align: TextAlign.right,
      bold: true,
    ),
  ], style: largeTotalStyle);

  bytes += await renderer.divider(
    generator,
    thickness: 1.0,
    verticalPadding: 4.0,
  );

  // Paid Status Information
  bytes += await _renderTotalRow(
    renderer,
    generator,
    bodyStyle,
    ReceiptScreenLocale.receiptPaidAmount.getString(context),
    formatAmount(voucher.totalPaymentAmount),
  );

  if (voucher.remainingPaymentAmount > 0) {
    bytes += await renderer.row(generator, [
      ThermalCell(
        ReceiptScreenLocale.receiptRemainingAmount.getString(context),
        flex: 6,
        bold: true,
      ),
      ThermalCell(
        formatAmount(voucher.remainingPaymentAmount),
        flex: 6,
        align: TextAlign.right,
        bold: true,
      ),
    ], style: boldBodyStyle);
  }

  // Footer Notes Section
  if ((voucher.note ?? '').isNotEmpty) {
    bytes += await renderer.divider(
      generator,
      thickness: 1.0,
      verticalPadding: 2.0,
    );
    bytes += await renderer.textLine(
      generator,
      voucher.note!,
      style: bodyStyle,
      padding: cellPadding,
    );
  }

  bytes += await renderer.divider(
    generator,
    thickness: 1.0,
    verticalPadding: 4.0,
  );

  bytes += await renderer.textLine(
    generator,
    VoucherScreenLocale.thankYouMessage.getString(context),
    align: TextAlign.center,
    style: boldBodyStyle,
    padding: cellPadding,
  );

  bytes += generator.feed(3);
  bytes += generator.cut();

  return bytes;
}

/// Helper method to keep checkout summary row formatting consistent and simple
Future<List<int>> _renderTotalRow(
  ThermalUnicodeRenderer renderer,
  Generator generator,
  TextStyle style,
  String label,
  String value,
) {
  return renderer.row(generator, [
    ThermalCell(label, flex: 6),
    ThermalCell(value, flex: 6, align: TextAlign.right),
  ], style: style);
}
