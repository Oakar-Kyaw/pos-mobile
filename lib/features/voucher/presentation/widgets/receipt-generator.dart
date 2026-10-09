// import 'package:flutter/material.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:flutter_localization/flutter_localization.dart';
// import 'package:pos/features/voucher/data/model/voucher-detail.dart';
// import 'package:pos/localization/voucher-local.dart';
// import 'package:pos/utils/myanmar-safe-printer.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
// import 'package:thermal_unicode_print/thermal_unicode_print.dart';
// import 'package:pos/localization/receipt-local.dart';

// Future<List<int>> generateReceiptBytes(
//   BuildContext context,
//   VoucherDetailModel voucher,
//   PaperSize paperSize,
// ) async {
//   final profile = await CapabilityProfile.load();
//   final paperSizes = paperSize;
//   final generator = Generator(paperSizes, profile);

//   // Initialize the renderer: 384 dots for 58mm paper size
//   const renderer = ThermalUnicodeRenderer(dotsWidth: 384);

//   // Define clean, tight reusable styles for your Padauk font

//   const TextStyle companyTitleStyle = TextStyle(
//     fontFamily: 'NotoSerif',
//     fontSize: 30,
//     fontWeight: FontWeight.bold,
//   );

//   const TextStyle bodyStyle = TextStyle(
//     fontFamily: 'NotoSerif',
//     fontSize: 22,
//     fontWeight: FontWeight.normal,
//   );

//   const TextStyle boldBodyStyle = TextStyle(
//     fontFamily: 'NotoSerif',
//     fontSize: 22,
//     fontWeight: FontWeight.bold,
//   );

//   const TextStyle largeTotalStyle = TextStyle(
//     fontFamily: 'NotoSerif',
//     fontSize: 28,
//     fontWeight: FontWeight.bold,
//   );

//   // Custom tight cell padding configuration to fix your height issue
//   const EdgeInsets cellPadding = EdgeInsets.symmetric(vertical: 1.0);

//   List<int> bytes = [];
//   bytes += generator.reset();

//   // Company Name
//   if ((voucher.company?.name ?? '').isNotEmpty) {
//     bytes += await renderer.textLine(
//       generator,
//       voucher.company!.name,
//       align: TextAlign.center,
//       style: companyTitleStyle,
//       padding: cellPadding,
//     );
//   }

//   // Contact Info
//   if ((voucher.company?.phone ?? '').isNotEmpty) {
//     bytes += await renderer.textLine(
//       generator,
//       "${ReceiptScreenLocale.receiptPhone.getString(context)}: ${voucher.company!.phone!}",
//       style: bodyStyle,
//       padding: cellPadding,
//     );
//   }
//   if ((voucher.company?.address ?? '').isNotEmpty) {
//     bytes += await renderer.textLine(
//       generator,
//       "${ReceiptScreenLocale.receiptAddress.getString(context)}: ${voucher.company!.address!}",
//       style: bodyStyle,
//       padding: cellPadding,
//     );
//   }
//   bytes += await renderer.textLine(
//     generator,
//     "${ReceiptScreenLocale.receiptNo.getString(context)}: ${voucher.voucherCode}",
//     style: bodyStyle,
//     padding: cellPadding,
//   );
//   bytes += await renderer.textLine(
//     generator,
//     "${ReceiptScreenLocale.receiptDate.getString(context)}: ${voucher.createdAt != null ? DateFormat('d MMM yyyy').format(voucher.createdAt!) : ''}",
//     style: bodyStyle,
//     padding: cellPadding,
//   );

//   ///customer name
//   if (voucher.customer != null) {
//     bytes += await renderer.textLine(
//       generator,
//       "${ReceiptScreenLocale.customerName.getString(context)}: ${voucher.customer!.name}(${voucher.customer!.phone ?? "-"})",
//       style: bodyStyle,
//       padding: cellPadding,
//     );
//   }

//   bytes += await renderer.divider(
//     generator,
//     thickness: 1.0,
//     verticalPadding: 2.0,
//   );

//   // Table Columns Header (Width out of 12 grid mapped directly to flex ratios)
//   bytes += await renderer.row(generator, [
//     ThermalCell(
//       ReceiptScreenLocale.receiptItemName.getString(context),
//       flex: 6,
//       bold: true,
//     ),
//     ThermalCell(
//       ReceiptScreenLocale.receiptItemQty.getString(context),
//       flex: 2,
//       align: TextAlign.center,
//       bold: true,
//     ),
//     ThermalCell(
//       ReceiptScreenLocale.receiptItemAmount.getString(context),
//       flex: 4,
//       align: TextAlign.right,
//       bold: true,
//     ),
//   ], style: boldBodyStyle);

//   bytes += await renderer.divider(
//     generator,
//     thickness: 1.0,
//     verticalPadding: 2.0,
//   );

//   // Cart Items Loop
//   for (final item in voucher.items) {
//     bytes += await renderer.row(generator, [
//       ThermalCell(item.name, flex: 6),
//       ThermalCell("${item.quantity}", flex: 2, align: TextAlign.center),
//       ThermalCell(
//         formatAmount(item.price * item.quantity),
//         flex: 4,
//         align: TextAlign.right,
//       ),
//     ], style: bodyStyle);

//     // Print the dynamic unit item price tag sub-line directly below the row tightly
//     bytes += await renderer.textLine(
//       generator,
//       "   x ${formatAmount(item.price)}",
//       style: bodyStyle,
//       padding: EdgeInsets.zero,
//     );
//   }

//   bytes += await renderer.divider(
//     generator,
//     thickness: 1.0,
//     verticalPadding: 2.0,
//   );

//   // Financial Breakdown Section
//   bytes += await _renderTotalRow(
//     renderer,
//     generator,
//     boldBodyStyle,
//     ReceiptScreenLocale.receiptSubtotal.getString(context),
//     formatAmount(voucher.subTotal),
//   );

//   if (voucher.tax > 0) {
//     bytes += await _renderTotalRow(
//       renderer,
//       generator,
//       bodyStyle,
//       ReceiptScreenLocale.receiptTax.getString(context),
//       formatAmount(voucher.tax),
//     );
//   }
//   if (voucher.deliveryFee > 0) {
//     bytes += await _renderTotalRow(
//       renderer,
//       generator,
//       bodyStyle,
//       ReceiptScreenLocale.receiptDeliveryFee.getString(context),
//       formatAmount(voucher.deliveryFee),
//     );
//   }
//   if (voucher.discountAmount > 0) {
//     bytes += await _renderTotalRow(
//       renderer,
//       generator,
//       bodyStyle,
//       ReceiptScreenLocale.receiptDiscount.getString(context),
//       "-${formatAmount(voucher.discountAmount)}",
//     );
//   }
//   if (voucher.discountPercent > 0) {
//     bytes += await _renderTotalRow(
//       renderer,
//       generator,
//       bodyStyle,
//       ReceiptScreenLocale.receiptDiscount.getString(context),
//       "-${formatAmount(voucher.discountPercent)}%",
//     );
//   }

//   if (voucher.packagingFee != null && voucher.packagingFee! > 0) {
//     bytes += await _renderTotalRow(
//       renderer,
//       generator,
//       bodyStyle,
//       ReceiptScreenLocale.packagingFee.getString(context),
//       formatAmount(voucher.packagingFee!),
//     );
//   }

//   bytes += await renderer.divider(
//     generator,
//     thickness: 2.0,
//     verticalPadding: 4.0,
//   );

//   // Grand Total Block (Using larger scalable font configuration cleanly)
//   bytes += await renderer.row(generator, [
//     ThermalCell(
//       ReceiptScreenLocale.receiptTotal.getString(context),
//       flex: 6,
//       bold: true,
//     ),
//     ThermalCell(
//       formatAmount(voucher.total),
//       flex: 6,
//       align: TextAlign.right,
//       bold: true,
//     ),
//   ], style: largeTotalStyle);

//   bytes += await renderer.divider(
//     generator,
//     thickness: 1.0,
//     verticalPadding: 4.0,
//   );

//   // Paid Status Information
//   bytes += await _renderTotalRow(
//     renderer,
//     generator,
//     bodyStyle,
//     ReceiptScreenLocale.receiptPaidAmount.getString(context),
//     formatAmount(voucher.totalPaymentAmount),
//   );

//   if (voucher.remainingPaymentAmount > 0) {
//     bytes += await renderer.row(generator, [
//       ThermalCell(
//         ReceiptScreenLocale.receiptRemainingAmount.getString(context),
//         flex: 6,
//         bold: true,
//       ),
//       ThermalCell(
//         formatAmount(voucher.remainingPaymentAmount),
//         flex: 6,
//         align: TextAlign.right,
//         bold: true,
//       ),
//     ], style: boldBodyStyle);
//   }

//   // Footer Notes Section
//   if ((voucher.note ?? '').isNotEmpty) {
//     bytes += await renderer.divider(
//       generator,
//       thickness: 1.0,
//       verticalPadding: 2.0,
//     );
//     bytes += await renderer.textLine(
//       generator,
//       voucher.note!,
//       style: bodyStyle,
//       padding: cellPadding,
//     );
//   }

//   bytes += await renderer.divider(
//     generator,
//     thickness: 1.0,
//     verticalPadding: 4.0,
//   );

//   bytes += await renderer.textLine(
//     generator,
//     VoucherScreenLocale.thankYouMessage.getString(context),
//     align: TextAlign.center,
//     style: boldBodyStyle,
//     padding: cellPadding,
//   );

//   bytes += generator.feed(3);
//   bytes += generator.cut();

//   return bytes;
// }

// /// Helper method to keep checkout summary row formatting consistent and simple
// Future<List<int>> _renderTotalRow(
//   ThermalUnicodeRenderer renderer,
//   Generator generator,
//   TextStyle style,
//   String label,
//   String value,
// ) {
//   return renderer.row(generator, [
//     ThermalCell(label, flex: 6),
//     ThermalCell(value, flex: 6, align: TextAlign.right),
//   ], style: style);
// }

import 'package:flutter/material.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/localization/receipt-local.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:thermal_unicode_print/thermal_unicode_print.dart';

// ---------------------------------------------------------------------------
// Helpers: ASCII only lines => native ESC/POS text (few bytes)
//          Burmese lines    => image via ThermalUnicodeRenderer (big bytes)
// ---------------------------------------------------------------------------

bool _isAscii(String s) => s.codeUnits.every((c) => c < 128);

PosAlign _posAlign(TextAlign a) {
  switch (a) {
    case TextAlign.center:
      return PosAlign.center;
    case TextAlign.right:
    case TextAlign.end:
      return PosAlign.right;
    default:
      return PosAlign.left;
  }
}

class _Cell {
  final String text;
  final int flex;
  final TextAlign align;
  final bool bold;
  const _Cell(
    this.text, {
    this.flex = 6,
    this.align = TextAlign.left,
    this.bold = false,
  });
}

/// Single line: native text if ASCII, otherwise image.
Future<List<int>> _line(
  ThermalUnicodeRenderer renderer,
  Generator generator,
  String text, {
  required TextStyle style,
  TextAlign align = TextAlign.left,
  EdgeInsets padding = EdgeInsets.zero,
  bool bold = false,
}) async {
  if (_isAscii(text)) {
    return generator.text(
      text,
      styles: PosStyles(align: _posAlign(align), bold: bold),
    );
  }
  return renderer.textLine(
    generator,
    text,
    align: align,
    style: style,
    padding: padding,
  );
}

/// Multi column row: native if every cell is ASCII, otherwise image.
Future<List<int>> _row(
  ThermalUnicodeRenderer renderer,
  Generator generator,
  List<_Cell> cells, {
  required TextStyle style,
}) async {
  final allAscii = cells.every((c) => _isAscii(c.text));

  if (allAscii) {
    // esc_pos_utils column widths must sum to 12
    final totalFlex = cells.fold<int>(0, (sum, c) => sum + c.flex);
    final widths = cells.map((c) => (c.flex * 12 / totalFlex).round()).toList();
    final diff = 12 - widths.fold<int>(0, (a, b) => a + b);
    widths[widths.length - 1] += diff;

    return generator.row([
      for (var i = 0; i < cells.length; i++)
        PosColumn(
          text: cells[i].text,
          width: widths[i],
          styles: PosStyles(
            align: _posAlign(cells[i].align),
            bold: cells[i].bold,
          ),
        ),
    ]);
  }

  return renderer.row(generator, [
    for (final c in cells)
      ThermalCell(c.text, flex: c.flex, align: c.align, bold: c.bold),
  ], style: style);
}

/// Divider as native text (very small).
List<int> _divider(Generator generator, {bool thick = false}) {
  return generator.hr(ch: thick ? '=' : '-');
}

Future<List<int>> _totalRow(
  ThermalUnicodeRenderer renderer,
  Generator generator,
  TextStyle style,
  String label,
  String value, {
  bool bold = false,
}) {
  return _row(renderer, generator, [
    _Cell(label, flex: 6, bold: bold),
    _Cell(value, flex: 6, align: TextAlign.right, bold: bold),
  ], style: style);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

Future<List<int>> generateReceiptBytes(
  BuildContext context,
  VoucherDetailModel voucher,
  PaperSize paperSize,
) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(paperSize, profile);

  // 384 dots for 58mm paper
  const renderer = ThermalUnicodeRenderer(dotsWidth: 384);

  // Smaller font sizes => fewer image rows => fewer bytes
  const TextStyle companyTitleStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  const TextStyle bodyStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 20,
    fontWeight: FontWeight.normal,
  );

  const TextStyle boldBodyStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  const TextStyle largeTotalStyle = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  const EdgeInsets cellPadding = EdgeInsets.symmetric(vertical: 1.0);

  List<int> bytes = [];
  bytes += generator.reset();

  // Company name
  if ((voucher.company?.name ?? '').isNotEmpty) {
    bytes += await _line(
      renderer,
      generator,
      voucher.company!.name,
      align: TextAlign.center,
      style: companyTitleStyle,
      padding: cellPadding,
      bold: true,
    );
  }

  // Contact info
  if ((voucher.company?.phone ?? '').isNotEmpty) {
    bytes += await _line(
      renderer,
      generator,
      "${ReceiptScreenLocale.receiptPhone.getString(context)}: ${voucher.company!.phone!}",
      style: bodyStyle,
      padding: cellPadding,
    );
  }
  if ((voucher.company?.address ?? '').isNotEmpty) {
    bytes += await _line(
      renderer,
      generator,
      "${ReceiptScreenLocale.receiptAddress.getString(context)}: ${voucher.company!.address!}",
      style: bodyStyle,
      padding: cellPadding,
    );
  }
  bytes += await _line(
    renderer,
    generator,
    "${ReceiptScreenLocale.receiptNo.getString(context)}: ${voucher.voucherCode}",
    style: bodyStyle,
    padding: cellPadding,
  );
  bytes += await _line(
    renderer,
    generator,
    "${ReceiptScreenLocale.receiptDate.getString(context)}: ${voucher.createdAt != null ? DateFormat('d MMM yyyy').format(voucher.createdAt!) : ''}",
    style: bodyStyle,
    padding: cellPadding,
  );

  // Customer
  if (voucher.customer != null) {
    bytes += await _line(
      renderer,
      generator,
      "${ReceiptScreenLocale.customerName.getString(context)}: ${voucher.customer!.name}(${voucher.customer!.phone ?? "-"})",
      style: bodyStyle,
      padding: cellPadding,
    );
  }

  bytes += _divider(generator);

  // Table header
  bytes += await _row(renderer, generator, [
    _Cell(
      ReceiptScreenLocale.receiptItemName.getString(context),
      flex: 6,
      bold: true,
    ),
    _Cell(
      ReceiptScreenLocale.receiptItemQty.getString(context),
      flex: 2,
      align: TextAlign.center,
      bold: true,
    ),
    _Cell(
      ReceiptScreenLocale.receiptItemAmount.getString(context),
      flex: 4,
      align: TextAlign.right,
      bold: true,
    ),
  ], style: boldBodyStyle);

  bytes += _divider(generator);

  // Items
  for (final item in voucher.items) {
    // Line 1: item name (Burmese => image, English => native)
    bytes += await _line(
      renderer,
      generator,
      item.name,
      style: bodyStyle,
      padding: EdgeInsets.zero,
    );

    // Line 2: numbers only => always native text (no image)
    bytes += await _row(renderer, generator, [
      _Cell("  ${item.quantity} x ${formatAmount(item.price)}", flex: 7),
      _Cell(
        formatAmount(item.price * item.quantity),
        flex: 5,
        align: TextAlign.right,
      ),
    ], style: bodyStyle);
  }

  bytes += _divider(generator);

  // Financial breakdown
  bytes += await _totalRow(
    renderer,
    generator,
    boldBodyStyle,
    ReceiptScreenLocale.receiptSubtotal.getString(context),
    formatAmount(voucher.subTotal),
    bold: true,
  );

  if (voucher.tax > 0) {
    bytes += await _totalRow(
      renderer,
      generator,
      bodyStyle,
      ReceiptScreenLocale.receiptTax.getString(context),
      formatAmount(voucher.tax),
    );
  }
  if (voucher.deliveryFee > 0) {
    bytes += await _totalRow(
      renderer,
      generator,
      bodyStyle,
      ReceiptScreenLocale.receiptDeliveryFee.getString(context),
      formatAmount(voucher.deliveryFee),
    );
  }
  if (voucher.discountAmount > 0) {
    bytes += await _totalRow(
      renderer,
      generator,
      bodyStyle,
      ReceiptScreenLocale.receiptDiscount.getString(context),
      "-${formatAmount(voucher.discountAmount)}",
    );
  }
  if (voucher.discountPercent > 0) {
    bytes += await _totalRow(
      renderer,
      generator,
      bodyStyle,
      ReceiptScreenLocale.receiptDiscount.getString(context),
      "-${formatAmount(voucher.discountPercent)}%",
    );
  }
  if (voucher.packagingFee != null && voucher.packagingFee! > 0) {
    bytes += await _totalRow(
      renderer,
      generator,
      bodyStyle,
      ReceiptScreenLocale.packagingFee.getString(context),
      formatAmount(voucher.packagingFee!),
    );
  }

  bytes += _divider(generator, thick: true);

  // Grand total
  bytes += await _totalRow(
    renderer,
    generator,
    largeTotalStyle,
    ReceiptScreenLocale.receiptTotal.getString(context),
    formatAmount(voucher.total),
    bold: true,
  );

  bytes += _divider(generator);

  // Paid status
  bytes += await _totalRow(
    renderer,
    generator,
    bodyStyle,
    ReceiptScreenLocale.receiptPaidAmount.getString(context),
    formatAmount(voucher.totalPaymentAmount),
  );

  if (voucher.remainingPaymentAmount > 0) {
    bytes += await _totalRow(
      renderer,
      generator,
      boldBodyStyle,
      ReceiptScreenLocale.receiptRemainingAmount.getString(context),
      formatAmount(voucher.remainingPaymentAmount),
      bold: true,
    );
  }

  // Note
  if ((voucher.note ?? '').isNotEmpty) {
    bytes += _divider(generator);
    bytes += await _line(
      renderer,
      generator,
      voucher.note!,
      style: bodyStyle,
      padding: cellPadding,
    );
  }

  bytes += _divider(generator);

  bytes += await _line(
    renderer,
    generator,
    VoucherScreenLocale.thankYouMessage.getString(context),
    align: TextAlign.center,
    style: boldBodyStyle,
    padding: cellPadding,
    bold: true,
  );

  bytes += generator.feed(3);
  bytes += generator.cut();

  debugPrint('receipt bytes: ${bytes.length}');
  return bytes;
}
