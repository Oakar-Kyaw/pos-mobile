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
import 'package:pos/core/widgets/input.dart';
import 'package:pos/models/category.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/shad-toaster.dart';
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
  bool isLoading = false;
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

  void _clearForm() {
    nameCtrl.clear();
    codeCtrl.clear();
    barcodeCtrl.clear();
    descriptionCtrl.clear();
    photoUrlCtrl.clear();
    priceCtrl.clear();
    costPriceCtrl.clear();
    stockCtrl.text = '0';
    minStockCtrl.clear();
    setState(() {
      imageFile = null;
      categoryId = null;
      barCodeString = null;
    });
  }

  void _submit() async {
    if (isLoading) return;

    if (nameCtrl.text.trim().isEmpty ||
        codeCtrl.text.trim().isEmpty ||
        priceCtrl.text.trim().isEmpty ||
        stockCtrl.text.trim().isEmpty) {
      ShadToaster.of(context).show(
        const ShadToast.destructive(
          title: Text('Validation Error'),
          description: Text('Please fill in all required fields.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final productPayload = {
        "name": nameCtrl.text.trim(),
        "code": codeCtrl.text.trim(),
        "barcode": barCodeString,
        "description": descriptionCtrl.text.trim(),
        "price": double.tryParse(priceCtrl.text) ?? 0,
        "costPrice": costPriceCtrl.text.isEmpty
            ? null
            : double.tryParse(costPriceCtrl.text),
        "stock": int.tryParse(stockCtrl.text) ?? 0,
        "minStock": minStockCtrl.text.isEmpty
            ? null
            : int.tryParse(minStockCtrl.text),
        "memberSellingPrice": 0,
        "vipSellingPrice": 0,
        "vvipSellingPrice": 0,
        "isActive": isActive,
        if (categoryId != null) "categoryId": categoryId,
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

      await ref.read(productProvider.notifier).postProduct(formData);

      if (mounted) {
        ShowToast(
          context,
          description: Text(
            ProductScreenLocale.success.getString(context),
            style: TextStyle(color: kGreen),
          ),
        );
        _clearForm();
      }
    } on DioException catch (e) {
      String message = "Something went wrong";
      if (e.toString().contains(ProductScreenLocale.codeAlreadyExist)) {
        message = ProductScreenLocale.codeAlreadyExist.getString(context);
      }
      if (mounted) {
        ShowToast(
          context,
          isError: true,
          description: Text(message, style: TextStyle(color: kRed)),
        );
      }
    } catch (e) {
      if (mounted) {
        ShowToast(
          context,
          isError: true,
          description: Text(
            ProductScreenLocale.error.getString(context),
            style: TextStyle(color: kRed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final labelColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final barcodeBg = isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFF3F4F6);

    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Name
          customInput(
            context,
            label: ProductScreenLocale.productName,
            placeholder: ProductScreenLocale.productNamePlaceholder,
            controller: nameCtrl,
            labelColor: labelColor,
          ),

          customGap(),

          /// Category
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: customLabel(
              context,
              CategoryScreenLocale.categoryName,
              labelColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: cateAsync.when(
              data: (data) => SizedBox(
                width: double.infinity,
                child: ShadSelect<Category>(
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
              ),

              error: (error, stackTrace) => const SizedBox(),
              loading: () => const Center(
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),

          customGap(),

          /// Product Code
          customInput(
            context,
            label: ProductScreenLocale.productCode,
            placeholder: ProductScreenLocale.productCodePlaceholder,
            controller: codeCtrl,
            labelColor: labelColor,
          ),

          customGap(),

          /// Barcode
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: customLabel(
              context,
              ProductScreenLocale.barcode,
              labelColor,
            ),
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

          customGap(),

          /// Photo
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: customLabel(
              context,
              ProductScreenLocale.photoUrl,
              labelColor,
            ),
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

          customGap(),

          /// Price
          customInput(
            context,
            label: ProductScreenLocale.productPrice,
            placeholder: ProductScreenLocale.productPricePlaceholder,
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            labelColor: labelColor,
          ),

          customGap(),

          /// Cost Price
          customInput(
            context,
            label: ProductScreenLocale.productCostPrice,
            placeholder: ProductScreenLocale.productCostPricePlaceholder,
            controller: costPriceCtrl,
            keyboardType: TextInputType.number,
            labelColor: labelColor,
          ),

          customGap(),

          /// Stock
          customInput(
            context,
            label: ProductScreenLocale.productStock,
            placeholder: ProductScreenLocale.productStockPlaceholder,
            controller: stockCtrl,
            keyboardType: TextInputType.number,
            labelColor: labelColor,
          ),

          customGap(),

          /// Min Stock
          customInput(
            context,
            label: ProductScreenLocale.minStock,
            placeholder: ProductScreenLocale.minStockPlaceholder,
            controller: minStockCtrl,
            keyboardType: TextInputType.number,
            labelColor: labelColor,
          ),

          customGap(),

          /// Submit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLoading
                        ? [Colors.grey, Colors.grey.shade400]
                        : [kPrimary, kSecondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ShadButton(
                  backgroundColor: Colors.transparent,
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
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
}
