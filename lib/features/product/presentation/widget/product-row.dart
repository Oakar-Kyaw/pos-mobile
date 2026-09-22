import 'package:flutter/material.dart';
import 'package:pos/core/utils/brand-select.dart';
import 'package:pos/core/utils/categories-select.dart';
import 'package:pos/utils/extension.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProductRow extends StatelessWidget {
  final String title;
  final String text;
  const ProductRow({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "$title - ",
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          TextSpan(
            text: text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class ProductRowByTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool readOnly;
  final bool isBarcode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onPressed;

  const ProductRowByTextField({
    super.key,
    required this.title,
    required this.controller,
    required this.readOnly,
    this.isBarcode = false,
    this.onChanged,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ),

        Expanded(
          flex: 10,
          child: ShadInputFormField(
            controller: controller,
            readOnly: readOnly,
            style: context.bodyStyle?.copyWith(
              fontWeight: FontWeight.bold,
              color: readOnly ? Colors.grey : null,
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 5),

        Expanded(
          flex: 1,
          child: SizedBox(
            child: isBarcode
                ? IconButton(
                    onPressed: onPressed,
                    icon: const Icon(LucideIcons.barcode, size: 28),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class ProductRowByCategorySelect extends StatelessWidget {
  final String title;
  final String? categoryId;
  final ValueChanged<String>? onChanged;

  const ProductRowByCategorySelect({
    super.key,
    required this.title,
    this.categoryId,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ),

        Expanded(
          flex: 10,
          child: CategoriesSelect(
            initialValue: categoryId,
            allCategories: false,
            onChanged: (v) {
              if (v == null) return;
              onChanged?.call(v);
            },
          ),
        ),
      ],
    );
  }
}

class ProductRowByBrandSelect extends StatelessWidget {
  final String title;
  final String? brandId;
  final ValueChanged<String>? onChanged;

  const ProductRowByBrandSelect({
    super.key,
    required this.title,
    this.brandId,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ),

        Expanded(
          flex: 10,
          child: BrandSelect(
            initialValue: brandId,
            allBrands: false,
            onChanged: (v) {
              if (v == null) return;
              onChanged?.call(v);
            },
          ),
        ),
      ],
    );
  }
}
