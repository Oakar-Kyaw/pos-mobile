import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/attendance.api.dart';
import 'package:pos/api/payroll.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/input.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/component/payment-calculation-card.dart';
import 'package:pos/component/payroll-form.dart';
import 'package:pos/localization/attendance-local.dart';
import 'package:pos/localization/payroll-local.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/models/attendance.dart';
import 'package:pos/models/payroll.dart';
import 'package:pos/models/user.dart';
import 'package:pos/ui/attendance-list-by-userId.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PayrollCreatePage extends ConsumerStatefulWidget {
  const PayrollCreatePage({super.key});

  @override
  ConsumerState<PayrollCreatePage> createState() => _PayrollCreatePageState();
}

class _PayrollCreatePageState extends ConsumerState<PayrollCreatePage> {
  User? selectedUser;
  CalculateSalaryData? calculateSalaryData;
  AttendanceGroupedByStatus? attendanceGroupedByStatus;
  bool isLoading = false;
  bool isCalculating = false;
  DateTime selectedDate = DateTime.now();
  double bonusAmount = 0;
  double deductionAmount = 0;
  final TextEditingController bonusController = TextEditingController();
  final TextEditingController deductionController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    bonusController.dispose();
    deductionController.dispose();
    bonusController.dispose();
    deductionController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _onBonusChange({required double bonus}) {
    if (calculateSalaryData == null) return;
    print("von $bonus");
    setState(() {
      bonusAmount = bonus;
    });
  }

  void _onDeductionChange({required double deduct}) {
    if (calculateSalaryData == null) return;
    print("von $deduct");
    setState(() {
      deductionAmount = (deduct);
    });
  }

  CalculateSalaryData _applyAdjustments(CalculateSalaryData data) {
    // print("calc and bonus ${bonusAmount}");
    final adjustedTotalDeductions = data.totalDeductions + deductionAmount;
    final adjustedNetSalary = data.netSalary + bonusAmount - deductionAmount;

    return CalculateSalaryData(
      totalSalary: data.totalSalary,
      overtime: data.overtime,
      salaryByDay: data.salaryByDay,
      attendanceSalary: data.attendanceSalary,
      workedDays: data.workedDays,
      lateDeduction: data.lateDeduction,
      earlyLeaveDeduction: data.earlyLeaveDeduction,
      absentDeduction: data.absentDeduction,
      leaveDeduction: data.leaveDeduction,
      totalDeductions: adjustedTotalDeductions,
      netSalary: adjustedNetSalary,
      lateDeductionItems: data.lateDeductionItems,
      earlyLeaveDeductionItems: data.earlyLeaveDeductionItems,
    );
  }

  void onUserChange(User user) {
    setState(() {
      selectedUser = user;
    });

    fetchAttendance(user.id);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      if (selectedUser != null) {
        fetchAttendance(selectedUser!.id);
      }
    }
  }

  void _calculateSalary() async {
    if (selectedUser == null) return;
    setState(() {
      isCalculating = true;
    });
    try {
      //  print("slected ${selectedDate.toUtc().toIso8601String()}");
      final result = await ref
          .read(payrollProvider.notifier)
          .calculatePayroll(
            date: selectedDate.toUtc().toIso8601String(),
            userId: selectedUser!.id,
          );
      //  print("cac; ${result.totalSalary}");
      setState(() {
        calculateSalaryData = result;
      });
    } catch (e) {
      debugPrint("Payroll calculate error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isCalculating = false;
        });
      }
    }
  }

  Future<void> fetchAttendance(int userId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ref
          .read(attendanceProvider.notifier)
          .getMonthlyAttendanceGroupedByStatus(
            filterUserId: userId,
            date: selectedDate,
          );

      setState(() {
        attendanceGroupedByStatus = response;
      });
    } catch (e) {
      debugPrint("Attendance fetch error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });

    print("DATE is $selectedDate");

    final Map<String, dynamic> payrollPayload = {
      "date": selectedDate.toUtc().toIso8601String(),
      "userId": selectedUser!.id,
      "bonus": bonusAmount,
      "deduction": deductionAmount,
      "note": noteController.text,
      "status": "APPROVED",
    };

    try {
      final response = await ref
          .read(payrollProvider.notifier)
          .createPayroll(payrollPayload);

      if (response["success"]) {
        ShowToast(context, description: Text("Payroll Created Successfully"));
        final payrollId = response["payrollId"];
        context.pushNamed(
          AppRoute.payrollPayslip,
          pathParameters: {'id': payrollId.toString()},
        );
      }
    } catch (e) {
      String message = "Something went wrong";

      if (e is DioException) {
        message = e.message ?? message;
      }

      ShowToast(
        context,
        isError: true,
        description: Text(message, style: TextStyle(color: kRed)),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final formattedMonth = DateFormat('MMM yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: PayrollLocaleScreenLocale.payrollTitle.getString(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? kPrimary.withOpacity(0.08)
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          LucideIcons.calendar,
                          color: kPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PayrollLocaleScreenLocale.payrollMonth.getString(
                              context,
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? kTextDark : kTextLight,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedMonth,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? kTextDark : kTextLight,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          PayrollLocaleScreenLocale.payrollChange.getString(
                            context,
                          ),
                          style: const TextStyle(
                            color: kPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Payroll Form
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: PayrollForm(onUserChange: (user) => onUserChange(user)),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GradientSubmitButton(
                onPressed: _calculateSalary,
                text: PayrollLocaleScreenLocale.payrollCalculateSalary
                    .getString(context),
                width: 150,
              ),
            ),

            const SizedBox(height: 20),

            Divider(height: 1),

            const SizedBox(height: 20),
            if (isCalculating) ...[
              const Center(child: LoadingWidget()),
              const SizedBox(height: 20),
            ],
            if (calculateSalaryData != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PaymentCalculationCard(
                  data: _applyAdjustments(calculateSalaryData!),
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    input(
                      context,
                      label: PayrollLocaleScreenLocale.payrollBonus.getString(
                        context,
                      ),
                      controller: bonusController,
                      onChanged: (v) =>
                          _onBonusChange(bonus: double.tryParse(v) ?? 0),
                      labelColor: isDark ? kTextDark : kTextLight,
                      isNumber: true,
                    ),
                    const SizedBox(height: 12),
                    input(
                      context,
                      label: PayrollLocaleScreenLocale.payrollDeduction
                          .getString(context),
                      controller: deductionController,
                      onChanged: (v) =>
                          _onDeductionChange(deduct: double.tryParse(v) ?? 0),
                      labelColor: isDark ? kTextDark : kTextLight,
                      isNumber: true,
                    ),
                    const SizedBox(height: 12),
                    input(
                      context,
                      label: PayrollLocaleScreenLocale.payrollNote.getString(
                        context,
                      ),
                      controller: noteController,
                      labelColor: isDark ? kTextDark : kTextLight,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GradientSubmitButton(
                  onPressed: _submit,
                  text: PayrollLocaleScreenLocale.payrollCreate.getString(
                    context,
                  ),
                  width: 160,
                ),
              ),
              const SizedBox(height: 20),
              Divider(height: 1),
              const SizedBox(height: 20),
            ],
            // Show loading indicator
            if (isLoading) const Center(child: CircularProgressIndicator()),

            // Attendance Sections
            if (attendanceGroupedByStatus != null && !isLoading) ...[
              buildSection(
                context,
                AttendanceLocaleScreenLocale.attendanceAbsent.getString(
                  context,
                ),
                attendanceGroupedByStatus!.attendanceByAbsent,
              ),
              buildSection(
                context,
                AttendanceLocaleScreenLocale.attendanceHalfDay.getString(
                  context,
                ),
                attendanceGroupedByStatus!.attendanceByHalfDay,
              ),
              buildSection(
                context,
                AttendanceLocaleScreenLocale.attendanceLate.getString(context),
                attendanceGroupedByStatus!.attendanceByLate,
              ),
              buildSection(
                context,
                AttendanceLocaleScreenLocale.attendancePresent.getString(
                  context,
                ),
                attendanceGroupedByStatus!.attendanceByPresent,
              ),
              buildSection(
                context,
                AttendanceLocaleScreenLocale.attendanceLeave.getString(context),
                attendanceGroupedByStatus!.attendanceByLeave,
              ),
              buildSection(
                context,
                AttendanceLocaleScreenLocale.attendanceHoliday.getString(
                  context,
                ),
                attendanceGroupedByStatus!.attendanceByHoliday,
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Reusable section for each attendance status
  Widget buildSection(
    BuildContext context,
    String title,
    List<Attendance> list,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        list.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 5,
                ),
                child: Center(
                  child: Text(
                    VoucherScreenLocale.noItems.getString(context),
                    style: const TextStyle(
                      color: kRed,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : AttendanceListByUserId(attendanceList: list),
        list.isEmpty ? const SizedBox(height: 10) : SizedBox(),
      ],
    );
  }
}
