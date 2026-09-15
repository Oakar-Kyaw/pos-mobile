import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/account.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/delete-dialog.dart';
import 'package:pos/features/payment-list/presentation/widget/account-form.dart';
import 'package:pos/features/profile/data/model/user.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/payment-data-local.dart';
import 'package:pos/localization/payment-local.dart';
import 'package:pos/models/payment-data.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/formatAmount.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PaymentDataPage extends ConsumerStatefulWidget {
  const PaymentDataPage({super.key});

  @override
  ConsumerState<PaymentDataPage> createState() => _PaymentDataPageState();
}

class _PaymentDataPageState extends ConsumerState<PaymentDataPage> {
  PaymentData? data;

  Future<void> _onRefresh() async {
    await ref.read(paymentDataProvider.notifier).refreshAccounts();

    if (!mounted) return;

    setState(() {
      data = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _buildSectionLabel(context, isDark),
              const SizedBox(height: 12),
              AccountForm(
                existedData: data,
                onSaved: () async {
                  await ref
                      .read(paymentDataProvider.notifier)
                      .refreshAccounts();
                },
              ),
              const SizedBox(height: 25),
              _buildContainer(context, isDark, (value) {
                setState(() {
                  data = value;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _delete(BuildContext context, PaymentData data, bool isDark) {
    showDeleteDialog(
      context,
      title: PaymentScreenLocale.deletePaymentAccountConfirm.getString(context),
      isDark: isDark,
      submit: () async {
        try {
          final result = await ref
              .read(paymentDataProvider.notifier)
              .deleteAccount(data.id);

          if (!mounted) return;

          if (result) {
            ShowToast(
              context,
              description: Text(
                PaymentScreenLocale.deletePaymentSuccess.getString(context),
              ),
            );

            context.pop();

            await ref.read(paymentDataProvider.notifier).refreshAccounts();
          }
        } catch (e) {
          if (!mounted) return;

          ShowToast(
            context,
            description: Text(
              PaymentScreenLocale.deletePaymentFailed.getString(context),
            ),
            isError: true,
          );
        }
      },
    );
  }

  CustomAppBar _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(LucideIcons.arrowLeft),
      ),
      title: DrawerScreenLocale.drawerBankAccount.getString(context),
    );
  }

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

  Widget _buildContainer(
    BuildContext context,
    bool isDark,
    void Function(PaymentData) set,
  ) {
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final user = ref.watch(userStateProvider);

    return ref
        .watch(paymentDataProvider)
        .when(
          data: (accounts) {
            if (accounts.isEmpty) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: Text(
                    PaymentDataLocale.accountNoItems.getString(context),
                    style: TextStyle(color: subColor),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];

                return _AccountCard(
                  user: user!,
                  account: account,
                  isDark: isDark,
                  textColor: textColor,
                  subColor: subColor,
                  onEdit: () => set(account),
                  onDelete: () => _delete(context, account, isDark),
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => SizedBox(
            height: 300,
            child: Center(
              child: Text("Error: $err", style: TextStyle(color: subColor)),
            ),
          ),
        );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.user,
    required this.account,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.onEdit,
    required this.onDelete,
  });

  final PaymentData account;
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : kSurfaceLight,
        borderRadius: BorderRadius.circular(16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.landmark,
                    color: kPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.accountName,
                        style: TextStyle(
                          fontSize: FontSizeConfig.title(context),
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.accountNumber ?? "-",
                        style: TextStyle(
                          fontSize: FontSizeConfig.body(context),
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin(user.role) || isManager(user.role))
                  Row(
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit,
                          color: Colors.green,
                          size: FontSizeConfig.iconSize(context),
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: FontSizeConfig.iconSize(context),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "${PaymentDataLocale.type.getString(context)} - ",
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
                const SizedBox(width: 6),
                Text(
                  account.accountType,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "${PaymentDataLocale.balance.getString(context)} - ",
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
                const SizedBox(width: 6),
                Text(
                  formatAmount(account.balance),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
