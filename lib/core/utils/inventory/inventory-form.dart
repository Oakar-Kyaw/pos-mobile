import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/input.dart';
import 'package:pos/core/utils/inventory/inventory-item-input.dart';
import 'package:pos/models/inventory-item.dart';
import 'package:pos/models/inventory-management.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/inventory-configuration.dart';
import 'package:pos/utils/product-search-field.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:pos/localization/inventory-management-local.dart';
import 'package:pos/utils/app-theme.dart';

class InventoryManagementForm extends ConsumerStatefulWidget {
  final String inventoryType;
  final InventoryManagement?
  inventory; // null == create mode, non-null == edit mode

  const InventoryManagementForm({
    super.key,
    required this.inventoryType,
    this.inventory,
  });

  @override
  ConsumerState<InventoryManagementForm> createState() =>
      _InventoryManagementFormState();
}

class _InventoryManagementFormState
    extends ConsumerState<InventoryManagementForm> {
  final _formKey = GlobalKey<ShadFormState>();
  late final TextEditingController reasonCtrl;
  late final TextEditingController noteCtrl;
  late List<TextEditingController> itemQtyController;
  String? type;
  bool _isSubmitting = false;

  Timer? _debounce;

  List<InventoryItem> items = [];

  bool get _isEditMode => widget.inventory != null;

  @override
  void initState() {
    super.initState();

    final existing = widget.inventory;

    reasonCtrl = TextEditingController(text: existing?.reason ?? '');
    noteCtrl = TextEditingController(text: existing?.note ?? '');
    debugPrint("existing type ${existing?.type}");
    type =
        existing?.type ??
        InventoryActionConfig.getTypeValue(widget.inventoryType);

    // Pre-fill items when editing
    items = existing != null ? List<InventoryItem>.from(existing.items) : [];
    itemQtyController = items
        .map((item) => TextEditingController(text: item.quantity.toString()))
        .toList();
  }

  void _onAddItemList(InventoryItem item) {
    setState(() {
      InventoryItem newItem = InventoryItem(
        inventoryId: item.inventoryId,
        productId: item.productId,
        product: item.product,
        photoUrl: item.photoUrl,
        quantity: 1,
        price: item.price,
        totalAmount: item.totalAmount,
        costPrice: item.costPrice,
        avgCostPrice: item.avgCostPrice,
      );
      items.add(newItem);
      itemQtyController.add(
        TextEditingController(text: newItem.quantity.toString()),
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      itemQtyController[index].dispose();
      itemQtyController.removeAt(index);
      items.removeAt(index);
    });
  }

  void _onProductSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(productProvider.notifier).searchProducts(search: value);
    });
  }

  void _submit(double total) async {
    if (items.isEmpty) {
      ShowToast(
        context,
        description: Text(
          InventoryManagementLocale.inventoryInvalidAmount.getString(context),
        ),
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      "type": type,
      "reason": reasonCtrl.text,
      "note": noteCtrl.text,
      "items": items.map((e) => e.toJson()).toList(),
      'totalAmount': total,
    };

    debugPrint("🟢 Inventory Payload => $payload");

    try {
      final Map<String, dynamic> api;

      if (_isEditMode) {
        api = await ref
            .read(productProvider.notifier)
            .updateInventoryManagement(
              id: widget.inventory!.id!,
              body: payload,
            );
      } else {
        api = await ref
            .read(productProvider.notifier)
            .createInventory(body: payload);
      }

      if (!mounted) return;

      if (api["success"] == true) {
        ShowToast(
          context,
          description: Text(
            InventoryManagementLocale.inventorySuccess.getString(context),
            style: TextStyle(fontSize: FontSizeConfig.title(context)),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ShowToast(
          context,
          description: Text(
            InventoryManagementLocale.inventoryError.getString(context),
            style: TextStyle(fontSize: FontSizeConfig.title(context)),
          ),
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ShowToast(context, description: Text(e.toString()), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    for (final r in itemQtyController) {
      r.dispose();
    }
    _debounce?.cancel();
    reasonCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final labelColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final totalAmounts = items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    debugPrint("Debugging print for tupe $type ${widget.inventoryType}");
    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Select
          Text(
            InventoryManagementLocale.inventoryAddItem.getString(context),
            style: TextStyle(fontWeight: FontWeight.bold, color: labelColor),
          ),

          SizedBox(height: 5),

          ProductItemSearchField<InventoryItem>(
            onSearchChanged: _onProductSearchChanged,
            itemBuilder: (product) => InventoryItem(
              inventoryId: 0,
              productId: product.id,
              product: product,
              quantity: 1,
              photoUrl: product.photoUrl,
              price: product.price,
              costPrice: product.costPrice ?? 0,
              avgCostPrice: product.avgCostPrice,
              totalAmount: product.price * 1,
            ),
            onProductSelected: (item) => _onAddItemList(item),
          ),

          /// Selected Items
          if (items.isEmpty)
            Text("No items selected.", style: TextStyle(color: subColor))
          else
            ...List.generate(items.length, (index) {
              final product = items[index];
              return InventoryItemInput(
                index: index,
                itemName: product.product.name,
                price: product.price,
                controller: itemQtyController[index],
                onQuantityChanged: (v) {
                  final qty = int.tryParse(v) ?? 0;
                  setState(() {
                    items[index] = items[index].copyWith(
                      quantity: qty,
                      totalAmount: items[index].price * qty,
                    );
                  });
                },
                validator: (v) {
                  if (v.isEmpty || v == '0') {
                    return InventoryManagementLocale.inventoryInvalidAmount
                        .getString(context);
                  }
                  return null;
                },
                onRemove: () => _removeItem(index),
              );
            }),

          const SizedBox(height: 20),

          ShadRadioGroup<String>(
            initialValue: type,
            alignment: WrapAlignment.center,
            onChanged: (value) => setState(() => type = value!),
            spacing: 5,
            items: [
              if (widget.inventoryType == 'Damage') ...[
                ShadRadio(label: Text('Expire'), value: 'EXPIRED'),
                SizedBox(height: 10),
                ShadRadio(label: Text('Damage'), value: 'DAMAGED'),
              ] else ...[
                SizedBox(height: 10),
                ShadRadio(label: Text('Request'), value: 'REQUESTED'),
              ],
            ],
          ),

          const SizedBox(height: 20),

          /// Reason
          input(
            context,
            label: InventoryManagementLocale.inventoryReason.getString(context),
            controller: reasonCtrl,
            labelColor: labelColor,
          ),

          const SizedBox(height: 20),

          /// Note
          input(
            context,
            label: InventoryManagementLocale.inventoryNote.getString(context),
            controller: noteCtrl,
            labelColor: labelColor,
            maxLines: 2,
          ),

          const SizedBox(height: 20),

          /// Total
          Row(
            children: [
              Text(
                InventoryManagementLocale.inventoryTotalAmount.getString(
                  context,
                ),
              ),
              const Spacer(),
              Text(
                totalAmounts.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// Submit Button
          SizedBox(
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
                onPressed: _isSubmitting ? null : () => _submit(totalAmounts),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditMode
                            ? InventoryManagementLocale.updateInventory
                                  .getString(context)
                            : InventoryManagementLocale.inventorySubmit
                                  .getString(context),
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
