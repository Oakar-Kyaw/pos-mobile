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
  String? role;

  bool locationRestrict = false;

  List<String> holidays = [];

  List<HolidayModel> holidayArrays = [
    HolidayModel(
      name: "Monday",
      title: EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.monday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Tuesday",
      title: EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.tuesday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Wednesday",
      title:
          EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.wednesday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Thursday",
      title:
          EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.thursday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Friday",
      title: EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.friday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Saturday",
      title:
          EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.saturday]!,
      isCheck: false,
    ),
    HolidayModel(
      name: "Sunday",
      title: EmployeeLocaleScreenLocale.EN[EmployeeLocaleScreenLocale.sunday]!,
      isCheck: false,
    ),
  ];

  void toggleHoliday(String day, bool isChecked) {
    if (isChecked) {
      if (!holidays.contains(day)) {
        holidays.add(day);
      }
    } else {
      holidays.remove(day);
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: controller.text.isNotEmpty
          ? _parseTime(controller.text)
          : TimeOfDay.now(),
    );

    if (picked == null) return;

    final hour = picked.hour.toString().padLeft(2, '0');
    final minute = picked.minute.toString().padLeft(2, '0');

    controller.text = '$hour:$minute';

    setState(() {});
  }

  TimeOfDay _parseTime(String value) {
    try {
      final parts = value.split(':');

      if (parts.length != 2) {
        return TimeOfDay.now();
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return TimeOfDay.now();
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return TimeOfDay.now();
    }
  }

  int _timeToMinutes(String value) {
    final parts = value.split(':');

    if (parts.length != 2) {
      return 0;
    }

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      ShowToast(
        context,
        description: const Text(
          "Please fill all required fields.",
          style: TextStyle(color: Colors.red),
        ),
      );
      return;
    }

    if (role == null) {
      ShowToast(
        context,
        description: const Text(
          "Please select a role.",
          style: TextStyle(color: Colors.red),
        ),
      );
      return;
    }

    if (type == null) {
      ShowToast(
        context,
        description: const Text(
          "Please select a salary type.",
          style: TextStyle(color: Colors.red),
        ),
      );
      return;
    }

    if (type == 'MONTHLY') {
      if (startTimeCtrl.text.isEmpty || endTimeCtrl.text.isEmpty) {
        ShowToast(
          context,
          description: const Text(
            "Please select start and end time.",
            style: TextStyle(color: Colors.red),
          ),
        );
        return;
      }

      final startMinutes = _timeToMinutes(startTimeCtrl.text);

      final endMinutes = _timeToMinutes(endTimeCtrl.text);

      if (endMinutes <= startMinutes) {
        ShowToast(
          context,
          description: const Text(
            "End time must be later than start time.",
            style: TextStyle(color: Colors.red),
          ),
        );
        return;
      }
    }

    final payload = {
      "firstName": firstNameCtrl.text.trim(),
      "lastName": lastNameCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "password": passwordCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "address": addressCtrl.text.trim(),
      "role": role,
      "employeeType": type,
      "hourlySalary": type == 'HOURLY' ? hourlySalaryCtrl.text.trim() : null,
      "monthlySalary": type == 'MONTHLY' ? monthlySalaryCtrl.text.trim() : null,
      "startTime": type == 'MONTHLY' ? startTimeCtrl.text.trim() : null,
      "endTime": type == 'MONTHLY' ? endTimeCtrl.text.trim() : null,
      "holidays": type == 'MONTHLY' ? holidays : [],
      "locationRestrict": locationRestrict,
    };

    debugPrint("🟢 Employee Payload => $payload");

    try {
      final api = await ref.read(userProvider.notifier).postUser(payload);

      if (!mounted) return;

      if (api) {
        ShowToast(
          context,
          description: Text(
            EmployeeLocaleScreenLocale.employeeSuccess.getString(context),
            style: const TextStyle(color: Colors.green),
          ),
        );

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
          role = null;
          locationRestrict = false;
          holidays.clear();

          holidayArrays = holidayArrays
              .map((holiday) => holiday.copyWith(isCheck: false))
              .toList();
        });
      } else {
        ShowToast(
          context,
          description: Text(
            EmployeeLocaleScreenLocale.employeeFail.getString(context),
            style: const TextStyle(color: Colors.red),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint("🤬 Employee create error => $e");

      ShowToast(
        context,
        description: Text(
          EmployeeLocaleScreenLocale.employeeFail.getString(context),
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    hourlySalaryCtrl.dispose();
    monthlySalaryCtrl.dispose();
    startTimeCtrl.dispose();
    endTimeCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final labelColor = isDark ? kTextDark : kTextLight;

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
              const SizedBox(width: 10),
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

          ShadSelect<String>(
            placeholder: const Text("Select Role"),
            options: const [
              ShadOption(value: "ADMIN", child: Text("ADMIN")),
              ShadOption(value: "SALE", child: Text("SALE")),
              ShadOption(value: "MANAGER", child: Text("MANAGER")),
            ],
            selectedOptionBuilder: (context, value) {
              return Text(value);
            },
            onChanged: (value) {
              setState(() {
                role = value;
              });
            },
          ),

          const SizedBox(height: 20),

          input(
            context,
            label: EmployeeLocaleScreenLocale.employeeEmail.getString(context),
            controller: emailCtrl,
            labelColor: labelColor,
          ),

          const SizedBox(height: 20),

          input(
            context,
            label: EmployeeLocaleScreenLocale.employeePassword.getString(
              context,
            ),
            controller: passwordCtrl,
            labelColor: labelColor,
          ),

          const SizedBox(height: 20),

          input(
            context,
            label: EmployeeLocaleScreenLocale.employeePhone.getString(context),
            controller: phoneCtrl,
            labelColor: labelColor,
          ),

          const SizedBox(height: 20),

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
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ShadRadioGroup<String>(
              alignment: WrapAlignment.center,
              spacing: 10,
              onChanged: (value) {
                setState(() {
                  type = value;

                  if (value == 'HOURLY') {
                    monthlySalaryCtrl.clear();
                    startTimeCtrl.clear();
                    endTimeCtrl.clear();
                    holidays.clear();

                    holidayArrays = holidayArrays
                        .map((holiday) => holiday.copyWith(isCheck: false))
                        .toList();
                  }

                  if (value == 'MONTHLY') {
                    hourlySalaryCtrl.clear();
                  }
                });
              },
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

          if (type == 'MONTHLY') ...[
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                _selectTime(startTimeCtrl);
              },
              child: AbsorbPointer(
                child: input(
                  context,
                  label: EmployeeLocaleScreenLocale.employeeStartTime.getString(
                    context,
                  ),
                  controller: startTimeCtrl,
                  labelColor: labelColor,
                ),
              ),
            ),
          ],

          if (type == 'MONTHLY') ...[
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                _selectTime(endTimeCtrl);
              },
              child: AbsorbPointer(
                child: input(
                  context,
                  label: EmployeeLocaleScreenLocale.employeeEndTime.getString(
                    context,
                  ),
                  controller: endTimeCtrl,
                  labelColor: labelColor,
                ),
              ),
            ),
          ],

          if (type == 'MONTHLY') ...[
            const SizedBox(height: 24),

            Text(
              "Holidays",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: labelColor,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: holidayArrays.asMap().entries.map((entry) {
                final index = entry.key;
                final holiday = entry.value;

                return ShadCheckbox(
                  value: holiday.isCheck,
                  onChanged: (value) {
                    setState(() {
                      toggleHoliday(holiday.name, value);

                      holidayArrays[index] = holidayArrays[index].copyWith(
                        isCheck: value,
                      );
                    });
                  },
                  label: Text(holiday.title),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            if (holidays.isNotEmpty)
              Text(
                "Selected holidays: ${holidays.join(', ')}",
                style: TextStyle(fontSize: 13, color: labelColor),
              ),
          ],

          const SizedBox(height: 20),

          // ShadSwitch(
          //   value: locationRestrict,
          //   onChanged: (value) {
          //     setState(() {
          //       locationRestrict = value;
          //     });
          //   },
          //   label: Text(
          //     EmployeeLocaleScreenLocale.employeeLocationRestrict.getString(
          //       context,
          //     ),
          //   ),
          // ),

          // const SizedBox(height: 20),
          GradientSubmitButton(
            onPressed: _submit,
            text: InventoryManagementLocale.inventorySubmit.getString(context),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
