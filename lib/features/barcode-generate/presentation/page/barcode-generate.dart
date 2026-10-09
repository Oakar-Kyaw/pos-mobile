import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/core/database/printer-table-schema.dart';
import 'package:pos/features/barcode-generate/presentation/widget/generate-barcode-dialog.dart';
import 'package:pos/features/printer/data/datasource/printer-local-datasource.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';
import 'package:pos/features/printer/presentation/provider/printer-provider.dart';
import 'package:pos/models/product.dart';
import 'package:pos/utils/button.dart';

class NoBarcodeProductsPage extends ConsumerStatefulWidget {
  const NoBarcodeProductsPage({super.key});

  @override
  ConsumerState<NoBarcodeProductsPage> createState() =>
      _NoBarcodeProductsPageState();
}

class _NoBarcodeProductsPageState extends ConsumerState<NoBarcodeProductsPage> {
  late final PagingController<int, Product> _pagingController;
  List<PrinterTableItem> listOfPrinters = [];

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Product>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(productProvider.notifier)
          .getProductsWithoutBarcode(page: pageKey.toString(), limit: '20'),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSavedPrinters();
    });
  }

  Future<void> _getSavedPrinters() async {
    try {
      final datasource = PrinterLocalDatabaseSource();
      final printers = await datasource.getAll();
      if (printers.isEmpty) return;
      final initial = printers.firstWhere((e) => e.setDefault);

      print("printers are: ${initial} ");
      setState(() {
        listOfPrinters = printers;
      });
      ref
          .read(printerProvider.notifier)
          .connect(
            initial.type.toDomain(),
            Printer(
              name: initial.name,
              address: initial.address,
              vendorId: initial.vendorId,
              productId: initial.productId,
              isConnected: initial.isConnected,
            ),
            // PrinterDevice(
            //   id: initialPrinter.id.toString(),
            //   name: initialPrinter.name,
            //   type: initialPrinter.type.toDomain(),
            //   paperSize: initialPrinter.paperSize,
            //   address: initialPrinter.address,
            //   setDefault: initialPrinter.setDefault,
            //   isConnected: initialPrinter.isConnected,
            // ),
          );
    } catch (e) {}
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void _openGenerateBarcodeDialog(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => GenerateBarcodeDialog(
        product: product,
        onSaved: _pagingController.refresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products Without Barcode')),
      body: RefreshIndicator(
        onRefresh: () async => _pagingController.refresh(),
        child: PagingListener(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedListView<int, Product>(
                state: state,
                fetchNextPage: fetchNextPage,
                padding: const EdgeInsets.symmetric(vertical: 8),
                builderDelegate: PagedChildBuilderDelegate<Product>(
                  itemBuilder: (context, product, index) => _ProductRow(
                    product: product,
                    onGenerate: () => _openGenerateBarcodeDialog(product),
                  ),
                  firstPageProgressIndicatorBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  newPageProgressIndicatorBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  noItemsFoundIndicatorBuilder: (_) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Every product already has a barcode 🎉'),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onGenerate;

  const _ProductRow({required this.product, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
      ),
      title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: GradientSubmitButton(
        onPressed: onGenerate,
        text: 'Generate',
        width: 120,
      ),
    );
  }
}
