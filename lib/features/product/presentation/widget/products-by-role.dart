import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/bar-code.dart';
import 'package:pos/features/product/presentation/provider/edit-item.dart';
import 'package:pos/features/product/presentation/widget/product-image-with-remove.dart';
import 'package:pos/features/product/presentation/widget/product-row.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/models/product.dart';
import 'package:pos/utils/extension.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
      imageUrl != widget.product.photoUrl;

  void _onAnyFieldChanged(int id) {
    final editingId = ref.read(editingProductIdProvider);
    if (editingId == null) {
      ref.read(editingProductIdProvider.notifier).startEdit(id);
    }
  }

  Future<void> scanBarCode(int id) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (result != null) {
      _barcodeController.text = result;
      _onAnyFieldChanged(id);
    }
  }

  void _save() async {
    final productPayload = {
      "name": _nameController.text,
      "code": _codeController.text,
      "barcode": _barcodeController.text,
      "price": double.parse(_priceController.text),
      "costPrice": double.parse(_costPriceController.text),
      "stock": int.parse(_stockController.text),
      "minStock": int.parse(_minStockController.text),
      "isActive": active,
    };

    FormData formData = FormData.fromMap(productPayload);

    debugPrint("🟢 Product Payload => $productPayload");
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
    debugPrint("🟢 Product Payload => $formData");
    final success = await ref
        .read(productProvider.notifier)
        .editProductById(widget.product.id, formData);
    if (success) {
      ShowToast(
        context,
        description: Text(
          ProductScreenLocale.productEditSaved.getString(context),
        ),
      );
      ref.read(editingProductIdProvider.notifier).clearEdit();
    }
    return;
  }

  void _cancel() {
    _resetDraft();

    ref.read(editingProductIdProvider.notifier).clearEdit();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final editingId = ref.watch(editingProductIdProvider);
    final isLockedByOther = editingId != null && editingId != product.id;
    final isThisEditing = editingId == product.id;
    // print("imageUrl is 📈 $imageUrl");
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
                        readOnly: isLockedByOther,
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 5,
                        ),
                        decoration: const ShadDecoration(
                          shape: BoxShape.rectangle,
                        ),
                        onChanged: (val) {
                          _onAnyFieldChanged(product.id);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('code-$_resetVersion'),
                  controller: _codeController,
                  title: ProductScreenLocale.productCode.getString(context),
                  //text: product.code,
                  readOnly: isLockedByOther,
                  onChanged: (val) {
                    _onAnyFieldChanged(product.id);
                  },
                ),
                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('barcode-$_resetVersion'),
                  controller: _barcodeController,
                  title: ProductScreenLocale.barcode.getString(context),
                  // text: product.barcode ?? "-",
                  readOnly: isLockedByOther,
                  isBarcode: true,
                  onChanged: (val) {
                    _onAnyFieldChanged(product.id);
                  },
                  onPressed: () => scanBarCode(product.id),
                ),
                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('price-$_resetVersion'),
                  controller: _priceController,
                  title: ProductScreenLocale.productPrice.getString(context),
                  //text: product.price.toString(),
                  readOnly: isLockedByOther,
                  onChanged: (val) {
                    _onAnyFieldChanged(product.id);
                  },
                ),
                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('costprice-$_resetVersion'),
                  controller: _costPriceController,
                  title: ProductScreenLocale.productCostPrice.getString(
                    context,
                  ),
                  // text: product.costPrice.toString(),
                  readOnly: isLockedByOther,
                  onChanged: (val) {
                    _onAnyFieldChanged(product.id);
                  },
                ),
                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('stock-$_resetVersion'),
                  controller: _stockController,
                  title: ProductScreenLocale.productStock.getString(context),
                  // text: product.stock.toString(),
                  readOnly: isLockedByOther,
                  onChanged: (val) {
                    _onAnyFieldChanged(product.id);
                  },
                ),
                const SizedBox(height: 10),
                ProductRowByTextField(
                  key: ValueKey('minStock-$_resetVersion'),
                  controller: _minStockController,
                  title: ProductScreenLocale.minStock.getString(context),
                  // text: product.minStock.toString(),
                  readOnly: isLockedByOther,
                  onChanged: (val) {
                    _onAnyFieldChanged(product.id);
                  },
                ),
                const SizedBox(height: 15),

                /// Active Switch
                // ShadSwitchFormField(
                //   label: Text(
                //     ProductScreenLocale.isActive.getString(context),
                //     style: context.bodyStyle,
                //   ),
                //   key: ValueKey(active),
                //   initialValue: active,
                //   onChanged: (value) {
                //     setState(() {
                //       active = value;
                //     });

                //     _onAnyFieldChanged(product.id);
                //   },
                // ),
                if (isThisEditing && _isDirty) ...[
                  Row(
                    children: [
                      IconButton.filled(
                        onPressed: _save,
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
            onUpload: uploadPhoto,
            onRemove: () {
              setState(() {
                imageUrl = null;
                imageFile = null;
              });
              _onAnyFieldChanged(product.id);
            },
          ),
        ],
      ),
    );
  }
}
