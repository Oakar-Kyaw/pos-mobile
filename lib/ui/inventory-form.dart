import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/input.dart';
import 'package:pos/models/inventory-item.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/inventory-configuration.dart';
import 'package:pos/utils/product-search-field.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:pos/localization/inventory-management-local.dart';
import 'package:pos/utils/app-theme.dart';

class InventoryManagementForm extends ConsumerStatefulWidget {
  final String inventoryType;

  const InventoryManagementForm({super.key, required this.inventoryType});

  @override
  ConsumerState<InventoryManagementForm> createState() =>
      _InventoryManagementFormState();
}

class _InventoryManagementFormState
    extends ConsumerState<InventoryManagementForm> {
  final _formKey = GlobalKey<ShadFormState>();
  final reasonCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  String? type;

  Timer? _debounce;

  List<InventoryItem> items = [];

  void _onProductSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(productProvider.notifier).searchProducts(search: value);
    });
  }

  void _onItemQuantityChanged(InventoryItem item, int qty) {
    setState(() {
      final index = items.indexWhere(
        (element) => element.productId == item.productId,
      );
      if (index != -1) {
        items[index] = items[index].copyWith(
          quantity: qty,
          totalAmount: item.price * qty,
        );
      }
    });
  }

  void _submit(double total) async {
    final payload = {
      "type": type,
      "reason": reasonCtrl.text,
      "note": noteCtrl.text,
      "items": items.map((e) => e.toJson()).toList(),
      'totalAmount': total,
    };

    debugPrint("🟢 Inventory Payload => $payload");

    final api = await ref
        .read(productProvider.notifier)
        .createInventory(body: payload);

    if (api["success"]) {
      ShowToast(
        context,
        description: Text(
          InventoryManagementLocale.inventorySuccess.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.title(context)),
        ),
      );
    } else {
      ShowToast(
        context,
        description: Text(
          InventoryManagementLocale.inventoryError.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.title(context)),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => type = InventoryActionConfig.getTypeValue(widget.inventoryType),
    );
  }

  @override
  void dispose() {
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
    //print("type is $");
    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Select
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: Text(
              InventoryManagementLocale.inventoryAddItem.getString(context),
              style: TextStyle(fontWeight: FontWeight.bold, color: labelColor),
            ),
          ),

          SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ProductItemSearchField<InventoryItem>(
              onSearchChanged: _onProductSearchChanged,
              itemBuilder: (product) => InventoryItem(
                inventoryId: 0,
                productId: product.id,
                product: product,
                quantity: 1,
                photoUrl: product.photoUrl,
                price: product.price,
                totalAmount: product.price * 1,
              ),
              onProductSelected: (item) => setState(() => items.add(item)),
            ),
          ),

          const SizedBox(height: 15),

          /// Selected Items
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "No items selected.",
                style: TextStyle(color: subColor),
              ),
            )
          else
            ...items.map(
              (item) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: kPrimary.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item.price.toStringAsFixed(2)),
                  trailing: SizedBox(
                    width: 60,
                    child: ShadInputFormField(
                      initialValue: item.quantity.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        final qty = int.tryParse(value);
                        if (qty != null && qty > 0) {
                          _onItemQuantityChanged(item, qty);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ShadRadioGroup<String>(
              initialValue: InventoryActionConfig.getTypeValue(
                widget.inventoryType,
              ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
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
          ),

          const SizedBox(height: 30),

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
                  onPressed: () => _submit(totalAmounts),
                  child: Text(
                    InventoryManagementLocale.inventorySubmit.getString(
                      context,
                    ),
                    style: TextStyle(color: Colors.white),
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
