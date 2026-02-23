import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/payment-in-voucher.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/product.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/bottom-sheet.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';
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
          .getProductByUserId("10", "10", search: value);
    });
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      setState(() => _photos.add(File(pickedFile.path)));
    }
  }

  void addPayment() {
    final dialog = PaymentDialog();
    dialog.show(context, ref);
  }

  void saveVoucher() async {
    final voucher = ref.watch(voucherDetailProvider);
    if (voucher == null) return;
    final saveVoucherApi = await ref
        .read(voucherProvider.notifier)
        .postVoucher(voucher: voucher, files: _photos);
    if (saveVoucherApi["success"]) {
      ShowToast(
        context,
        description: Text(
          VoucherScreenLocale.createdSuccess.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.body(context)),
        ),
        action: Icon(
          LucideIcons.circleCheck,
          color: kGreen,
          size: FontSizeConfig.iconSize(context),
        ),
      );
      context.pushReplacement(AppRoute.receipt, extra: saveVoucherApi["id"]);
    }
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
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);

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
            flex: 5,
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
                            _QtyButton(
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
                            _QtyButton(
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

                    // ── Add Item Button (last item) ────
                    if (index == voucher.items.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: showAddField
                            ? _buildSearchField(isDark, textColor, subColor)
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
                  ],
                );
              },
            ),
          ),

          // ── Divider ──────────────────────────────────
          Divider(height: 1, color: dividerColor),

          // ── Calculation Panel ────────────────────────
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: Column(
                children: [
                  // ── Totals card ────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      children: [
                        _rowTax(
                          VoucherScreenLocale.tax.getString(context),
                          textColor,
                        ),
                        const SizedBox(height: 10),
                        _rowDeliveryFee(
                          PaymentScreenLocale.deliveryFee.getString(context),
                          textColor,
                        ),
                        const SizedBox(height: 10),
                        _row(
                          VoucherScreenLocale.subtotal.getString(context),
                          voucher.subTotal,
                          textColor,
                          subColor,
                        ),
                        Divider(height: 24, color: dividerColor),
                        _row(
                          VoucherScreenLocale.total.getString(context),
                          voucher.total,
                          textColor,
                          kPrimary,
                          highlight: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Section label ──────────────────
                  _sectionLabel(
                    PaymentScreenLocale.paymentTitle.getString(context),
                    textColor,
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Column(
                      children: [
                        const PaymentInVoucherWidget(),
                        const SizedBox(height: 12),
                        // Select payment button
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
                              onPressed: addPayment,
                              child: Text(
                                PaymentScreenLocale.selectPaymentMethod
                                    .getString(context),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Divider(height: 24, color: dividerColor),
                        _row(
                          PaymentScreenLocale.paidAmount.getString(context),
                          voucher.totalPaymentAmount,
                          textColor,
                          kGreen,
                        ),
                        const SizedBox(height: 10),
                        _row(
                          PaymentScreenLocale.paymentRemainingAmount.getString(
                            context,
                          ),
                          voucher.remainingPaymentAmount,
                          textColor,
                          kAmber,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Photo section ──────────────────
                  _sectionLabel(
                    PaymentScreenLocale.paymentPhoto.getString(context),
                    textColor,
                  ),
                  const SizedBox(height: 12),

                  _photos.isNotEmpty
                      ? Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: kPrimary.withOpacity(0.3),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  _photos[0],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _photos = []),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: _takePhoto,
                          child: DottedBorder(
                            options: RectDottedBorderOptions(
                              color: kPrimary.withOpacity(0.4),
                              dashPattern: const [6, 4],
                              strokeWidth: 1.5,
                              padding: const EdgeInsets.all(16),
                            ),
                            child: SizedBox(
                              width: double.infinity,
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
                                      LucideIcons.camera,
                                      size: 26,
                                      color: kPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to take photo',
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

                  const SizedBox(height: 16),

                  // ── Note ──────────────────────────
                  _rowNote(
                    VoucherScreenLocale.note.getString(context),
                    textColor,
                  ),

                  const SizedBox(height: 16),

                  // ── Save button ───────────────────
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
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ShadButton(
                        backgroundColor: Colors.transparent,
                        onPressed: saveVoucher,
                        child: Text(
                          VoucherScreenLocale.save.getString(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ──────────────────────────────
  Widget _sectionLabel(String title, Color textColor) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ── Row helpers ────────────────────────────────
  Widget _row(
    String label,
    double value,
    Color textColor,
    Color valueColor, {
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: highlight
                ? FontSizeConfig.title(context)
                : FontSizeConfig.body(context),
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _rowDeliveryFee(String label, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
        SizedBox(
          width: 80,
          child: ShadInputFormField(
            keyboardType: TextInputType.number,
            initialValue: "0",
            textAlign: TextAlign.right,
            decoration: ShadDecoration(secondaryFocusedBorder: ShadBorder.none),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              final val = double.tryParse(value) ?? 0.0;
              ref
                  .read(voucherDetailProvider.notifier)
                  .updateVoucher(deliveryFee: val);
              ref.read(voucherDetailProvider.notifier).calculate();
            },
          ),
        ),
      ],
    );
  }

  Widget _rowTax(String label, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
        SizedBox(
          width: 80,
          child: ShadInputFormField(
            keyboardType: TextInputType.number,
            initialValue: "0",
            textAlign: TextAlign.right,
            decoration: ShadDecoration(secondaryFocusedBorder: ShadBorder.none),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              final val = double.tryParse(value) ?? 0.0;
              ref.read(voucherDetailProvider.notifier).updateVoucher(tax: val);
              ref.read(voucherDetailProvider.notifier).calculate();
            },
          ),
        ),
      ],
    );
  }

  Widget _rowNote(String label, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
        const SizedBox(width: 50),
        Expanded(
          child: ShadInputFormField(
            decoration: ShadDecoration(secondaryFocusedBorder: ShadBorder.none),
            onChanged: (value) {
              ref
                  .read(voucherDetailProvider.notifier)
                  .updateVoucher(note: value);
            },
          ),
        ),
      ],
    );
  }

  // ── Add product ────────────────────────────────
  void _addProduct(Product product) {
    ref
        .read(voucherDetailProvider.notifier)
        .addItem(
          ItemModel(
            id: product.id,
            name: product.name,
            quantity: 1,
            price: product.price,
            photoUrl: product.photoUrl,
          ),
        );
    searchController.clear();
    setState(() => showAddField = false);
  }

  // ── Search field ───────────────────────────────
  Widget _buildSearchField(bool isDark, Color textColor, Color subColor) {
    return Column(
      children: [
        ShadInputFormField(
          controller: searchController,
          decoration: ShadDecoration(secondaryFocusedBorder: ShadBorder.none),
          placeholder: Text(
            "Search product...",
            style: TextStyle(color: subColor),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 8),
        _buildSuggestions(isDark, textColor, subColor),
      ],
    );
  }

  // ── Suggestions ────────────────────────────────
  Widget _buildSuggestions(bool isDark, Color textColor, Color subColor) {
    final filtered = ref.watch(productProvider).value ?? [];
    if (searchController.text.isEmpty) return const SizedBox();

    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFF3F4F6);

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? kPrimary.withOpacity(0.1)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: dividerColor),
        itemBuilder: (context, index) {
          final product = filtered[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: product.photoUrl != null
                    ? Image.network(product.photoUrl!, fit: BoxFit.cover)
                    : Image.asset("assets/default.jpg", fit: BoxFit.cover),
              ),
            ),
            title: Text(
              product.name,
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "${VoucherScreenLocale.price.getString(context)}: ${product.price}",
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                color: subColor,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.plus, color: kPrimary, size: 16),
            ),
            onTap: () => _addProduct(product),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// Qty Button
// ─────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: kPrimary),
      ),
    );
  }
}
