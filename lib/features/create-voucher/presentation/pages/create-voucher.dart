import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/create-voucher/presentation/pages/calculation.dart';
import 'package:pos/features/create-voucher/presentation/widgets/calculation-add-product.dart';
import 'package:pos/features/create-voucher/presentation/widgets/calculation-qty-button.dart';
import 'package:pos/features/create-voucher/presentation/widgets/calculation-search-field.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/product.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/bottom-sheet.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreateVoucherPage extends ConsumerStatefulWidget {
  const CreateVoucherPage({super.key});

  @override
  ConsumerState<CreateVoucherPage> createState() => _CreateVoucherPageState();
}

class _CreateVoucherPageState extends ConsumerState<CreateVoucherPage> {
  Timer? _debounce;
  bool showAddField = false;
  final TextEditingController searchController = TextEditingController();
  List<File> _photos = [];

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ref
          .read(productProvider.notifier)
          .getProductLists("10", "10", search: value);
    });
  }

  // Future<void> _takePhoto() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(
  //     source: ImageSource.camera,
  //     maxWidth: 800,
  //     maxHeight: 800,
  //   );
  //   if (pickedFile != null) {
  //     setState(() => _photos.add(File(pickedFile.path)));
  //   }
  // }

  void addPayment() {
    final dialog = PaymentDialog();
    dialog.show(context, ref);
  }

  void handleChangeAmount(String voucherId, String value) {
    final vd = ref.read(voucherDetailProvider.notifier);
    vd.updatePaymentAmount(voucherId, value);
  }

  @override
  Widget build(BuildContext context) {
    final voucher = ref.watch(voucherDetailProvider);
    final notifier = ref.read(voucherDetailProvider.notifier);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    if (voucher == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text("No voucher", style: TextStyle(color: textColor)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: VoucherScreenLocale.title.getString(context),
      ),
      body: Column(
        children: [
          // ── Item List ────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: voucher.items.length,
              itemBuilder: (context, index) {
                final item = voucher.items[index];
                return Column(
                  children: [
                    // ── Item Card ──────────────────────
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? kPrimary.withOpacity(0.08)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: item.photoUrl != null
                                  ? Image.network(
                                      item.photoUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      "assets/default.jpg",
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: FontSizeConfig.body(context),
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "${VoucherScreenLocale.price.getString(context)}: ${item.price} x ${item.quantity}",
                            style: TextStyle(
                              fontSize: FontSizeConfig.body(context),
                              color: subColor,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              QtyButton(
                                icon: Icons.remove,
                                onTap: () {
                                  if (item.quantity > 1) {
                                    notifier.updateVoucher(
                                      items: voucher.items
                                          .map(
                                            (e) => e.id == item.id
                                                ? e.copyWith(
                                                    quantity: e.quantity - 1,
                                                  )
                                                : e,
                                          )
                                          .toList(),
                                    );
                                    notifier.calculate();
                                  } else {
                                    notifier.removeItem(item.id);
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  item.quantity.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              QtyButton(
                                icon: Icons.add,
                                onTap: () {
                                  notifier.updateVoucher(
                                    items: voucher.items
                                        .map(
                                          (e) => e.id == item.id
                                              ? e.copyWith(
                                                  quantity: e.quantity + 1,
                                                )
                                              : e,
                                        )
                                        .toList(),
                                  );
                                  notifier.calculate();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Add Item Button (last item) ────
                    if (index == voucher.items.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: showAddField
                            ? buildSearchField(
                                context,
                                ref,
                                searchController,
                                isDark,
                                textColor,
                                subColor,
                                setState,
                                showAddField,
                                onSearchChanged: onSearchChanged,
                                onAddProduct: (Product product) => addProduct(
                                  ref,
                                  product,
                                  searchController,
                                  setState,
                                  showAddField,
                                ),
                              )
                            : SizedBox(
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
                                    onPressed: () =>
                                        setState(() => showAddField = true),
                                    child: Text(
                                      VoucherScreenLocale.addItem.getString(
                                        context,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    if (index == voucher.items.length - 1)
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
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) =>
                                  VoucherCalculationDialog(photos: _photos),
                            ),
                            child: Text(
                              VoucherScreenLocale.voucherCalculate.getString(
                                context,
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
