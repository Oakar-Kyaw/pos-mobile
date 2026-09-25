import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos/core/utils/myanmar-text-to-image.dart';
import 'package:pos/core/utils/voucher/label-text-images.dart';
import 'package:pos/core/utils/voucher/logo-cache.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:printing/printing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OSVoucherService {
  Future<void> printOSVoucher(
    BuildContext buildContext,
    VoucherDetailModel voucher,
  ) async {
    final pdf = pw.Document();
    final label = await LabelTextImages.getImageText(buildContext);

    // Product name
    List<pw.MemoryImage> itemNamesAsImages = await Future.wait(
      voucher.items.map((it) async {
        final imageBytes = await myanmarTextToImage(
          it.name,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        );
        return pw.MemoryImage(imageBytes);
      }),
    );

    const PdfColor primaryBlue = PdfColor.fromInt(0xFF7B99BA);
    const PdfColor textGray = PdfColor.fromInt(0xFF333333);
    const PdfColor lightBg = PdfColor.fromInt(0xFFE8EEF5);

    final pw.Font myanmarFont = await fontFromAssetBundle(
      'assets/fonts/Pyidaungsu-2.5.3_Bold.ttf',
    );

    // Company logo
    pw.ImageProvider? companyLogo;
    final logoBytes = await LogoCache.load(voucher.company?.photoUrl);
    if (logoBytes != null) {
      companyLogo = pw.MemoryImage(logoBytes);
    }

    final hasNote = voucher.note != null && voucher.note!.isNotEmpty;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(fontFallback: [myanmarFont]),
        build: (pw.Context context) {
          return [
            // ===== Header =====
            pw.Container(
              color: primaryBlue,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 30,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        voucher.voucherCode ?? "-",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        DateFormat(
                          "dd MMM yyyy (EEE)",
                        ).format(voucher.createdAt!).toUpperCase(),
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  if (companyLogo != null)
                    pw.Container(
                      width: 56,
                      height: 56,
                      padding: const pw.EdgeInsets.all(4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Image(companyLogo, fit: pw.BoxFit.cover),
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // ===== Customer / Company info =====
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(80),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      _buildInfoRow(
                        label.customer.name,
                        voucher.customer?.name ?? "-",
                        hasBottomLine: false,
                      ),
                      _buildInfoRow(
                        label.customer.phone,
                        voucher.customer?.phone ?? "-",
                        hasBottomLine: false,
                      ),
                      _buildInfoRow(
                        label.customer.address,
                        voucher.customer?.address ?? "-",
                        hasBottomLine: false,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(80),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      _buildInfoRow(
                        label.company.name,
                        voucher.company?.name ?? "-",
                      ),
                      _buildInfoRow(
                        label.company.phone,
                        voucher.company?.phone ?? "-",
                      ),
                      _buildInfoRow(
                        label.company.email,
                        voucher.company?.email ?? "-",
                      ),
                      _buildInfoRow(
                        label.company.address,
                        voucher.company?.address ?? "-",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // ===== Items table =====
            pw.Table(
              border: pw.TableBorder.all(color: textGray, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(40),
                1: const pw.FlexColumnWidth(),
                2: const pw.FixedColumnWidth(60),
                3: const pw.FixedColumnWidth(80),
                4: const pw.FixedColumnWidth(90),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: primaryBlue),
                  children: [
                    _buildTableHeader(label.tableHeader.no),
                    _buildTableHeader(
                      label.tableHeader.product,
                      alignLeft: true,
                    ),
                    _buildTableHeader(label.tableHeader.quantity),
                    _buildTableHeader(label.tableHeader.price),
                    _buildTableHeader(label.tableHeader.total),
                  ],
                ),
                ...voucher.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final it = entry.value;

                  return _buildDataRow(
                    (index + 1).toString(),
                    itemNamesAsImages[index],
                    it.quantity.toString(),
                    it.price.toString(),
                    (it.quantity * it.price).toString(),
                  );
                }),
              ],
            ),

            // ===== Debt/QR (ဘယ်) + Summary (ညာ) =====
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (voucher.debt > 0) ...[
                        pw.SizedBox(height: 10),
                        _buildRowAmount(
                          label.summary.debtAmount,
                          voucher.debt.toString(),
                        ),
                        pw.SizedBox(height: 21),
                      ],
                      pw.Container(
                        width: 90,
                        height: 90,
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: 'https://flutter.dev',
                          color: PdfColors.black,
                          backgroundColor: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Container(
                  width: 230,
                  child: pw.Table(
                    border: pw.TableBorder.all(color: textGray, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(),
                      1: const pw.FixedColumnWidth(90),
                    },
                    children: [
                      _buildSummaryRow(
                        label.summary.subTotal,
                        voucher.subTotal.toString(),
                        primaryBlue,
                        PdfColors.white,
                      ),
                      _buildSummaryRow(
                        label.summary.tax,
                        voucher.tax.toString(),
                        primaryBlue,
                        PdfColors.white,
                      ),
                      _buildSummaryRow(
                        label.summary.discount,
                        voucher.discountAmount.toString(),
                        primaryBlue,
                        PdfColors.white,
                      ),
                      _buildSummaryRow(
                        label.summary.discountPercent,
                        voucher.discountPercent.toString(),
                        primaryBlue,
                        PdfColors.white,
                      ),
                      _buildSummaryRow(
                        label.summary.packagingFee,
                        voucher.packagingFee.toString(),
                        lightBg,
                        textGray,
                        isBoldTotal: true,
                      ),
                      _buildSummaryRow(
                        label.summary.total,
                        voucher.total.toString(),
                        lightBg,
                        textGray,
                        isBoldTotal: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ===== Note (summary အောက်၊ ဘယ်ဘက်) =====
            if (hasNote) ...[
              pw.SizedBox(height: 12),
              _buildRowAmount(label.summary.note, voucher.note!),
            ],

            pw.SizedBox(height: 12),

            // ===== Sale Person (ဘယ်) + Thank you (အလယ်) =====
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Sale Person (ဘယ်)
                pw.Container(
                  width: 180,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        voucher.user?.email ?? "-",
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          fontStyle: pw.FontStyle.italic,
                          color: textGray,
                        ),
                      ),
                      pw.Container(width: 180, height: 0.5, color: textGray),
                      pw.SizedBox(height: 4),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 30),
                        child: pw.Image(label.company.salePerson, height: 18),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                // Thank you (အလယ်)
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Image(label.summary.thankYou, height: 20),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.TableRow _buildInfoRow(
    pw.ImageProvider labelImage,
    String value, {
    bool hasBottomLine = true,
  }) {
    return pw.TableRow(
      decoration: hasBottomLine
          ? const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
              ),
            )
          : const pw.BoxDecoration(),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 3),
          child: pw.Image(labelImage, height: 18),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: pw.Text(" - $value", style: const pw.TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  pw.Widget _buildTableHeader(
    pw.ImageProvider image, {
    bool alignLeft = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Align(
        alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
        child: pw.Image(image, height: 18),
      ),
    );
  }

  pw.TableRow _buildDataRow(
    String no,
    pw.ImageProvider labelImage,
    String qty,
    String price,
    String total,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Center(
            child: pw.Text(no, style: const pw.TextStyle(fontSize: 9)),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 3),
          child: pw.Image(labelImage, height: 18),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Center(
            child: pw.Text(qty, style: const pw.TextStyle(fontSize: 9)),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(price, style: const pw.TextStyle(fontSize: 9)),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(total, style: const pw.TextStyle(fontSize: 9)),
          ),
        ),
      ],
    );
  }

  pw.TableRow _buildSummaryRow(
    pw.ImageProvider labelImage,
    String amount,
    PdfColor bgColor,
    PdfColor textColor, {
    bool isBoldTotal = false,
  }) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bgColor),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 3),
          child: pw.Image(labelImage, height: 18),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              amount,
              style: pw.TextStyle(
                fontSize: 9,
                color: textColor,
                fontWeight: isBoldTotal
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildRowAmount(
    pw.ImageProvider labelImage,
    String value, {
    double labelHeight = 22,
    double fontSize = 18,
  }) {
    return pw.Row(
      children: [
        pw.Image(labelImage, height: labelHeight),
        pw.Text(" - $value", style: pw.TextStyle(fontSize: fontSize)),
      ],
    );
  }
}
