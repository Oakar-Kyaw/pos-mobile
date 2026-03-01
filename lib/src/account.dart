import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/account.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/payment-data-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/utils/account-form.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/responsive.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PaymentDataPage extends ConsumerStatefulWidget {
  const PaymentDataPage({super.key});

  @override
  ConsumerState<PaymentDataPage> createState() => _PaymentDataPageState();
}

class _PaymentDataPageState extends ConsumerState<PaymentDataPage> {
  final int limit = 20;
  PaymentData? data;
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    //print("acccunt 🥸 ${data?.accountName}");
    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _buildDescriptionBanner(context, isDark),
            const SizedBox(height: 20),
            _buildSectionLabel(context, isDark),
            const SizedBox(height: 12),
            AccountForm(
              existedData: data,
              onSaved: () =>
                  ref.read(paymentDataProvider.notifier).refreshAccounts(),
            ),
            const SizedBox(height: 25),
            _buildTableContainer(context, isDark, (v) {
              print("V ${v.accountName}");
              setState(() {
                data = v;
              });
            }),
          ],
        ),
      ),
    );
  }

  /// ── AppBar ─────────────────────────────────────
  CustomAppBar _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(LucideIcons.arrowLeft),
      ),
      title: DrawerScreenLocale.drawerBankAccount.getString(context),
    );
  }

  /// ── Description Banner ─────────────────────────
  Widget _buildDescriptionBanner(BuildContext context, bool isDark) {
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.landmark, color: kPrimary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              PaymentDataLocale.addAccount.getString(context),
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                color: subColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Section Label ─────────────────────────────
  Widget _buildSectionLabel(BuildContext context, bool isDark) {
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
          PaymentDataLocale.accountForm.getString(context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? kTextDark : kTextLight,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // --- Table -----
  // --- Table with ListView.builder ---
  Widget _buildTableContainer(BuildContext context, bool isDark, set) {
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final rowHoverColor = isDark
        ? kPrimary.withOpacity(0.06)
        : kPrimary.withOpacity(0.04);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        width: double.infinity,
        height: 400,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
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
        child: Column(
          children: [
            // ── Table Header ──────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimary.withOpacity(isDark ? 0.25 : 0.08),
                    kSecondary.withOpacity(isDark ? 0.15 : 0.04),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                border: Border(
                  bottom: BorderSide(color: dividerColor, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (Responsive.isTablet(context) ||
                      Responsive.isDesktop(context))
                    Expanded(
                      flex: 2,
                      child: Text(
                        PaymentDataLocale.name.getString(context),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      PaymentDataLocale.accountNumber.getString(context),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      PaymentDataLocale.type.getString(context),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      PaymentDataLocale.balance.getString(context),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SizedBox(),
                    // Text(
                    //   PaymentDataLocale.accountNo.getString(context),
                    //   style: TextStyle(
                    //     color: textColor,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ),
                ],
              ),
            ),

            // ── ListView.builder Rows ─────────
            Expanded(
              child: ref
                  .watch(paymentDataProvider)
                  .when(
                    data: (accounts) {
                      if (accounts.isEmpty) {
                        return Center(
                          child: Text(
                            PaymentDataLocale.accountNoItems.getString(context),
                            style: TextStyle(color: subColor),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          final isEven = index % 2 == 0;
                          return Container(
                            color: isEven ? Colors.transparent : rowHoverColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                if (Responsive.isTablet(context) ||
                                    Responsive.isDesktop(context))
                                  Expanded(
                                    flex: 2,

                                    child: Text(
                                      account.accountName,
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    account.accountNumber ?? "-",
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    account.accountType,
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    formatAmount(account.balance),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.green,
                                          size: FontSizeConfig.iconSize(
                                            context,
                                          ),
                                        ),

                                        onTap: () {
                                          print("tea");
                                          set.call(account);
                                        },
                                      ),
                                      const SizedBox(width: 14),
                                      GestureDetector(
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: FontSizeConfig.iconSize(
                                            context,
                                          ),
                                        ),

                                        onTap: () {
                                          //debugPrint("Delete ${cate.title}");
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Text(
                        "Error: $err",
                        style: TextStyle(color: subColor),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
