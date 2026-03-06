import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/voucher-detail.dart';
import 'package:pos/ui/voucher-list.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';

class VoucherTablePage extends ConsumerStatefulWidget {
  const VoucherTablePage({super.key});

  @override
  ConsumerState<VoucherTablePage> createState() => _VoucherTablePageState();
}

class _VoucherTablePageState extends ConsumerState<VoucherTablePage> {
  String searchQuery = "";
  late final PagingController<int, VoucherDetailModel> _pagingController;
  final int limit = 20;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, VoucherDetailModel>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => ref
          .read(voucherProvider.notifier)
          .getVouchersByUserId(page: pageKey, limit: limit, existDebt: true),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: DrawerScreenLocale.drawerVoucher.getString(context),
      ),
      body: Column(
        children: [
          // ── Description banner ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(isDark ? 0.15 : 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: kPrimary.withOpacity(isDark ? 0.3 : 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Container(
                  //   padding: const EdgeInsets.all(7),
                  //   decoration: BoxDecoration(
                  //     color: kPrimary.withOpacity(0.12),
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: const Icon(
                  //     LucideIcons.ticket,
                  //     color: kPrimary,
                  //     size: 16,
                  //   ),
                  // ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      VoucherScreenLocale.viewAllVouchers.getString(context),
                      style: TextStyle(
                        fontSize: FontSizeConfig.body(context),
                        color: subColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Section label ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
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
                  DrawerScreenLocale.drawerVoucher.getString(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Expanded(child: VoucherList()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
