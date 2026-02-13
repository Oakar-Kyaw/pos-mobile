import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pos/api/category.api.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/bar-code.dart';
import 'package:pos/models/category.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/localization/category-local.dart';

class ProductForm extends ConsumerStatefulWidget {
  const ProductForm({super.key});

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<ShadFormState>();

  /// Controllers
  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final barcodeCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final photoUrlCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final costPriceCtrl = TextEditingController();
  final stockCtrl = TextEditingController(text: '0');
  final minStockCtrl = TextEditingController();

  bool isActive = true;
  File? imageFile;
  int? categoryId;
  String? barCodeString;

  void uploadPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // simplest option
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        imageFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> scanBarCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (result != null) {
      setState(() {
        barCodeString = result;
        barcodeCtrl.text = result;
      });
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    codeCtrl.dispose();
    barcodeCtrl.dispose();
    descriptionCtrl.dispose();
    photoUrlCtrl.dispose();
    priceCtrl.dispose();
    costPriceCtrl.dispose();
    stockCtrl.dispose();
    minStockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cateAsync = ref.watch(categoryProvider);
    print("barcode is 😁 $barCodeString");
    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Name
          _input(
            context,
            label: ProductScreenLocale.productName,
            placeholder: ProductScreenLocale.productNamePlaceholder,
            controller: nameCtrl,
          ),

          _gap(),

          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: _label(context, CategoryScreenLocale.categoryName),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 5),
            child: cateAsync.when(
              data: (data) => ShadSelect<Category>(
                placeholder: Text(
                  CategoryScreenLocale.selectCategory.getString(context),
                ),
                options: data
                    .map((e) => ShadOption(value: e, child: Text(e.title)))
                    .toList(),
                selectedOptionBuilder: (context, value) => Text(value.title),
                onChanged: (value) {
                  setState(() {
                    categoryId = value?.id; // store selected id
                  });
                },
              ),
              error: (error, stackTrace) => Container(),
              loading: () => Center(
                child: SizedBox(
                  height: 8,
                  width: 8,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          _gap(),
          //Product Code
          _input(
            context,
            label: ProductScreenLocale.productCode,
            placeholder: ProductScreenLocale.productCodePlaceholder,
            controller: codeCtrl,
          ),

          _gap(),

          /// Barcode
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: _label(context, ProductScreenLocale.barcode),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => scanBarCode(),
                  icon: Icon(
                    LucideIcons.scanBarcode,
                    size: 50,
                    color: const Color.fromARGB(255, 192, 191, 191),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  barcodeCtrl.text ?? "",
                  style: TextStyle(fontSize: FontSizeConfig.body(context)),
                ),
              ],
            ),
          ),
          _gap(),

          /// Description
          _input(
            context,
            label: ProductScreenLocale.description,
            placeholder: ProductScreenLocale.descriptionPlaceholder,
            controller: descriptionCtrl,
            maxLines: 3,
          ),

          _gap(),

          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: _label(context, ProductScreenLocale.photoUrl),
          ),

          /// Photo URL
          imageFile != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          imageFile!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),

                      /// Clear button (X)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              imageFile = null; // clear the photo
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DottedBorder(
                    options: RectDottedBorderOptions(
                      dashPattern: [5, 5],
                      strokeWidth: 0.5,
                      padding: EdgeInsets.all(16),
                    ),
                    child: IconButton(
                      onPressed: () => uploadPhoto(),
                      icon: Icon(
                        LucideIcons.plus,
                        size: 30,
                        color: const Color.fromARGB(255, 192, 191, 191),
                      ),
                    ),
                  ),
                ),

          _gap(),

          /// Price
          _input(
            context,
            label: ProductScreenLocale.productPrice,
            placeholder: ProductScreenLocale.productPricePlaceholder,
            controller: priceCtrl,
            keyboardType: TextInputType.number,
          ),

          _gap(),

          /// Cost Price
          _input(
            context,
            label: ProductScreenLocale.productCostPrice,
            placeholder: ProductScreenLocale.productCostPricePlaceholder,
            controller: costPriceCtrl,
            keyboardType: TextInputType.number,
          ),

          _gap(),

          /// Stock
          _input(
            context,
            label: ProductScreenLocale.productStock,
            placeholder: ProductScreenLocale.productStockPlaceholder,
            controller: stockCtrl,
            keyboardType: TextInputType.number,
          ),

          _gap(),

          /// Min Stock
          _input(
            context,
            label: ProductScreenLocale.minStock,
            placeholder: ProductScreenLocale.minStockPlaceholder,
            controller: minStockCtrl,
            keyboardType: TextInputType.number,
          ),

          _gap(),

          /// Active Switch
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
            child: ShadSwitchFormField(
              label: Text(
                ProductScreenLocale.isActive.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              initialValue: true,
              onChanged: (value) => isActive = value,
            ),
          ),

          _gap(),

          /// Submit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ShadButton(
              onPressed: _submit,
              child: Text(ProductScreenLocale.addProduct.getString(context)),
            ),
          ),
        ],
      ),
    );
  }

  /// Submit
  void _submit() async {
    final productPayload = {
      "name": nameCtrl.text,
      "code": codeCtrl.text,
      "barcode": barCodeString,
      "description": descriptionCtrl.text,
      "price": double.parse(priceCtrl.text),
      "costPrice": costPriceCtrl.text.isEmpty
          ? null
          : double.parse(costPriceCtrl.text),
      "stock": int.parse(stockCtrl.text),
      "minStock": minStockCtrl.text.isEmpty
          ? null
          : int.parse(minStockCtrl.text),
      "isActive": isActive,
      "categoryId": categoryId,
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
    final postProduct = await ref
        .read(productProvider.notifier)
        .postProduct(formData);
  }

  /// UI Helpers
  Widget _gap({double height = 20}) => SizedBox(height: height);

  Widget _label(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        key.getString(context),
        style: TextStyle(
          fontSize: FontSizeConfig.body(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _input(
    BuildContext context, {
    required dynamic label,
    required String placeholder,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ShadInputFormField(
        controller: controller,
        label: _label(context, label),
        maxLines: maxLines,
        keyboardType: keyboardType,
        placeholder: Text(
          placeholder.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.body(context)),
        ),
      ),
    );
  }
}
