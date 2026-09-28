import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart' as esc;
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/features/printer/domain/entites/printer-state.dart';
import 'package:pos/features/printer/presentation/provider/printer-provider.dart';
import 'package:pos/localization/printer-local.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/models/product.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:printing/printing.dart';
import 'package:image/image.dart' as img;
import 'package:shadcn_ui/shadcn_ui.dart';

class GenerateBarcodeDialog extends ConsumerStatefulWidget {
  final Product product;
  final VoidCallback onSaved;

  const GenerateBarcodeDialog({required this.product, required this.onSaved});

  @override
  ConsumerState<GenerateBarcodeDialog> createState() =>
      _GenerateBarcodeDialogState();
}

class _GenerateBarcodeDialogState extends ConsumerState<GenerateBarcodeDialog> {
  late final TextEditingController _codeController;
  bool _isBusy = false;

  // Preview state — rendered as a PNG (via `printing`'s rasterizer, no
  // extra barcode-widget package needed) and redrawn whenever the code
  // text changes.
  Uint8List? _previewPng;
  bool _isPreviewLoading = false;
  Timer? _previewDebounce;

  @override
  void initState() {
    super.initState();
    // Default suggested code — adjust the prefix/padding to your own
    // SKU convention.
    _codeController = TextEditingController(text: "${widget.product.code}");
    _refreshPreview();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _previewDebounce?.cancel();
    super.dispose();
  }

  String get _code => _codeController.text.trim();

  void _onCodeChanged(String _) {
    setState(() {}); // updates button enabled/disabled state immediately
    _previewDebounce?.cancel();
    _previewDebounce = Timer(
      const Duration(milliseconds: 350),
      _refreshPreview,
    );
  }

  /// Builds a one-page PDF containing just the barcode, then rasterizes
  /// that page to a PNG so it can be shown with a plain Image.memory —
  /// no barcode_widget (or any other extra) package required.
  Future<void> _refreshPreview() async {
    if (_code.isEmpty) {
      setState(() => _previewPng = null);
      return;
    }
    setState(() => _isPreviewLoading = true);

    try {
      final pdfBytes = await _buildBarcodePdf(showLabel: false);

      final pages = Printing.raster(pdfBytes, dpi: 200);
      final page = await pages.first;
      final image = await page.toPng();

      if (!mounted) return;
      setState(() {
        _previewPng = image;
        _isPreviewLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _previewPng = null;
        _isPreviewLoading = false;
      });
    }
  }

  int _resolvePrintWidth(PrinterState state, esc.PaperSize paperSize) {
    // fallback: standard mm58/mm80 default
    return paperSize == esc.PaperSize.mm58 ? 384 : 576;
  }

  /// Shared PDF builder — used both for the on-screen preview raster
  /// and for the real "Office" print job.
  Future<Uint8List> _buildBarcodePdf({required bool showLabel}) async {
    final pdf = pw.Document();
    final labelPageFormat = PdfPageFormat(
      50 * PdfPageFormat.mm,
      30 * PdfPageFormat.mm,
    );
    pdf.addPage(
      pw.Page(
        pageFormat: labelPageFormat,
        margin: const pw.EdgeInsets.all(12),
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (showLabel) ...[
                pw.Text(
                  widget.product.name,
                  style: const pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),
              ],
              pw.Container(
                width: 42 * PdfPageFormat.mm,
                height: 12 * PdfPageFormat.mm,
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: _code,
                  drawText: true,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return pdf.save();
  }

  Future<void> _printOffice() async {
    if (_code.isEmpty) return;
    setState(() => _isBusy = true);
    try {
      final pdfBytes = await _buildBarcodePdf(showLabel: true);
      await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _printReceipt() async {
    if (_code.isEmpty) return;

    final printerState = ref.read(printerProvider);
    final connectedType = printerState.connectedPrinterType;

    if (!printerState.isConnected || connectedType == null) {
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.printerNotConnected.getString(context),
        ),
      );
      return;
    }

    setState(() => _isBusy = true);
    try {
      final paperSizeStr = printerState.connectedPrinter?.paperSize;
      final paperSize = paperSizeStr == '80mm'
          ? esc.PaperSize.mm80
          : esc.PaperSize.mm58;

      final profile = await esc.CapabilityProfile.load();
      final generator = esc.Generator(paperSize, profile);

      // saved printer ရဲ့ actual dot-width — hardcoded 384/576 မဟုတ်တော့ဘူး
      final targetWidth = _resolvePrintWidth(printerState, paperSize);

      List<int> bytes = [];

      final pdfBytes = await _buildBarcodePdf(showLabel: false);
      final pages = Printing.raster(pdfBytes, dpi: 200);
      final page = await pages.first;
      final pngBytes = await page.toPng();
      bytes += generator.text(
        widget.product.name,
        styles: const esc.PosStyles(align: esc.PosAlign.center, bold: true),
      );
      final img.Image? decodedImage = img.decodeImage(pngBytes);
      if (decodedImage != null) {
        final resizedImage = img.copyResize(decodedImage, width: targetWidth);
        bytes += generator.image(resizedImage);
      }

      bytes += generator.text(
        _code,
        styles: const esc.PosStyles(align: esc.PosAlign.center),
      );

      final success = await ref
          .read(printerProvider.notifier)
          .printTest(connectedType, bytes);

      if (!mounted) return;
      ShowToast(
        context,
        isError: !success,
        description: Text(
          success
              ? PrinterScreenLocale.printerSaveSuccess.getString(context)
              : PrinterScreenLocale.printerSomethingWentWrong.getString(
                  context,
                ),
        ),
      );
    } catch (e) {
      ShowToast(
        context,
        isError: true,
        action: Icon(
          LucideIcons.x,
          color: Colors.red,
          size: FontSizeConfig.iconSize(context),
        ),
        description: Text(
          PrinterScreenLocale.printerSomethingWentWrong.getString(context),
          style: const TextStyle(color: Colors.red),
        ),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _saveToProduct() async {
    if (_code.isEmpty) return;
    setState(() => _isBusy = true);
    try {
      await ref
          .read(productProvider.notifier)
          .assignBarcodeToProduct(productId: widget.product.id, barcode: _code);
      if (!mounted) return;
      widget.onSaved();
      Navigator.of(context).pop();
      ShowToast(
        context,
        description: Text(
          ProductScreenLocale.productUpdated.getString(context),
          style: TextStyle(color: kGreen),
        ),
      );
    } catch (e) {
      // print("Failed to create company: ${e.toString()}");

      if (!mounted) return;

      if (e.toString().contains('Barcode already exists')) {
        ShowToast(
          context,
          isError: true,
          action: Icon(
            LucideIcons.x,
            color: Colors.red,
            size: FontSizeConfig.iconSize(context),
          ),
          description: Text(
            ProductScreenLocale.barcodeAlreadyExist.getString(context),
            style: const TextStyle(color: Colors.red),
          ),
        );
      } else {
        ShowToast(
          context,
          isError: true,
          action: Icon(
            LucideIcons.x,
            color: Colors.red,
            size: FontSizeConfig.iconSize(context),
          ),
          description: Text(
            PrinterScreenLocale.printerSomethingWentWrong.getString(context),
            style: const TextStyle(color: Colors.red),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codeController,
              onChanged: _onCodeChanged,
              decoration: const InputDecoration(
                labelText: 'Barcode value',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Preview: a rasterized PNG of the same pw.BarcodeWidget used
            // for the real print job -- no extra package, and what you
            // see here is pixel-identical to what prints.
            Container(
              height: 110,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _code.isEmpty
                    ? Text(
                        'Enter a value above',
                        style: TextStyle(color: Colors.grey.shade500),
                      )
                    : _isPreviewLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _previewPng != null
                    ? Image.memory(_previewPng!, fit: BoxFit.contain)
                    : Text(
                        'Preview unavailable',
                        style: TextStyle(color: Colors.red.shade300),
                      ),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _isBusy || _code.isEmpty ? null : _printOffice,
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Office'),
            ),
            OutlinedButton.icon(
              onPressed: _isBusy || _code.isEmpty ? null : _printReceipt,
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Receipt'),
            ),
            FilledButton.icon(
              onPressed: _isBusy || _code.isEmpty ? null : _saveToProduct,
              icon: _isBusy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save, size: 18),
              label: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
