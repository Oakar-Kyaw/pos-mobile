import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/category.api.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/bar-code.dart';
import 'package:pos/models/category.dart';
import 'package:pos/utils/app-theme.dart';
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
      type: FileType.image,
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
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final labelColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final barcodeBg = isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFF3F4F6);
    final scanIconColor = kPrimary;

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
            labelColor: labelColor,
          ),

          _gap(),

          /// Category
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: _label(
              context,
              CategoryScreenLocale.categoryName,
              labelColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  setState(() => categoryId = value?.id);
                },
              ),
              error: (error, stackTrace) => const SizedBox(),
              loading: () => const Center(
                child: SizedBox(
                  height: 8,
                  width: 8,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),

          _gap(),

          /// Product Code
          _input(
            context,
            label: ProductScreenLocale.productCode,
            placeholder: ProductScreenLocale.productCodePlaceholder,
            controller: codeCtrl,
            labelColor: labelColor,
          ),

          _gap(),

          /// Barcode
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: _label(context, ProductScreenLocale.barcode, labelColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: barcodeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPrimary.withOpacity(0.2), width: 1),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => scanBarCode(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimary, kSecondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.scanBarcode,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      barcodeCtrl.text.isEmpty
                          ? 'Tap to scan barcode'
                          : barcodeCtrl.text,
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: barcodeCtrl.text.isEmpty ? subColor : labelColor,
                        fontWeight: barcodeCtrl.text.isEmpty
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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
            labelColor: labelColor,
          ),

          _gap(),

          /// Photo
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: _label(context, ProductScreenLocale.photoUrl, labelColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: imageFile != null
                ? Stack(
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
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => imageFile = null),
                          child: Container(
                            decoration: const BoxDecoration(
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
                  )
                : GestureDetector(
                    onTap: () => uploadPhoto(),
                    child: DottedBorder(
                      options: RectDottedBorderOptions(
                        color: kPrimary.withOpacity(0.4),
                        dashPattern: const [6, 4],
                        strokeWidth: 1.5,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.imagePlus,
                                size: 26,
                                color: kPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to upload photo',
                              style: TextStyle(
                                color: subColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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
            labelColor: labelColor,
          ),

          _gap(),

          /// Cost Price
          _input(
            context,
            label: ProductScreenLocale.productCostPrice,
            placeholder: ProductScreenLocale.productCostPricePlaceholder,
            controller: costPriceCtrl,
            keyboardType: TextInputType.number,
            labelColor: labelColor,
          ),

          _gap(),

          /// Stock
          _input(
            context,
            label: ProductScreenLocale.productStock,
            placeholder: ProductScreenLocale.productStockPlaceholder,
            controller: stockCtrl,
            keyboardType: TextInputType.number,
            labelColor: labelColor,
          ),

          _gap(),

          /// Min Stock
          _input(
            context,
            label: ProductScreenLocale.minStock,
            placeholder: ProductScreenLocale.minStockPlaceholder,
            controller: minStockCtrl,
            keyboardType: TextInputType.number,
            labelColor: labelColor,
          ),

          _gap(),

          /// Active Switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ShadSwitchFormField(
              label: Text(
                ProductScreenLocale.isActive.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  fontWeight: FontWeight.bold,
                  color: labelColor,
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
            child: SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimary, kSecondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ShadButton(
                  backgroundColor: Colors.transparent,
                  onPressed: _submit,
                  child: Text(
                    ProductScreenLocale.addProduct.getString(context),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gap({double height = 20}) => SizedBox(height: height);

  Widget _label(BuildContext context, String key, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        key.getString(context),
        style: TextStyle(
          fontSize: FontSizeConfig.body(context),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _input(
    BuildContext context, {
    required dynamic label,
    required String placeholder,
    required TextEditingController controller,
    required Color labelColor,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ShadInputFormField(
        controller: controller,
        label: _label(context, label, labelColor),
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
