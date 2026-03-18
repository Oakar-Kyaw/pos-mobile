import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/attendance.api.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/component/time-picker.dart';
import 'package:pos/localization/attendance-local.dart';
import 'package:pos/models/user.dart';
import 'package:pos/riverpod/company.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/check-role.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AttendanceForm extends ConsumerStatefulWidget {
  const AttendanceForm({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  ConsumerState<AttendanceForm> createState() => _AttendanceFormState();
}

class _AttendanceFormState extends ConsumerState<AttendanceForm> {
  final _formKey = GlobalKey<ShadFormState>();
  DateTime? _date;
  String? _checkIn;
  String? _checkOut;
  String? _overtime;
  final _noteCtrl = TextEditingController();
  final _workingMinutesCtrl = TextEditingController();
  final _overtimeController = ShadTimePickerController();
  final _checkInTimeController = ShadTimePickerController();
  final _checkOutTimeController = ShadTimePickerController();

  int? _userId;
  String _status = "PRESENT";
  String _checkInPeriod = 'AM';
  String _checkOutPeriod = 'PM';
  bool _overtimeEnabled = false;
  String? _overtimeType;

  String formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showError(String title) {
    ShowToast(
      context,
      description: Text(
        title,
        style: TextStyle(fontSize: FontSizeConfig.title(context), color: kRed),
      ),
      isError: true,
    );
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _workingMinutesCtrl.dispose();
    _checkInTimeController.dispose();
    _checkOutTimeController.dispose();
    _overtimeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!mounted) return;

    if (_date == null) {
      _showError(
        AttendanceLocaleScreenLocale.attendanceValidationError.getString(
          context,
        ),
      );
      return;
    }
    if (_checkIn == null) {
      _showError(
        AttendanceLocaleScreenLocale.attendanceCheckInRequired.getString(
          context,
        ),
      );
      return;
    }
    if (_checkOut == null) {
      _showError(
        AttendanceLocaleScreenLocale.attendanceCheckOutRequired.getString(
          context,
        ),
      );
      return;
    }
    print("over tiem is $_overtimeType $_overtime");
    if (_overtimeType != null &&
        _overtimeType == 'MINUTES' &&
        _overtime == null) {
      _showError(
        AttendanceLocaleScreenLocale.attendanceOvertimeRequired.getString(
          context,
        ),
      );
      return;
    }
    final user = ref.read(userStateProvider);
    final isAdminUser =
        user != null && (isAdmin(user.role) || isManager(user.role));
    final effectiveUserId = isAdminUser ? _userId : user?.id;
    if (isAdminUser && effectiveUserId == null) {
      ShowToast(
        context,
        description: Text(
          AttendanceLocaleScreenLocale.attendanceSelectUser.getString(context),
          style: TextStyle(
            fontSize: FontSizeConfig.title(context),
            color: kRed,
          ),
        ),
        isError: true,
      );
      return;
    }
    final note = _noteCtrl.text.trim();
    final workingMinutes = _workingMinutesCtrl.text.trim();

    // print("👀 data is $_date $checkIn $checkOut $_status");
    try {
      final result = await ref
          .read(attendanceProvider.notifier)
          .createAttendance(
            date: _date!,
            userId: effectiveUserId,
            status: _status,
            checkIn: _checkIn,
            checkOut: _checkOut,
            note: note.isNotEmpty ? note : null,
            workingHours: workingMinutes.isNotEmpty ? workingMinutes : null,
            overtimeType: _overtimeType,
            overtimeMinutes: _overtime,
          );

      if (result["success"] == true) {
        ShowToast(
          context,
          description: Text(
            AttendanceLocaleScreenLocale.attendanceSuccess.getString(context),
            style: TextStyle(fontSize: FontSizeConfig.title(context)),
          ),
        );
        widget.onSaved?.call();
      }
    } catch (_) {
      _showError(
        AttendanceLocaleScreenLocale.attendanceFail.getString(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final user = ref.watch(userStateProvider);
    final company = ref.watch(companyStateProvider);

    final attendanceTypeValue = {
      "PRESENT": AttendanceLocaleScreenLocale.attendancePresent.getString(
        context,
      ),
      "ABSENT": AttendanceLocaleScreenLocale.attendanceAbsent.getString(
        context,
      ),
      "LEAVE": AttendanceLocaleScreenLocale.attendanceLeave.getString(context),
      "HALF_DAY": AttendanceLocaleScreenLocale.attendanceHalfDay.getString(
        context,
      ),
      "HOLIDAY": AttendanceLocaleScreenLocale.attendanceHoliday.getString(
        context,
      ),
    };
    final attendanceTypeOptions = [
      {
        "value": 'PRESENT',
        'title': AttendanceLocaleScreenLocale.attendancePresent.getString(
          context,
        ),
      },
      {
        "value": "ABSENT",
        "title": AttendanceLocaleScreenLocale.attendanceAbsent.getString(
          context,
        ),
      },
      {
        "value": "HALF_DAY",
        "title": AttendanceLocaleScreenLocale.attendanceHalfDay.getString(
          context,
        ),
      },
      {
        "value": "HOLIDAY",
        "title": AttendanceLocaleScreenLocale.attendanceHoliday.getString(
          context,
        ),
      },
    ];

    return ShadForm(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user != null && (isAdmin(user.role) || isManager(user.role)))
            _UserSelectField(
              companyId: company?.id,
              onChanged: (id) => setState(() => _userId = id),
            ),
          const SizedBox(height: 12),

          _Label(
            text: AttendanceLocaleScreenLocale.attendanceDate.getString(
              context,
            ),
          ),
          const SizedBox(height: 6),
          ShadDatePicker(onChanged: (value) => _date = value),
          const SizedBox(height: 12),

          _Label(
            text: AttendanceLocaleScreenLocale.attendanceStatus.getString(
              context,
            ),
          ),
          const SizedBox(height: 6),
          ShadSelect<String>(
            initialValue: _status,
            options: attendanceTypeOptions.map(
              (o) => ShadOption(value: o["value"], child: Text(o["title"]!)),
            ),
            selectedOptionBuilder: (context, value) =>
                Text(attendanceTypeValue[value]!),
            placeholder: Text(
              AttendanceLocaleScreenLocale.attendanceStatusPlaceholder
                  .getString(context),
              style: TextStyle(color: subColor),
            ),
            onChanged: (value) {
              if (value != null) setState(() => _status = value);
            },
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              TimePicker(
                timeController: _checkInTimeController,
                title: AttendanceLocaleScreenLocale.attendanceCheckIn.getString(
                  context,
                ),
                onChanged: (time, period, minutes) {
                  _checkIn = time;
                  setState(() {
                    _checkInPeriod = period;
                  });
                },
              ),
              const SizedBox(width: 20),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Text(
                    _checkInPeriod,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              TimePicker(
                timeController: _checkOutTimeController,
                title: AttendanceLocaleScreenLocale.attendanceCheckOut
                    .getString(context),
                onChanged: (time, period, minutes) {
                  _checkOut = time;
                  setState(() {
                    _checkOutPeriod = period;
                  });
                },
              ),
              const SizedBox(width: 20),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Text(
                    _checkOutPeriod,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // _Label(
          //   text: AttendanceLocaleScreenLocale.attendanceWorkingMinutes
          //       .getString(context),
          // ),
          // const SizedBox(height: 6),
          // ShadInputFormField(
          //   controller: _workingMinutesCtrl,
          //   keyboardType: TextInputType.number,
          //   decoration: const ShadDecoration(
          //     secondaryBorder: ShadBorder.none,
          //     secondaryFocusedBorder: ShadBorder.none,
          //   ),
          //   placeholder: Text(
          //     AttendanceLocaleScreenLocale.attendanceWorkingMinutesPlaceholder
          //         .getString(context),
          //     style: TextStyle(color: subColor),
          //   ),
          // ),
          const SizedBox(height: 12),

          _Label(
            text: AttendanceLocaleScreenLocale.attendanceNote.getString(
              context,
            ),
          ),
          const SizedBox(height: 6),
          ShadInputFormField(
            controller: _noteCtrl,
            decoration: const ShadDecoration(
              secondaryBorder: ShadBorder.none,
              secondaryFocusedBorder: ShadBorder.none,
            ),
            placeholder: Text(
              AttendanceLocaleScreenLocale.attendanceNotePlaceholder.getString(
                context,
              ),
              style: TextStyle(color: subColor),
            ),
          ),

          const SizedBox(height: 20),

          ShadCheckbox(
            value: _overtimeEnabled,
            sublabel: Text(
              AttendanceLocaleScreenLocale.attendanceOvertime.getString(
                context,
              ),
            ),
            onChanged: (value) => setState(() {
              _overtimeEnabled = value;
            }),
          ),
          const SizedBox(height: 10),
          _overtimeEnabled
              ? ShadRadioGroup<String>(
                  onChanged: (value) {
                    //print("Radio Grup $value");
                    setState(() {
                      _overtimeType = value;
                    });
                  },
                  axis: Axis.horizontal,
                  spacing: 30,
                  items: [
                    ShadRadio(
                      label: Text(
                        AttendanceLocaleScreenLocale.attendanceHour.getString(
                          context,
                        ),
                      ),
                      value: 'MINUTES',
                    ),
                    ShadRadio(
                      label: Text(
                        AttendanceLocaleScreenLocale.attendanceDay.getString(
                          context,
                        ),
                      ),
                      value: 'Day',
                    ),
                  ],
                )
              : const SizedBox(),
          const SizedBox(height: 10),
          Visibility(
            visible: _overtimeType == 'MINUTES',
            child: TimePicker(
              timeController: _overtimeController,
              title: "",
              onChanged: (value, period, minutes) {
                print("shad time value is $value $period");
                _overtime = minutes;
              },
            ),
          ),
          const SizedBox(height: 20),
          GradientSubmitButton(
            onPressed: _submit,
            text: AttendanceLocaleScreenLocale.attendanceCreate.getString(
              context,
            ),
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600));
  }
}

class _OvertimeChip extends StatelessWidget {
  const _OvertimeChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kPrimary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? kPrimary : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? kPrimary : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _UserSelectField extends ConsumerWidget {
  const _UserSelectField({required this.companyId, required this.onChanged});

  final int? companyId;
  final void Function(int? userId) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (companyId == null) return const SizedBox.shrink();

    final userAsync = ref.watch(userByCompanyProvider(companyId!));
    return userAsync.when(
      data: (users) {
        final options = [
          ...users.map(
            (u) => ShadOption<int>(value: u.id, child: Text(u.email)),
          ),
        ];

        Map<int, User> userMaps = Map.fromEntries(
          users.map((u) => MapEntry(u.id, u)),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label(
              text: AttendanceLocaleScreenLocale.attendanceEmployee.getString(
                context,
              ),
            ),
            const SizedBox(height: 6),
            ShadSelect<int>(
              options: options,
              selectedOptionBuilder: (context, value) =>
                  Text(userMaps[value]!.email),
              placeholder: Text(
                AttendanceLocaleScreenLocale.attendanceSelectUser.getString(
                  context,
                ),
              ),
              onChanged: (value) {
                if (value == null || value == 0) {
                  onChanged(null);
                } else {
                  onChanged(value);
                }
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
