// features/product/presentation/widget/products-by-role.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/bar-code.dart';
import 'package:pos/features/product/presentation/provider/edit-product.provider.dart';
import 'package:pos/features/product/presentation/widget/product-image-with-remove.dart';
import 'package:pos/features/product/presentation/widget/product-row.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/models/product.dart';
import 'package:pos/utils/extension.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

// ==========================================================
// POS / SALE ROLE — read-only card
// ==========================================================

class ProductListByPosAndSale extends StatelessWidget {
  const ProductListByPosAndSale({
    super.key,
    required this.product,
    required this.containerDecoration,
  });

  final Product product;
  final BoxDecoration containerDecoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: containerDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: context.titleStyle,
                ),
                ProductRow(
                  title: "${ProductScreenLocale.barcode.getString(context)}:",
                  text: product.barcode ?? "-",
                ),
                ProductRow(
                  title:
                      "${ProductScreenLocale.productPrice.getString(context)}:",
                  text: product.price.toString(),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ProductRow(
                        title:
                            "${ProductScreenLocale.productStock.getString(context)}:",
                        text: product.stock.toString(),
                      ),
                    ),
                    Expanded(
                      child: ProductRow(
                        title:
                            "${ProductScreenLocale.minStock.getString(context)}:",
                        text: product.minStock.toString(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: product.photoUrl ?? "",
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(width: 56, height: 56, color: Colors.grey.shade200),
              errorWidget: (context, url, error) => Container(
                width: 56,
                height: 56,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported_outlined, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// ADMIN / MANAGER ROLE — editable card
// ==========================================================

class ProductListByAdminAndManager extends ConsumerStatefulWidget {
  const ProductListByAdminAndManager({
    super.key,
    required this.product,
    required this.containerDecoration,
  });

  final Product product;
  final BoxDecoration containerDecoration;

  @override
  ConsumerState<ProductListByAdminAndManager> createState() =>
      _ProductListByAdminAndManagerState();
}

class _ProductListByAdminAndManagerState
    extends ConsumerState<ProductListByAdminAndManager> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _priceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  bool active = false;
  String? imageUrl;

  final _resetVersion = 0;
  File? imageFile;

  // ======================================================
  // INIT
  // ======================================================

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _codeController = TextEditingController(text: widget.product.code);
    _barcodeController = TextEditingController(
      text: widget.product.barcode ?? "",
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _costPriceController = TextEditingController(
      text: widget.product.costPrice.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _minStockController = TextEditingController(
      text: widget.product.minStock.toString(),
    );

    active = widget.product.isActive;
    imageUrl = widget.product.photoUrl;
  }

  @override
  void didUpdateWidget(covariant ProductListByAdminAndManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product != widget.product) {
      _resetDraft();
    }
  }

  void uploadPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        imageFile = File(result.files.single.path!);
      });
    }
  }

  void _resetDraft() {
    setState(() {
      _nameController.text = widget.product.name;
      _codeController.text = widget.product.code;
      _barcodeController.text = widget.product.barcode ?? "";
      _priceController.text = widget.product.price.toString();
      _costPriceController.text = widget.product.costPrice.toString();
      _stockController.text = widget.product.stock.toString();
      _minStockController.text = widget.product.minStock.toString();

      active = widget.product.isActive;
      imageUrl = widget.product.photoUrl;
      imageFile = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _nameController.text != widget.product.name ||
      _codeController.text != widget.product.code ||
      _barcodeController.text != (widget.product.barcode ?? "") ||
      _priceController.text != widget.product.price.toString() ||
      _costPriceController.text != widget.product.costPrice.toString() ||
      _stockController.text != widget.product.stock.toString() ||
      _minStockController.text != widget.product.minStock.toString() ||
      active != widget.product.isActive ||
      imageUrl != widget.product.photoUrl ||
      imageUrl != widget.product.photoUrl ||
      imageFile != null;

  // ======================================================
  // START EDIT (Edit icon နှိပ်မှသာ ခေါ်မယ်)
  // ======================================================

  void _startEditing() {
    ref.read(editingProductIdProvider.notifier).startEdit(widget.product.id);
  }

  Future<void> scanBarCode(int id) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (result != null) {
      setState(() {
        _barcodeController.text = result;
      });
    }
  }

  // ======================================================
  // SAVE
  // ======================================================

  void _save() async {
    final productPayload = {
      "name": _nameController.text,
      "code": _codeController.text,
      "barcode": _barcodeController.text,
      "price": double.parse(_priceController.text),
      "costPrice": double.parse(_costPriceController.text),
      "stock": int.parse(_stockController.text),
      "minStock": int.parse(_minStockController.text),
      "memberSellingPrice": 0,
      "vipSellingPrice": 0,
      "vvipSellingPrice": 0,
      "isActive": active,
    };

    FormData formData = FormData.fromMap(productPayload);

    if (imageFile != null) {
      formData.files.add(
        MapEntry(
          "file",
          await MultipartFile.fromFile(
            imageFile!.path,
            filename: imageFile!.path.split("/").last,
          ),
        ),
      );
    }

    final success = await ref
        .read(productProvider.notifier)
        .editProductById(widget.product.id, formData);

    if (success) {
      if (!mounted) return;
      ShowToast(
        context,
        description: Text(
          ProductScreenLocale.productEditSaved.getString(context),
        ),
      );
      ref.read(editingProductIdProvider.notifier).clearEdit();
    }
  }

  // ======================================================
  // CANCEL
  // ======================================================

  void _cancel() {
    _resetDraft();
    ref.read(editingProductIdProvider.notifier).clearEdit();
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final editingId = ref.watch(editingProductIdProvider);
    final isLockedByOther = editingId != null && editingId != product.id;
    final isThisEditing = editingId == product.id;

    // 👇 Edit icon မနှိပ်ရင် field တွေ ရေးလို့မရအောင်
    final fieldsReadOnly = !isThisEditing;

    return Container(
      decoration: widget.containerDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ShadInputFormField(
                        controller: _nameController,
                        readOnly: fieldsReadOnly,
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 5,
                        ),
                        decoration: const ShadDecoration(
                          shape: BoxShape.rectangle,
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // ==========================================
                    // EDIT ICON — Customer management page ရဲ့ pattern
                    // ==========================================
                    if (!isThisEditing)
                      IconButton(
                        onPressed: isLockedByOther ? null : _startEditing,
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: "Edit",
                      ),
                  ],
                ),

                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('code-$_resetVersion'),
                  controller: _codeController,
                  title: ProductScreenLocale.productCode.getString(context),
                  readOnly: fieldsReadOnly,
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('barcode-$_resetVersion'),
                  controller: _barcodeController,
                  title: ProductScreenLocale.barcode.getString(context),
                  readOnly: fieldsReadOnly,
                  isBarcode: true,
                  onChanged: (val) => setState(() {}),
                  onPressed: fieldsReadOnly
                      ? null
                      : () => scanBarCode(product.id),
                ),
                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('price-$_resetVersion'),
                  controller: _priceController,
                  title: ProductScreenLocale.productPrice.getString(context),
                  readOnly: fieldsReadOnly,
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('costprice-$_resetVersion'),
                  controller: _costPriceController,
                  title: ProductScreenLocale.productCostPrice.getString(
                    context,
                  ),
                  readOnly: fieldsReadOnly,
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('stock-$_resetVersion'),
                  controller: _stockController,
                  title: ProductScreenLocale.productStock.getString(context),
                  readOnly: fieldsReadOnly,
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('minStock-$_resetVersion'),
                  controller: _minStockController,
                  title: ProductScreenLocale.minStock.getString(context),
                  readOnly: fieldsReadOnly,
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 15),

                if (isThisEditing) ...[
                  Row(
                    children: [
                      IconButton.filled(
                        onPressed: _isDirty ? _save : null,
                        icon: const Icon(Icons.check),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        tooltip: "Save",
                      ),
                      const SizedBox(width: 20),
                      IconButton.filled(
                        onPressed: _cancel,
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        tooltip: "Cancel",
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 10),
              ],
            ),
          ),

          const SizedBox(width: 12),
          ProductImageWithRemove(
            photoUrl: imageUrl,
            imageFile: imageFile,
            onUpload: fieldsReadOnly ? () {} : uploadPhoto,
            onRemove: fieldsReadOnly
                ? () {}
                : () {
                    setState(() {
                      imageUrl = null;
                      imageFile = null;
                    });
                  },
          ),
        ],
      ),
    );
  }
}
