import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/voucher/data/model/voucher-detail.dart';
import 'package:pos/features/voucher/presentation/pages/calculation.dart';
import 'package:pos/features/voucher/presentation/widgets/calculation-qty-button.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/riverpod/voucher-detail.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProductBarcodeScanPage extends ConsumerStatefulWidget {
  const ProductBarcodeScanPage({super.key});

  @override
  ConsumerState<ProductBarcodeScanPage> createState() =>
      _ProductBarcodeScanPageState();
}

class _ProductBarcodeScanPageState
    extends ConsumerState<ProductBarcodeScanPage> {
  bool _isScanned = false;
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setVoucher();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setVoucher() {
    final existing = ref.read(voucherDetailProvider);
    if (existing != null) return; // ရှိပြီးသားဆို မထိတော့ဘူး

    final voucherDetailModel = VoucherDetailModel(
      id: 0,
      items: [],
      payments: [],
      total: 0,
      type: "draft",
    );
    ref.read(voucherDetailProvider.notifier).setVoucher(voucherDetailModel);
  }

  Future<void> _playBeep() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/scanner-beep.wav'));
    } catch (e) {
      debugPrint("Beep sound error: $e");
    }
  }

  Future<void> _handleScannedCode(String code) async {
    if (_isLoading) return;

    _isLoading = true;

    try {
      final item = await ref
          .read(productProvider.notifier)
          .searchProductsByBarcode(barcode: code);

      if (!mounted) return;

      ref
          .read(voucherDetailProvider.notifier)
          .addItem(
            ItemModel(
              id: item.id,
              productId: item.id,
              product: item,
              name: item.name,
              quantity: 1,
              price: item.price,
              photoUrl: item.photoUrl,
            ),
          );
      HapticFeedback.mediumImpact();
      _playBeep();
    } catch (e) {
      if (!mounted) return;
    } finally {
      _isLoading = false;

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        _isScanned = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Example:
    final voucher = ref.watch(voucherDetailProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final notifier = ref.read(voucherDetailProvider.notifier);
    // final productState = ref.watch(productProvider);

    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: VoucherScreenLocale.title.getString(context),
      ),
      body: Column(
        children: [
          /// Scanner (30%)
          Expanded(
            flex: 3,
            child: AiBarcodeScanner(
              fit: BoxFit.fitHeight,
              controller: _controller,
              galleryButtonType: GalleryButtonType.icon,
              validator: (capture) {
                final code = capture.barcodes.first.rawValue;
                return code != null && code.trim().isNotEmpty;
              },
              overlayConfig: const ScannerOverlayConfig(
                scannerAnimation: ScannerAnimation.fullWidth,
                scannerBorder: ScannerBorder.full,
                successColor: Colors.green,
                errorColor: Colors.red,
              ),
              onDetect: (capture) {
                if (_isScanned || _isLoading) return;

                final code = capture.barcodes.first.rawValue;
                if (code == null || code.trim().isEmpty) return;

                _isScanned = true;

                _handleScannedCode(code);
              },
            ),
          ),

          const Divider(height: 1),
          voucher == null
              ? Expanded(
                  flex: 6,
                  child: Center(
                    child: Text(
                      "No voucher",
                      style: TextStyle(color: textColor),
                    ),
                  ),
                )
              :
                // ── Item List ────────────────────────────────
                Expanded(
                  flex: 6,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                                                          quantity:
                                                              e.quantity - 1,
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
                                                        quantity:
                                                            e.quantity + 1,
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
                          // if (index == voucher.items.length - 1)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 4, bottom: 8),
                          //     child: showAdd
                          //         ? buildSearchField(
                          //             ref,
                          //             searchController,
                          //             isDark,
                          //             textColor,
                          //             subColor,
                          //             setState,
                          //             showAddField,
                          //             onSearchChanged: onSearchChanged,
                          //           )
                          //         : SizedBox(
                          //             width: double.infinity,
                          //             child: DecoratedBox(
                          //               decoration: BoxDecoration(
                          //                 gradient: const LinearGradient(
                          //                   colors: [kPrimary, kSecondary],
                          //                   begin: Alignment.centerLeft,
                          //                   end: Alignment.centerRight,
                          //                 ),
                          //                 borderRadius: BorderRadius.circular(
                          //                   8,
                          //                 ),
                          //               ),
                          //               child: ShadButton(
                          //                 backgroundColor: Colors.transparent,
                          //                 onPressed: () => setState(
                          //                   () => showAddField = true,
                          //                 ),
                          //                 child: Text(
                          //                   VoucherScreenLocale.addItem
                          //                       .getString(context),
                          //                   style: const TextStyle(
                          //                     color: Colors.white,
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //   ),
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
                                        VoucherCalculationDialog(photos: []),
                                  ),
                                  child: Text(
                                    VoucherScreenLocale.voucherCalculate
                                        .getString(context),
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
