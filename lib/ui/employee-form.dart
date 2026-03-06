import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/component/input.dart';
import 'package:pos/localization/employee-local.dart';
import 'package:pos/models/holidays.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:pos/localization/inventory-management-local.dart';
import 'package:pos/utils/app-theme.dart';

class EmployeeManagementForm extends ConsumerStatefulWidget {
  const EmployeeManagementForm({super.key});

  @override
  ConsumerState<EmployeeManagementForm> createState() =>
      _EmployeeManagementFormState();
}

class _EmployeeManagementFormState
    extends ConsumerState<EmployeeManagementForm> {
  final _formKey = GlobalKey<ShadFormState>();
  final reasonCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final hourlySalaryCtrl = TextEditingController();
  final monthlySalaryCtrl = TextEditingController();
  final startTimeCtrl = TextEditingController();
  final endTimeCtrl = TextEditingController();
  String? type;
  bool locationRestrict = false;
  List<String> holidays = [];
  List<HolidayModel> holidayArrays = [
    HolidayModel(
      name: "Mon",
      title: EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.monday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Tue",
      title: EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.tuesday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Wed",
      title:
          EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.wednesday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Thu",
      title:
          EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.thursday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Fri",
      title: EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.friday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Sat",
      title:
          EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.saturday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Sun",
      title: EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.sunday]!,
      isCheck: false,
    ),
  ];

  bool value = false;

  void toggleHoliday(String day, bool isChecked) {
    if (isChecked) {
      // Add day if not already in the list
      if (!holidays.contains(day)) {
        holidays.add(day);
      }
    } else {
      // Remove day if unchecked
      holidays.remove(day);
    }
  }

  void _submit() async {
    // Validate form
    if (!_formKey.currentState!.saveAndValidate()) {
      ShowToast(
        context,
        description: Text(
          "Please fill all required fields.",
          style: TextStyle(color: Colors.red),
        ),
      );
      return;
    }

    // Build payload
    final payload = {
      "firstName": firstNameCtrl.text.trim(),
      "lastName": lastNameCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "password": passwordCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "address": addressCtrl.text.trim(),
      "employeeType": type, // HOURLY / MONTHLY
      "hourlySalary": type == 'HOURLY' ? hourlySalaryCtrl.text.trim() : null,
      "monthlySalary": type == 'MONTHLY' ? monthlySalaryCtrl.text.trim() : null,
      "startTime": type == 'MONTHLY' ? startTimeCtrl.text.trim() : null,
      "endTime": type == 'MONTHLY' ? endTimeCtrl.text.trim() : null,
      "holidays": type == 'MONTHLY' ? holidays : [],
      "locationRestrict": locationRestrict,
    };

    debugPrint("🟢 Employee Payload => $payload");

    try {
      // Replace this with your provider/API call
      final api = await ref.read(userProvider.notifier).postUser(payload);

      if (api) {
        ShowToast(
          context,
          description: Text(
            EmployeeLocaleScreenLocale.employeeSuccess.getString(context),
            style: TextStyle(color: Colors.green),
          ),
        );

        // Clear form
        _formKey.currentState!.reset();
        firstNameCtrl.clear();
        lastNameCtrl.clear();
        emailCtrl.clear();
        passwordCtrl.clear();
        phoneCtrl.clear();
        addressCtrl.clear();
        hourlySalaryCtrl.clear();
        monthlySalaryCtrl.clear();
        startTimeCtrl.clear();
        endTimeCtrl.clear();
        setState(() {
          type = null;
          holidays.clear();
          holidayArrays = holidayArrays
              .map((h) => h.copyWith(isCheck: false))
              .toList();
        });
      } else {
        ShowToast(
          context,
          description: Text(
            EmployeeLocaleScreenLocale.employeeFail.getString(context),
            style: TextStyle(color: Colors.red),
          ),
        );
      }
    } catch (e) {
      ShowToast(
        context,
        description: Text(
          EmployeeLocaleScreenLocale.employeeFail.getString(context),
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    reasonCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final labelColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    //print("type is $");
    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: input(
                  context,
                  label: EmployeeLocaleScreenLocale.employeeFirstName.getString(
                    context,
                  ),
                  controller: firstNameCtrl,
                  labelColor: labelColor,
                ),
              ),
              Expanded(
                child: input(
                  context,
                  label: EmployeeLocaleScreenLocale.employeeLastName.getString(
                    context,
                  ),
                  controller: lastNameCtrl,
                  labelColor: labelColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Email
          input(
            context,
            label: EmployeeLocaleScreenLocale.employeeEmail.getString(context),
            controller: emailCtrl,
            labelColor: labelColor,
          ),

          const SizedBox(height: 20),

          /// Password
          input(
            context,
            label: EmployeeLocaleScreenLocale.employeePassword.getString(
              context,
            ),
            controller: passwordCtrl,
            labelColor: labelColor,
          ),

          const SizedBox(height: 20),

          /// Phone
          input(
            context,
            label: EmployeeLocaleScreenLocale.employeePhone.getString(context),
            controller: phoneCtrl,
            labelColor: labelColor,
          ),

          const SizedBox(height: 20),

          /// Address
          input(
            context,
            label: EmployeeLocaleScreenLocale.employeeAddress.getString(
              context,
            ),
            controller: addressCtrl,
            labelColor: labelColor,
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ShadRadioGroup<String>(
              alignment: WrapAlignment.center,
              onChanged: (value) => setState(() => type = value!),
              spacing: 10,
              items: [
                ShadRadio(
                  label: Text(
                    EmployeeLocaleScreenLocale.employeeHourlySalary.getString(
                      context,
                    ),
                  ),
                  value: 'HOURLY',
                ),
                ShadRadio(
                  label: Text(
                    EmployeeLocaleScreenLocale.employeeMonthlySalary.getString(
                      context,
                    ),
                  ),
                  value: 'MONTHLY',
                ),
              ],
            ),
          ),

          // 👇 Conditional UI
          if (type == 'HOURLY') ...[
            const SizedBox(height: 20),
            input(
              context,
              label: EmployeeLocaleScreenLocale.employeeHourlySalary.getString(
                context,
              ),
              controller: hourlySalaryCtrl,
              labelColor: labelColor,
            ),
          ],

          if (type == 'MONTHLY') ...[
            const SizedBox(height: 20),
            input(
              context,
              label: EmployeeLocaleScreenLocale.employeeMonthlySalary.getString(
                context,
              ),
              controller: monthlySalaryCtrl,
              labelColor: labelColor,
            ),
          ],

          SizedBox(height: 20),

          if (type == 'MONTHLY')
            /// Start time
            input(
              context,
              label: EmployeeLocaleScreenLocale.employeeStartTime.getString(
                context,
              ),
              controller: startTimeCtrl,
              labelColor: labelColor,
            ),

          const SizedBox(height: 20),

          if (type == 'MONTHLY')
            /// End time
            input(
              context,
              label: EmployeeLocaleScreenLocale.employeeEndTime.getString(
                context,
              ),
              controller: endTimeCtrl,
              labelColor: labelColor,
            ),

          const SizedBox(height: 20),

          if (type == 'MONTHLY')
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: holidayArrays.asMap().entries.map((h) {
                  int index = h.key;
                  final holiday = h.value;
                  final title = holiday.title;
                  return ShadCheckbox(
                    value: holiday.isCheck,
                    onChanged: (v) => setState(() {
                      toggleHoliday(holiday.name, v);
                      holidayArrays[index] = holidayArrays[index].copyWith(
                        isCheck: v,
                      );
                    }),
                    label: Text(title),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 20),
          ShadSwitch(
            value: locationRestrict,
            onChanged: (v) => setState(() => locationRestrict = v),
            label: Text(
              EmployeeLocaleScreenLocale.employeeLocationRestrict.getString(
                context,
              ),
            ),
          ),
          const SizedBox(height: 20),

          /// Submit Button
          GradientSubmitButton(
            onPressed: () => _submit(),
            text: InventoryManagementLocale.inventorySubmit.getString(context),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
