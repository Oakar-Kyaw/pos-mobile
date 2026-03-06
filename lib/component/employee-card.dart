import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pos/component/accent-bar.dart';
import 'package:pos/localization/employee-local.dart';
import 'package:pos/models/user.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/badge.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EmployeeCard extends StatelessWidget {
  EmployeeCard({
    super.key,
    required this.textColor,
    required this.subColor,
    required this.employee,
    required this.pagingController,
  });

  final Color textColor;
  final Color subColor;
  final User employee;
  PagingController<int, User> pagingController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccentBar(hasDebt: false),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EmployeeHeader(employee: employee),

                  const SizedBox(height: 8),
                  Text(
                    "${employee.firstName} ${employee.lastName}",
                    style: TextStyle(
                      fontSize: FontSizeConfig.title(context),
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    employee.email,
                    style: TextStyle(
                      fontSize: FontSizeConfig.title(context),
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    employee.phone ?? "-",
                    style: TextStyle(
                      fontSize: FontSizeConfig.title(context),
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  employee.employeeType == 'MONTHLY'
                      ? SalaryWidget(
                          salary: employee.monthlySalary.toString(),
                          title: EmployeeLocaleScreenLocale.employeeSalary
                              .getString(context),
                        )
                      : SalaryWidget(
                          salary: employee.hourlySalary.toString(),
                          title: EmployeeLocaleScreenLocale.employeeSalary
                              .getString(context),
                        ),
                  SizedBox(height: 8),
                  Text(
                    EmployeeLocaleScreenLocale.employeeHoliday.getString(
                      context,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: employee.holidays.map((day) {
                      return BadgeWidget(
                        icon: Icons.holiday_village,
                        label: day,
                        color: kPrimary,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeHeader extends StatelessWidget {
  const EmployeeHeader({super.key, required this.employee});

  final User employee;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BadgeWidget(icon: Icons.person, label: employee.role, color: kRed),
        SizedBox(width: 8),
        BadgeWidget(
          icon: Icons.people,
          label: employee.employeeType,
          color: kGreenSecondary,
        ),
      ],
    );
  }
}

class SalaryWidget extends StatelessWidget {
  final String title;
  final String salary;
  SalaryWidget({required this.salary, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Text(title), Spacer(), Text(salary)]);
  }
}
