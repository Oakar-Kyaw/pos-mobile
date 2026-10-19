import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/core/utils/date-select.dart';
import 'package:pos/core/utils/payment-row.dart';
import 'package:pos/core/utils/payment-select.dart';
import 'package:pos/core/utils/supplier-select.dart';
import 'package:pos/features/purchase-history/data/model/purchase-item.dart';
import 'package:pos/features/purchase-history/data/model/purchase-payment.dart';
import 'package:pos/features/purchase-history/presentation/provider/purchase.api.dart';
import 'package:pos/features/purchase-history/presentation/widget/purchase-status-select.dart';
import 'package:pos/features/supplier/presentation/provider/supplier-provider.dart';
import 'package:pos/localization/home-local.dart';
import 'package:pos/localization/purchase-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/models/product.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/customer-product-search-field.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PurchaseCreatePage extends ConsumerStatefulWidget {
  const PurchaseCreatePage({super.key});

  @override
  ConsumerState<PurchaseCreatePage> createState() => _PurchaseCreatePageState();
}

class _PurchaseCreatePageState extends ConsumerState<PurchaseCreatePage> {
  // Refresh လုပ်ရင် key အသစ်ပြောင်းပြီး form တစ်ခုလုံးကို rebuild လုပ်မယ်
  GlobalKey<ShadFormState> _formKey = GlobalKey<ShadFormState>();
  int? supplierId;
  String? status;
  DateTime? orderDate;
  DateTime? receivedDate;
  Timer? _debounce;

  // ── Product search (Home page နဲ့ တူတူ page 1, limit 40) ──
  static const int _searchLimit = 40;
  List<Product> _searchResults = [];
  bool _isSearchLoading = false;
  int _searchSeq = 0; // နောက်ဆုံး request ရဲ့ ရလဒ်ကိုပဲ ယူဖို့

  final TextEditingController searchController = TextEditingController();
  List<PurchaseItem> purchaseItems = [];
  final TextEditingController discountController = TextEditingController();
  final TextEditingController discountPercentController =
      TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController deliveryFeeController = TextEditingController();
  final TextEditingController packagingFeeController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  late List<TextEditingController> qtyControllers;
  late List<TextEditingController> priceControllers;
  late List<TextEditingController> sellingPriceControllers;
  late List<TextEditingController> paymentAmountController;
  List<PurchasePayment> purchasePayment = [];
  double totalPaidAmount = 0.0;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();

    qtyControllers = purchaseItems
        .map((e) => TextEditingController(text: e.quantity.toString()))
        .toList();

    priceControllers = purchaseItems
        .map((e) => TextEditingController(text: e.price.toString()))
        .toList();

    sellingPriceControllers = purchaseItems
        .map((e) => TextEditingController(text: e.sellingPrice.toString()))
        .toList();

    paymentAmountController = purchasePayment
        .map((e) => TextEditingController(text: e.amount.toString()))
        .toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();

    for (final controller in qtyControllers) {
      controller.dispose();
    }

    for (final controller in priceControllers) {
      controller.dispose();
    }

    for (final controller in sellingPriceControllers) {
      controller.dispose();
    }

    for (final p in paymentAmountController) {
      p.dispose();
    }

    discountController.dispose();
    discountPercentController.dispose();
    taxController.dispose();
    deliveryFeeController.dispose();
    packagingFeeController.dispose();
    noteController.dispose();

    super.dispose();
  }

  // ==========================================================
  // PULL TO REFRESH — form တစ်ခုလုံး reset + data ပြန်ယူ
  // ==========================================================
  Future<void> _onRefresh() async {
    _debounce?.cancel();
    _searchSeq++; // ပျံနေတဲ့ search request တွေရဲ့ ရလဒ်ကို ပယ်ပစ်

    // ဟောင်းတဲ့ controller တွေကို frame ပြီးမှ dispose လုပ်မယ်
    // (လက်ရှိ widget တွေက ဆက်သုံးနေသေးလို့ error မတက်အောင်)
    final oldControllers = <TextEditingController>[
      ...qtyControllers,
      ...priceControllers,
      ...sellingPriceControllers,
      ...paymentAmountController,
    ];

    setState(() {
      supplierId = null;
      status = null;
      orderDate = null;
      receivedDate = null;
      totalPaidAmount = 0.0;

      purchaseItems = [];
      purchasePayment = [];
      qtyControllers = [];
      priceControllers = [];
      sellingPriceControllers = [];
      paymentAmountController = [];

      _searchResults = [];
      _isSearchLoading = false;

      searchController.clear();
      discountController.clear();
      discountPercentController.clear();
      taxController.clear();
      deliveryFeeController.clear();
      packagingFeeController.clear();
      noteController.clear();

      // Key အသစ်ပေးလိုက်တော့ SupplierSelect, DateSelect,
      // PurchaseStatusSelect, PaymentSelect တွေပါ အသစ်ပြန်ဖြစ်မယ်
      _formKey = GlobalKey<ShadFormState>();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in oldControllers) {
        c.dispose();
      }
    });

    // Supplier list ကို cache ဖျက်ပြီး ပြန်ယူခိုင်းမယ်
    ref.invalidate(supplierProvider);
  }

  // ==========================================================
  // PRODUCT SEARCH
  // getProductLists က Home မှာလိုပဲ List<Product> ပြန်ပေးတာမို့
  // ရလာတဲ့ list ကို ဒီ page ရဲ့ state ထဲ ကိုယ်တိုင်ထည့်ပြီး ပြမယ်
  // ==========================================================
  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _searchProducts(value.trim());
    });
  }

  Future<void> _searchProducts(String query) async {
    final seq = ++_searchSeq;

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
      return;
    }

    setState(() => _isSearchLoading = true);

    try {
      final result = await ref
          .read(productProvider.notifier)
          .getProductLists("1", _searchLimit.toString(), search: query);

      // နောက် request ရောက်သွားပြီဆိုရင် ဒီရလဒ်ကို မသုံးဘူး
      if (!mounted || seq != _searchSeq) return;

      setState(() {
        _searchResults = List<Product>.from(result);
        _isSearchLoading = false;
      });
    } catch (e) {
      debugPrint('Search products error: $e');
      if (!mounted || seq != _searchSeq) return;
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
    }
  }

  void _onSelectSearchResult(Product product) {
    addProduct(product);
    _searchSeq++;
    setState(() {
      searchController.clear();
      _searchResults = [];
      _isSearchLoading = false;
    });
    FocusScope.of(context).unfocus();
  }

  Widget _buildProductSearch(
    Color surfaceColor,
    Color textColor,
    Color subColor,
  ) {
    final hasQuery = searchController.text.trim().isNotEmpty;

    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: (v) {
            setState(() {});
            onSearchChanged(v);
          },
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(color: subColor),
            prefixIcon: Icon(Icons.search, color: subColor),
            suffixIcon: _isSearchLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (hasQuery
                      ? IconButton(
                          icon: Icon(Icons.close, color: subColor),
                          onPressed: () {
                            _searchSeq++;
                            setState(() {
                              searchController.clear();
                              _searchResults = [];
                              _isSearchLoading = false;
                            });
                          },
                        )
                      : null),
            filled: true,
            fillColor: surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: subColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: subColor.withOpacity(0.3)),
            ),
          ),
        ),

        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: subColor.withOpacity(0.3)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _searchResults.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: subColor.withOpacity(0.2)),
              itemBuilder: (context, index) {
                final product = _searchResults[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    product.name,
                    style: TextStyle(color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    product.price.toString(),
                    style: TextStyle(color: subColor),
                  ),
                  trailing: Icon(
                    Icons.add_circle_outline,
                    color: subColor,
                    size: 22,
                  ),
                  onTap: () => _onSelectSearchResult(product),
                );
              },
            ),
          )
        else if (hasQuery && !_isSearchLoading)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              HomeScreenLocale.noItemFound.getString(context),
              style: TextStyle(color: subColor),
            ),
          ),
      ],
    );
  }

  double get totalAmount {
    double total = 0;

    // Calculate item total
    for (int i = 0; i < qtyControllers.length; i++) {
      final qty = int.tryParse(qtyControllers[i].text) ?? 0;
      final price = double.tryParse(priceControllers[i].text) ?? 0;

      total += qty * price;
    }

    // Add tax and delivery fee
    total += double.tryParse(taxController.text) ?? 0;
    total += double.tryParse(deliveryFeeController.text) ?? 0;
    total += double.tryParse(packagingFeeController.text) ?? 0;

    // Fixed discount
    final discount = double.tryParse(discountController.text) ?? 0;

    // Percentage discount
    final discountPercent =
        double.tryParse(discountPercentController.text) ?? 0;

    final percentageDiscount = total * (discountPercent / 100);

    total -= discount;
    total -= percentageDiscount;

    return total < 0 ? 0 : total;
  }

  void createPurchase() async {
    setState(() => _isSubmitting = true);
    try {
      debugPrint("Creating purchase... ${supplierId == null}");
      if (!mounted) return;
      if (supplierId == null) {
        debugPrint("Supplier is required");
        if (mounted) setState(() => _isSubmitting = false);
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseSupplierRequired.getString(context),
            style: TextStyle(color: kRed),
          ),
          borderColor: kRed,
          isError: true,
        );
        return;
      }
      if (purchasePayment.isEmpty) throw AddPurchasePaymentError();

      final purchasePayments = List.generate(
        purchasePayment.length,
        (index) => {
          "paymentDataId": purchasePayment[index].paymentData!.id,
          "amount": double.tryParse(paymentAmountController[index].text) ?? 0,
          "type": purchasePayment[index].type,
        },
      );

      if (status == null) {
        debugPrint("status is required");
        if (mounted) setState(() => _isSubmitting = false);
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseStatusRequired.getString(context),
            style: TextStyle(color: kRed),
          ),
          borderColor: kRed,
          isError: true,
        );
        return;
      }

      if (orderDate == null) {
        debugPrint("Order Date is required");
        if (mounted) setState(() => _isSubmitting = false);
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseOrderDateRequired.getString(context),
            style: TextStyle(color: kRed),
          ),
          borderColor: kRed,
          isError: true,
        );
        return;
      }

      if (status == "Success" && receivedDate == null) {
        debugPrint("Received Date is required");
        if (mounted) setState(() => _isSubmitting = false);
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseReceivedDateRequired.getString(context),
            style: TextStyle(color: kRed),
          ),
          borderColor: kRed,
          isError: true,
        );
        return;
      }

      if (purchaseItems.isEmpty) {
        debugPrint("Purchase Item is required");
        setState(() {
          _isSubmitting = false;
        });
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseItemRequired.getString(context),
            style: TextStyle(color: kRed),
          ),
          borderColor: kRed,
          isError: true,
        );
        return;
      }

      final items = List.generate(
        purchaseItems.length,
        (index) => {
          // "id": purchaseItems[index].id,
          "productId": purchaseItems[index].productId,
          "quantity": int.tryParse(qtyControllers[index].text) ?? 0,
          "price": double.tryParse(priceControllers[index].text) ?? 0,
          "sellingPrice":
              double.tryParse(sellingPriceControllers[index].text) ?? 0,
        },
      );

      final payload = {
        "supplierId": supplierId,
        "orderDate": orderDate?.toIso8601String(),
        "receivedDate": receivedDate?.toIso8601String(),
        "status": status!.toUpperCase(),
        "note": noteController.text,
        "discount": discountController.text.isEmpty
            ? 0
            : discountController.text,
        "discountPercent": discountPercentController.text.isEmpty
            ? 0
            : discountPercentController.text,
        "tax": taxController.text.isEmpty ? 0 : taxController.text,
        "deliveryFee": deliveryFeeController.text.isEmpty
            ? 0
            : deliveryFeeController.text,
        "packagingFee": packagingFeeController.text.isEmpty
            ? 0
            : int.tryParse(packagingFeeController.text) ?? 0,
        "purchaseItems": items,
        'purchasePayment': purchasePayments,
      };

      debugPrint("Payload for purchase: $payload");
      if (mounted) setState(() => _isSubmitting = true);

      // call API here
      final success = await ref
          .read(purchaseProvider.notifier)
          .createPurchase(payload);
      if (success) {
        ShowToast(
          context,
          description: Text(
            PurchaseLocale.purchaseSuccess.getString(context),
            style: TextStyle(color: kGreen),
          ),
          borderColor: kGreen,
        );
        context.pop();
      }
    } on AddPurchasePaymentError {
      setState(() => _isSubmitting = false);
      debugPrint("Pyament 📆 $_isSubmitting");
      ShowToast(
        context,
        isError: true,
        description: Text(
          PurchaseLocale.purchasePaymentRequired.getString(context),
          style: TextStyle(color: kRed),
        ),
        borderColor: kRed,
      );
    } catch (e, stackTrace) {
      debugPrint("Error creating purchase: $e");
      setState(() => _isSubmitting = false);
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void addProduct(Product product) {
    setState(() {
      final tempId = -DateTime.now().microsecondsSinceEpoch;

      final item = PurchaseItem(
        id: tempId,
        product: product,
        productId: product.id,

        purchaseId: product.id,

        quantity: 1,
        price: product.costPrice ?? 0,
        sellingPrice: product.price,
      );

      purchaseItems.add(item);

      qtyControllers.add(TextEditingController(text: '1'));

      priceControllers.add(
        TextEditingController(text: product.costPrice.toString()),
      );

      //selling price controller
      sellingPriceControllers.add(
        TextEditingController(text: product.price.toString()),
      );
    });
  }

  void _addPayment(PaymentData v) {
    setState(() {
      final exists = purchasePayment.any((p) => p.paymentDataId == v.id);
      if (exists) return;

      purchasePayment.add(
        PurchasePayment(
          id: v.id,
          purchaseId: v.id,
          paymentDataId: v.id,
          amount: 0,
          type: v.accountType,
          paymentData: v,
        ),
      );
      paymentAmountController.add(TextEditingController(text: '0'));
    });
  }

  void _removePayment(int index) {
    setState(() {
      paymentAmountController[index].dispose();
      paymentAmountController.removeAt(index);
      purchasePayment.removeAt(index);
    });
  }

  void _onremoveItem(int index) {
    setState(() {
      // Dispose controllers first
      qtyControllers[index].dispose();
      priceControllers[index].dispose();
      sellingPriceControllers[index].dispose();

      // Remove controllers
      qtyControllers.removeAt(index);
      priceControllers.removeAt(index);
      sellingPriceControllers.removeAt(index);
      // Remove purchase item
      purchaseItems.removeAt(index);
    });
  }

  double _calculateTotalPaidAmount() {
    return paymentAmountController.fold<double>(
      0.0,
      (sum, controller) => sum + (double.tryParse(controller.text) ?? 0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        title: Text(
          PurchaseLocale.purchaseDetail.getString(context),
          style: TextStyle(color: textColor),
        ),
        actions: [
          // ခလုတ်နဲ့လည်း refresh လုပ်လို့ရအောင်
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ShadForm(
          key: _formKey,
          child: Column(
            children: [
              ShadCard(
                backgroundColor: surfaceColor,
                child: Column(
                  children: [
                    _infoRowSupplier(
                      PurchaseLocale.purchaseSupplier.getString(context),
                      textColor,
                      subColor,
                      setState,
                    ),

                    _infoRowSelectPurchaseStatus(
                      PurchaseLocale.purchaseStatus.getString(context),
                      textColor,
                      subColor,
                      setState,
                    ),

                    _infoRowSelectDate(
                      PurchaseLocale.purchaseOrderDate.getString(context),
                      textColor,
                      subColor,
                      (value) => setState(() => orderDate = value),
                    ),

                    if (status == "Success")
                      _infoRowSelectDate(
                        PurchaseLocale.purchaseReceivedDate.getString(context),
                        textColor,
                        subColor,
                        (value) => setState(() => receivedDate = value),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  PurchaseLocale.purchaseAddItem.getString(context),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: textColor),
                ),
              ),

              const SizedBox(height: 12),

              CustomProductSearchField<Product>(
                itemBuilder: (product) => product,
                onProductSelected: (p) => addProduct(p as Product),
              ),

              // _buildProductSearch(surfaceColor, textColor, subColor),
              const SizedBox(height: 12),

              ...List.generate(purchaseItems.length, (index) {
                final item = purchaseItems[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShadCard(
                    backgroundColor: surfaceColor,
                    child: Column(
                      children: [
                        // ==========================
                        // PRODUCT NAME + DELETE
                        // ==========================
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.product?.name ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),

                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 25,
                              ),
                              tooltip: 'Delete',
                              onPressed: () => _onremoveItem(index),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ==========================
                        // QUANTITY + PRICE
                        // ==========================
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ShadInputFormField(
                                id: 'qty_$index',
                                controller: qtyControllers[index],
                                keyboardType: TextInputType.number,
                                label: Text(
                                  PurchaseLocale.purchaseQuantity.getString(
                                    context,
                                  ),
                                  style: TextStyle(color: subColor),
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),

                            const SizedBox(width: 8),

                            ///buyprice
                            Expanded(
                              flex: 5,
                              child: ShadInputFormField(
                                id: 'buying_price_$index',
                                controller: priceControllers[index],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                label: Text(
                                  PurchaseLocale.purchaseBuyPrice.getString(
                                    context,
                                  ),
                                  style: TextStyle(color: subColor),
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),

                            const SizedBox(width: 8),

                            ///selling price
                            Expanded(
                              flex: 5,
                              child: ShadInputFormField(
                                id: 'selling_price_$index',
                                controller: sellingPriceControllers[index],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                label: Text(
                                  PurchaseLocale.purchaseSellingPrice.getString(
                                    context,
                                  ),
                                  style: TextStyle(color: subColor),
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              ShadInputFormField(
                id: 'discount',
                controller: discountController,
                keyboardType: TextInputType.number,
                label: Text(
                  PurchaseLocale.purchaseDiscount.getString(context),
                  style: TextStyle(color: subColor),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 16),

              ShadInputFormField(
                id: 'discountPercent',
                controller: discountPercentController,
                keyboardType: TextInputType.number,
                label: Text(
                  PurchaseLocale.purchaseDiscountPercent.getString(context),
                  style: TextStyle(color: subColor),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              ShadInputFormField(
                id: 'tax',
                controller: taxController,
                keyboardType: TextInputType.number,
                label: Text(
                  PurchaseLocale.purchaseTax.getString(context),
                  style: TextStyle(color: subColor),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              ShadInputFormField(
                id: 'deliveryFee',
                controller: deliveryFeeController,
                keyboardType: TextInputType.number,
                label: Text(
                  PurchaseLocale.purchaseDeliveryFee.getString(context),
                  style: TextStyle(color: subColor),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 12),

              ShadInputFormField(
                id: 'packagingFee',
                controller: packagingFeeController,
                keyboardType: TextInputType.number,
                label: Text(
                  PurchaseLocale.purchasePackagingFee.getString(context),
                  style: TextStyle(color: subColor),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PaymentSelect(
                  allPayment: false,
                  onChanged: (PaymentData v) => _addPayment(v),
                ),
              ),

              const SizedBox(height: 12),

              ...List.generate(purchasePayment.length, (index) {
                final payment = purchasePayment[index];
                return PaymentRow(
                  index: index,
                  accountName: payment.paymentData!.accountName,
                  controller: paymentAmountController[index],
                  validator: (v) {
                    if (v.isEmpty || v == '0') {
                      return PurchaseLocale.purchaseInvalidAmount.getString(
                        context,
                      );
                    }
                    return null;
                  },
                  onAmountChanged: (_) {
                    setState(() {
                      totalPaidAmount = _calculateTotalPaidAmount();
                    });
                  },
                  onRemove: () => _removePayment(index),
                );
              }),

              ShadInputFormField(
                id: 'note',
                controller: noteController,
                maxLines: 3,
                label: Text(
                  PurchaseLocale.purchaseNote.getString(context),
                  style: TextStyle(color: subColor),
                ),
              ),

              const SizedBox(height: 20),

              ShadCard(
                backgroundColor: surfaceColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      PurchaseLocale.purchaseTotalAmount.getString(context),
                      style: TextStyle(color: textColor),
                    ),
                    Text(
                      totalAmount.toStringAsFixed(0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              GradientSubmitButton(
                isSubmitting: _isSubmitting,
                onPressed: createPurchase,
                text: PurchaseLocale.purchaseCreate.getString(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRowSupplier(
    String title,
    Color textColor,
    Color subColor,
    setState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(title, style: TextStyle(color: subColor)),
          ),

          Expanded(
            flex: 5,
            child: SupplierSelect(
              allSupplier: false,
              onChanged: (value) {
                print("create purchase item 👨‍🏭 $value");
                if (value == null) return;
                setState(() {
                  supplierId = int.tryParse(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowSelectDate(
    String title,
    Color textColor,
    Color subColor,
    ValueChanged<DateTime> onPicked,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(title, style: TextStyle(color: subColor)),
          ),
          Expanded(
            flex: 5,
            child: DateSelect(
              onChanged: (value) {
                if (value == null) return;
                onPicked(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowSelectPurchaseStatus(
    String title,
    Color textColor,
    Color subColor,
    setState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(title, style: TextStyle(color: subColor)),
          ),

          Expanded(
            flex: 5,
            child: PurchaseStatusSelect(
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  status = statusLabel(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
