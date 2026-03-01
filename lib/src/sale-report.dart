// pages/sale_report_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/income-dashboard.api.dart';
import 'package:pos/api/sale-report.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/closing-report-card.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/sale-report-local.dart';
import 'package:pos/utils/app-theme.dart';
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
      ref.read(incomeProvider.notifier).getIncomesByCompany(date: selectedDate);
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

  Future<void> _submit() async {
    final report = ref.read(saleReportProvider).value;
    if (report == null) return;
    String date = DateFormat('yyyy-MM-dd').format(selectedDate);
    print("Submitting report for ${date}");
    double total =
        (report.openingAmount ?? 0) +
        (report.closingAmount ?? 0) +
        double.parse(
          ref
              .read(incomeProvider)
              .maybeWhen(
                data: (income) => income.getTodaySale.total.toString(),
                orElse: () => '0',
              ),
        );
    print("Total Amount: $total");
    final success = await ref
        .read(saleReportProvider.notifier)
        .postOpeningAndClosingBalance(date: date, total: total);
    if (success) {
      ShowToast(
        context,
        description: Text(
          SaleReportLocale.saleReportSaved.getString(context),
          style: TextStyle(fontSize: FontSizeConfig.title(context)),
        ),
      );
      ref.read(saleReportProvider.notifier).getOpenClosing(date: selectedDate);
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

  @override
  Widget build(BuildContext context) {
    final asyncReport = ref.watch(saleReportProvider);
    final asyncIncome = ref.watch(incomeProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final formattedDate = DateFormat('EEE, dd MMM yyyy').format(selectedDate);

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
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (report) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                DateSelectorCard(
                  formattedDate: formattedDate,
                  onTap: _pickDate,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                ClosingReportCard(
                  report: report,
                  asyncIncome: asyncIncome,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
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
                          onPressed: _submit,
                          child: Text(
                            SaleReportLocale.saleReportSave.getString(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // spacing between buttons
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
                          onPressed: () {},
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
              ],
            ),
          );
        },
      ),
    );
  }
}
