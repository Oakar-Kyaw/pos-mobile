// pages/sale_report_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/income-dashboard.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/delete-dialog.dart';
import 'package:pos/core/utils/confirm-dialog.dart';
import 'package:pos/features/sale-report/data/model/sale-report.dart';
import 'package:pos/features/sale-report/presentation/provider/sale-report.api.dart';
import 'package:pos/features/sale-report/presentation/widget/closing-report-card.dart';
import 'package:pos/features/sale-report/presentation/widget/sale-report-card.dart';
import 'package:pos/features/sale-report/presentation/widget/transfer-card.dart';
import 'package:pos/features/sale-report/presentation/widget/transfer-dialog.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/sale-report-local.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/date-ui.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SaleReportPage extends ConsumerStatefulWidget {
  const SaleReportPage({super.key});

  @override
  ConsumerState createState() => _SaleReportPageState();
}

class _SaleReportPageState extends ConsumerState<SaleReportPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(saleReportProvider.notifier).getOpenClosing(date: selectedDate);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      ref.read(saleReportProvider.notifier).getOpenClosing(date: selectedDate);
      ref.read(incomeProvider.notifier).getIncomesByCompany(date: selectedDate);
    }
  }

  Future<void> _transferSaleAmount(SaleReport saleReport) async {
    final amount = saleReport.closingAmount;

    // final postMessage = await

    if (amount == 0) {
      ShowToast(
        context,
        description: const Text(
          'No closing amount to transfer',
          style: TextStyle(color: kRed),
        ),
        borderColor: kRed,
        isError: true,
      );
      return;
    }

    final success = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => TransferDialog(),
    );

    if (!mounted) return;

    if (success == true) {
      ref.read(saleReportProvider.notifier).refreshAccount(date: selectedDate);
      ref
          .read(saleReportProvider.notifier)
          .refreshTransfer(selectedDate.toIso8601String().split("T")[0]);
    }
  }

  Future<void> _submit(String date, double total) async {
    final success = await ref
        .read(saleReportProvider.notifier)
        .postOpeningAndClosingBalance(date: date, total: total);

    if (!mounted) return;

    if (success) {
      ShowToast(
        context,
        description: Text(
          SaleReportLocale.saleReportSaved.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.title(context)),
        ),
      );
      ref.read(saleReportProvider.notifier).refreshAccount(date: selectedDate);
      ref
          .read(saleReportProvider.notifier)
          .refreshTransfer(selectedDate.toIso8601String().split("T")[0]);
      ref
          .read(saleReportProvider.notifier)
          .refreshSaleReportEntries(
            selectedDate.toIso8601String().split("T")[0],
          );
    } else {
      ShowToast(
        context,
        description: Text(
          SaleReportLocale.saleReportSaveFailed.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.title(context)),
        ),
        borderColor: Colors.redAccent,
        action: Icon(LucideIcons.x, color: Colors.redAccent),
      );
    }
  }

  void _deleteTransfer(Transfer transfer, bool isDark) async {
    final confirmed = await showConfirmDialog(
      context,
      content: "Do you want to delete this transfer",
      title: "Delete Transfer",
      confirmLabel: "Confirm",
      cancelLabel: "Cancel",
    );
    if (confirmed != true) return;
    final success = await ref
        .read(saleReportProvider.notifier)
        .deleteTransfer(transfer.id);

    if (!mounted) return;

    if (success) {
      ShowToast(context, description: Text("Deleted Successfully"));
      ref.read(saleReportProvider.notifier).refreshAccount(date: selectedDate);
      ref
          .read(saleReportProvider.notifier)
          .refreshTransfer(selectedDate.toIso8601String().split("T")[0]);
    } else {
      ShowToast(
        context,
        isError: true,
        description: Text("Errror"),
        borderColor: kRed,
      );
    }
  }

  void _deleteSaleReportEntry(SaleReportEntry entry, bool isDark) async {
    final confirmed = await showConfirmDialog(
      context,
      content: "Do you want to delete this record",
      title: "Delete Sale Report",
      confirmLabel: "Confirm",
      cancelLabel: "Cancel",
    );
    if (confirmed != true) return;

    final success = await ref
        .read(saleReportProvider.notifier)
        .deleteSaleReportEntry(entry.id);

    if (!mounted) return;

    if (success) {
      ShowToast(context, description: const Text("Deleted Successfully"));
      ref.read(saleReportProvider.notifier).refreshAccount(date: selectedDate);
      ref.invalidate(
        saleReportListProvider(selectedDate.toIso8601String().split("T")[0]),
      );
    } else {
      ShowToast(
        context,
        isError: true,
        description: const Text("Error"),
        borderColor: kRed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncReport = ref.watch(saleReportProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final formattedDate = DateFormat('dd MMM yyyy').format(selectedDate);
    final transfersAsync = ref.watch(
      transferListProvider(selectedDate.toIso8601String().split("T")[0]),
    );
    final saleReportEntriesAsync = ref.watch(
      saleReportListProvider(selectedDate.toIso8601String().split("T")[0]),
    );
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final user = ref.watch(userStateProvider);

    // debugPrint("the select date 📆 $selectedDate");
    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: DrawerScreenLocale.drawerSaleReport.getString(context),
      ),
      body: asyncReport.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: kPrimary)),
        error: (err, stack) => const Center(child: Text('Error')),
        data: (report) {
          return RefreshIndicator(
            onRefresh: () async {
              ref
                  .read(saleReportProvider.notifier)
                  .refreshAccount(date: selectedDate);
              ref
                  .read(saleReportProvider.notifier)
                  .refreshTransfer(
                    selectedDate.toIso8601String().split("T")[0],
                  );
              ref
                  .read(saleReportProvider.notifier)
                  .refreshSaleReportEntries(
                    selectedDate.toIso8601String().split("T")[0],
                  );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateSelectorCard(
                    formattedDate: formattedDate,
                    onTap: _pickDate,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  ClosingReportCard(report: report, isDark: isDark),
                  const SizedBox(height: 20),
                  //Button for save and transfer
                  Row(
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kPrimary, kSecondary],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ShadButton(
                            backgroundColor: Colors.transparent,
                            onPressed: () => _submit(
                              selectedDate.toIso8601String().split("T")[0],
                              report.closingAmount,
                            ),
                            child: Text(
                              SaleReportLocale.saleReportSave.getString(
                                context,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kGreen, kGreenSecondary],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ShadButton(
                            backgroundColor: Colors.transparent,
                            onPressed: () => _transferSaleAmount(report),
                            child: Text(
                              SaleReportLocale.saleReportTransfer.getString(
                                context,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ///Sale Report History
                  const Text(
                    "Sale Report History",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  saleReportEntriesAsync.when(
                    data: (entries) {
                      if (entries.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "No records for this day",
                            style: TextStyle(color: subColor, fontSize: 12),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final e = entries[index];
                          return SaleReportEntryCard(
                            entry: e,
                            isDark: isDark,
                            canDelete: isAdmin(user!.role),
                            onDelete: () => _deleteSaleReportEntry(e, isDark),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (err, _) => Text(
                      "Error loading sale report entries: $err",
                      style: TextStyle(color: subColor, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ///Transfer Data
                  const Text(
                    "Transfer Datas",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  transfersAsync.when(
                    data: (transfers) {
                      if (transfers.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "No transfers for this day",
                            style: TextStyle(color: subColor, fontSize: 12),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transfers.length,
                        itemBuilder: (context, index) {
                          final t = transfers[index];
                          return TransferCard(
                            transfer: t,
                            isDark: isDark,
                            canDelete: isAdmin(user!.role),
                            onDelete: () => _deleteTransfer(t, isDark),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (err, _) => Text(
                      "Error loading transfers: $err",
                      style: TextStyle(color: subColor, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
